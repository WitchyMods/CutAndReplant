local typeMaps = mjrequire "common/typeMaps"

local shadow = mjrequire "hammerstone/utils/shadow"

local order = {}

function order:postload(base)
    local chopAndReplantOrder = {
        key = "chopAndReplant",
        name = "Chop and replant tree",
        inProgressName = "Chopping and replanting tree",
        disallowsLimitedAbilitySapiens = true,
        autoExtend = true,
        icon = "icon_chopReplant",
    }

    if not base.types["chopAndReplant"] then
        typeMaps:insert("order", base.types, chopAndReplantOrder)
    end
end

return shadow:shadow(order)