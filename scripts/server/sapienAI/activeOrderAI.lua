local plan = mjrequire "common/plan"
local planManager = mjrequire "server/planManager"
local action = mjrequire "common/action"
local constructable = mjrequire "common/constructable"
local gameObject = mjrequire "common/gameObject"

local shadow = mjrequire "hammerstone/utils/shadow"

local activeOrderAI = {}

function activeOrderAI:init(super, ...)
    local chopSuper = self.updateInfos[action.types.chop.index].completionFunction
    self.updateInfos[action.types.chop.index].completionFunction = function(allowCompletion, sapien, orderObject, orderState, actionState, constructableType, requiredLearnComplete)
        activeOrderAI:completeChopAction(chopSuper, allowCompletion, sapien, orderObject, orderState, actionState, constructableType, requiredLearnComplete)
    end
    
    super(self, ...)
end

function activeOrderAI:completeChopAction(super, allowCompletion, sapien, orderObject, orderState, actionState, constructableType, requiredLearnComplete)
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
        
                planManager:addPlans(sapien.sharedState.tribeID, userData)
                
                return
            end
        end
    end

    super(allowCompletion, sapien, orderObject, orderState, actionState, constructableType, requiredLearnComplete)
end

return shadow:shadow(activeOrderAI)
