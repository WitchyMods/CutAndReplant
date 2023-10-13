local plan = mjrequire "common/plan"
local planManager = mjrequire "server/planManager"
local action = mjrequire "common/action"

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
    if allowCompletion and orderObject.sharedState.replantAfterChop then
        local objectState = orderObject.sharedState
        local userData = {
            noBuildOrder = false,
            planTypeIndex = plan.types.plant.index,
            pos = orderObject.pos,
            rotation = orderObject.rotation,
            constructableTypeIndex = objectState.constructionConstructableTypeIndex,
            attachedToTerrain = true
        }

        super(allowCompletion, sapien, orderObject, orderState, actionState, constructableType, requiredLearnComplete)

        planManager:addPlans(sapien.sharedState.tribeID, userData)
    else
        super(allowCompletion, sapien, orderObject, orderState, actionState, constructableType, requiredLearnComplete)
    end

end

return shadow:shadow(activeOrderAI)
