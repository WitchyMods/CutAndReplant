local order = mjrequire "common/order"
local plan = mjrequire "common/plan"
local sapienConstants = mjrequire "common/sapienConstants"

local shadow = mjrequire "hammerstone/utils/shadow"

local serverSapienAI = {}

function serverSapienAI:createOrderInfo(super, sapien, orderObject, orderAssignInfo)
    local planTypeIndex = orderAssignInfo.planTypeIndex

    if planTypeIndex == plan.types.chopAndReplant.index then
        local orderInfo = self:createGeneralOrder(sapien, orderAssignInfo, true, order.types.chopAndReplant.index, {
            completionRepeatCount = 2,
        })

        if orderInfo and orderInfo.orderTypeIndex then
            if order.types[orderInfo.orderTypeIndex].disallowsLimitedAbilitySapiens then
                if sapienConstants:getHasLimitedGeneralAbility(sapien.sharedState) then
                    return nil
                end
            end
        end
        
        return orderInfo
    else
        return super(self, sapien, orderObject, orderAssignInfo)
    end
end

return shadow:shadow(serverSapienAI)