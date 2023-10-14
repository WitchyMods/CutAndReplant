local flora = mjrequire "common/flora"
local skill = mjrequire "common/skill"
local tool = mjrequire "common/tool"
local plan = mjrequire "common/plan"
local locale = mjrequire "common/locale"
local research = mjrequire "common/research"

local shadow = mjrequire "hammerstone/utils/shadow"

local planHelper = {}

local completedSkillsByTribeID = {}
local discoveriesByTribeID = {}

function planHelper:updateCompletedSkillsForDiscoveriesChange(super, tribeID)
    super(self, tribeID)

    for researchTypeIndex,discoveryInfo in pairs(discoveriesByTribeID[tribeID]) do
        if discoveryInfo.complete then
            local researchType = research.types[researchTypeIndex]
            if researchType then
                local skillTypeIndex = researchType.skillTypeIndex
                if skillTypeIndex then
                    completedSkillsByTribeID[tribeID][skillTypeIndex] = true
                end
            end
        end
    end
end

function planHelper:setDiscoveriesForTribeID(super, tribeID, discoveries, craftableDiscoveries)
    discoveriesByTribeID[tribeID] = discoveries
    completedSkillsByTribeID[tribeID] = {}

    super(self, tribeID, discoveries, craftableDiscoveries)
end

function planHelper:availablePlansForFloraObjects(super, objectInfos, tribeID)
    local plans = super(self, objectInfos, tribeID)

    for i = #plans, 1, -1 do
        if plans[i].planTypeIndex == plan.types.chopAndReplant.index then
            table.remove(plans, i)
        end
    end

    local hasChopDiscovery = false
    local hasPlantDiscovery = false

    if completedSkillsByTribeID[tribeID] then
        if completedSkillsByTribeID[tribeID][skill.types.treeFelling.index] then
            hasChopDiscovery = true
        end
        if completedSkillsByTribeID[tribeID][skill.types.planting.index] then
            hasPlantDiscovery = true
        end
    end

    if hasChopDiscovery and hasPlantDiscovery and flora:requiresAxeToChop(objectInfos[1]) then
        local queuedPlanInfos = self:getQueuedPlanInfos(objectInfos, tribeID, false)
        local availablePlanCounts = {}

        local chopReplantPlanInfo = {
            planTypeIndex = plan.types.chopAndReplant.index;
            requirements = {
                toolTypeIndex = tool.types.treeChop.index,
                skill = skill.types.treeFelling.index,
            },
        }

        if queuedPlanInfos and next(queuedPlanInfos) then
            availablePlanCounts[self:getPlanHash(chopReplantPlanInfo)] = 0
            chopReplantPlanInfo.unavailableReasonText = locale:get("ui_plan_unavailable_stopOrders")
        else
            availablePlanCounts[self:getPlanHash(chopReplantPlanInfo)] = #objectInfos
        end

        self:addPlanExtraInfo(chopReplantPlanInfo, queuedPlanInfos, availablePlanCounts)
        table.insert(plans, chopReplantPlanInfo)

        self:addCancelPlansForAnyMissingQueuedPlans(objectInfos, tribeID, queuedPlanInfos, {chopReplantPlanInfo})
    end

    return plans
end

return shadow:shadow(planHelper)