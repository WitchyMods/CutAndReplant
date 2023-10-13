local plan = mjrequire "common/plan"

local shadow = mjrequire "hammerstone/utils/shadow"

local planManager = {}

local serverGOM = nil

function planManager:init(super, serverGOM_, serverWorld_, serverSapien_, serverCraftArea_)
    super(self, serverGOM_, serverWorld_, serverSapien_, serverCraftArea_)

    serverGOM = serverGOM_
end

function planManager:addPlans(super, tribeID, userData)
    if userData.planTypeIndex == plan.types.cutAndReplant.index then
        for _, objectID in ipairs(userData.objectOrVertIDs) do
            local treeObject = serverGOM:getObjectWithID(objectID)

            if treeObject then
                local objectState = treeObject.sharedState
                objectState:set("replantAfterChop", true)
            end
        end

        userData.planTypeIndex = plan.types.chop.index
    end

    super(self, tribeID, userData)
end

function planManager:cancelPlans(super, tribeID, userData)
    if userData and userData.objectOrVertIDs and userData.planTypeIndex == plan.types.chop.index then
        for _, objectID in ipairs(userData.objectOrVertIDs) do 
            local treeObject = serverGOM:getObjectWithID(objectID)

            if treeObject and treeObject.sharedState.replantAfterChop then
                treeObject.sharedState:remove("replantAfterChop")
            end
        end
    end

    super(self, tribeID, userData)
end

function planManager:cancelAllPlansForObject(super, tribeID, objectID)
    local possibleTreeObject = serverGOM:getObjectWithID(objectID)

    if possibleTreeObject and possibleTreeObject.sharedState.replantAfterChop then
        possibleTreeObject.sharedState:remove("replantAfterChop")
    end

    super(self, tribeID, objectID)
end

return shadow:shadow(planManager)