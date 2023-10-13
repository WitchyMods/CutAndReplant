local typeMaps = mjrequire "common/typeMaps"

local shadow = mjrequire "hammerstone/utils/shadow"

local plan = {}

function plan:postload(base)
    local cutAndReplantPlan = {
        key = "cutAndReplant",
        name = "Cut And Replant",
        inProgress = "Cutting and replanting tree",
        icon = "icon_cutreplant",
        skipFinalReachableCollisionPathCheck = true,
        requiresLight = true,
        checkCanCompleteForRadialUI = true,
        priorityOffset = base.mineChopPriorityOffset,
    }

    if not base.types["cutAndReplant"] then
        typeMaps:insert("plan", base.types, cutAndReplantPlan)
    end
end

return shadow:shadow(plan)