local typeMaps = mjrequire "common/typeMaps"

local shadow = mjrequire "hammerstone/utils/shadow"

local plan = {}

function plan:postload(base)
    local chopAndReplantPlan = {
        key = "chopAndReplant",
        name = "Chop and replant tree",
        inProgress = "Chopping and replanting tree",
        icon = "icon_chopReplant",
        skipFinalReachableCollisionPathCheck = true,
        requiresLight = true,
        checkCanCompleteForRadialUI = true,
        priorityOffset = base.mineChopPriorityOffset,
    }

    if not base.types["chopAndReplant"] then
        typeMaps:insert("plan", base.types, chopAndReplantPlan)
    end
end

return shadow:shadow(plan)