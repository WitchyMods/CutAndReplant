local order = mjrequire "common/order"
local actionSequence = mjrequire "common/actionSequence"

local shadow = mjrequire "hammerstone/utils/shadow"

local serverSapien = {}

function serverSapien:actionSequenceTypeIndexForOrder(super, sapien, orderObject, orderState)
    local orderTypeIndex = orderState.orderTypeIndex

    if orderTypeIndex == order.types.chopAndReplant.index then
        return actionSequence.types.chopAndReplant.index
    end

    return super(self, sapien, orderObject, orderState)
end

return shadow:shadow(serverSapien)