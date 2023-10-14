local typeMaps = mjrequire "common/typeMaps"
local action = mjrequire "common/action"

local shadow = mjrequire "hammerstone/utils/shadow"

local actionSequence = {}

function actionSequence:postload(base)
    local chopAndReplantActionSequence = {
        key = "chopAndReplant",
        actions = {
            action.types.moveTo.index,
            action.types.chop.index,
        },
        assignedTriggerIndex = 2,
        snapToOrderObjectIndex = 2,
    }

    if not base.types["chopAndReplant"] then
        typeMaps:insert("actionSequence", base.types, chopAndReplantActionSequence)
    end
end

return shadow:shadow(actionSequence)