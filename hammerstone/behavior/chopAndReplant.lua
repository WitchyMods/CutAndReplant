local function completeChopAction(super, allowCompletion, sapien, orderObject, orderState, actionState, constructableType, requiredLearnComplete)
    local constructable = mjrequire "common/constructable"
    local gameObject = mjrequire "common/gameObject"
    local plan = mjrequire "common/plan"

    local tribeID = sapien.sharedState.tribeID

    if allowCompletion and orderObject.sharedState.planStates and orderObject.sharedState.planStates[tribeID] then
        for _, planState in ipairs(orderObject.sharedState.planStates[tribeID]) do
            if planState.planTypeIndex == plan.types.chopAndReplant.index then
                local objectState = orderObject.sharedState

                local constructableTypeIndex = objectState.constructionConstructableTypeIndex

                if not constructableTypeIndex then
                    local orderGameObject = gameObject.types[orderObject.objectTypeIndex]
                    local modelName = orderGameObject.modelName
                    
                    if not constructable.types["plant_" .. modelName] then
                        mj:warn("Could not find constructable type")
                        break
                    end

                    constructableTypeIndex = constructable.types["plant_" .. modelName].index
                end

                local userData = {
                    noBuildOrder = false,
                    planTypeIndex = plan.types.plant.index,
                    pos = orderObject.pos,
                    rotation = orderObject.rotation,
                    constructableTypeIndex = constructableTypeIndex,
                    attachedToTerrain = true
                }
        
                super(allowCompletion, sapien, orderObject, orderState, actionState, constructableType, requiredLearnComplete)
        
                mjrequire("server/planManager"):addPlans(sapien.sharedState.tribeID, userData)
                
                return
            end
        end
    end

    super(allowCompletion, sapien, orderObject, orderState, actionState, constructableType, requiredLearnComplete)
end

-- put in a function so we don't mjrequire activeOrderAI too soon
local function getActionLogic(activeOrderAI)
    local action = mjrequire "common/action"

    local chopInfos = activeOrderAI.updateInfos[action.types.chop.index]
    local super_complete = chopInfos.completionFunction

    return {
        actionTypeIndex = action.types.chop.index,
        checkFrequency = chopInfos.checkFrequency,
        defaultSkillIndex = chopInfos.defaultSkillIndex,
        toolMultiplierTypeIndex = chopInfos.toolMultiplierTypeIndex,
        injuryRisk = chopInfos.injuryRisk,
        completionFunction = function(allowCompletion, sapien, orderObject, orderState, actionState, constructableType, requiredLearnComplete)
            mj:log("In complete function")
            completeChopAction(super_complete, allowCompletion, sapien, orderObject, orderState, actionState, constructableType, requiredLearnComplete)
        end
    }
end

return {
    description = {
        identifier = "chopAndReplant",
        icon = "icon_chopReplant"
    },
    components = {
        hs_plan = {
            priority = "mineChopPriorityOffset",
            collision_path_check = "skip"
        },
        hs_action_sequence = {
            trigger = 2,
            snap = 2,
            actions = {
                "moveTo",
                "chop"
            }
        },
        hs_order = {
            limiting = true,
            plan_link = {
                repeat_count = 2
            }
        },
        hs_action_logic = getActionLogic,
        hs_plan_availability = {
            target_type = "objects",
            object_groups = {"floraTypes"},
            tool = "treeChop",
            skill = "treeFelling",
            add_condition =  function(planHelper, vertOrObjectInfos, tribeID)
                local flora = mjrequire "common/flora"
                return flora:requiresAxeToChop(vertOrObjectInfos[1])
            end,
            discovery = {
                do_check = true,
                condition = function(planHelper, context, vertOrObjectInfos, tribeID)
                    local skill = mjrequire "common/skill"

                    if planHelper.completedSkillsByTribeID[tribeID] then
                        if not planHelper.completedSkillsByTribeID[tribeID][skill.types.treeFelling.index] then
                            return false
                        end
                        if not planHelper.completedSkillsByTribeID[tribeID][skill.types.planting.index] then
                            return false
                        end
                        return true
                    end
                end
            }
        }
    }
}