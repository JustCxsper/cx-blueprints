local metadataKey = Config.MetadataKey or 'blueprints'

local function getPlayer(src)
    return exports.qbx_core:GetPlayer(src)
end

local function ensureBlueprintTable(player)
    local meta = player.PlayerData.metadata or {}
    local bp = meta[metadataKey]

    if type(bp) ~= 'table' then
        bp = {}
        player.Functions.SetMetaData(metadataKey, bp)
    end

    return bp
end

local function getBlueprintItemName(blueprintName)
    -- bp_weapon_pistol, bp_lockpick_advanced, etc.
    return ('bp_%s'):format(blueprintName)
end

local function getBlueprintItemCount(src, blueprintName)
    local itemName = getBlueprintItemName(blueprintName)
    local item = exports.ox_inventory:GetItem(src, itemName, nil, true)

    if not item then return 0 end

    if type(item) == 'table' then
        return item.count or item.amount or item.quantity or 0
    end

    return item or 0
end

local function buildBlueprintSnapshot(src, player)
    local learned = ensureBlueprintTable(player)
    local list = {}

    for _, bp in ipairs(Config.Blueprints) do
        local isLearned = learned[bp.name] == true
        local canLearn = false
        local missing = nil

        if not isLearned then
            local count = getBlueprintItemCount(src, bp.name)
            if count > 0 then
                canLearn = true
            else
                canLearn = false
                local pretty = Config.RequireLabels[bp.name] or getBlueprintItemName(bp.name)
                missing = ('Requires: %s'):format(pretty)
            end
        end

        list[#list+1] = {
            name        = bp.name,
            label       = bp.label,
            category    = bp.category,
            tier        = bp.tier,
            rarity      = bp.rarity or 'common',
            description = bp.description,
            learned     = isLearned,
            canLearn    = canLearn,
            missing     = missing,
        }
    end

    return list
end

-- shared helper for exports
local function hasBlueprintForItem(player, itemName)
    if not itemName then return false end
    local learned = ensureBlueprintTable(player)
    return learned[itemName] == true
end

-- callback for opening tablet
lib.callback.register('cx-blueprints:getBlueprints', function(src)
    local player = getPlayer(src)
    if not player then return {} end

    return buildBlueprintSnapshot(src, player)
end)

-- learn via bp_* item
RegisterNetEvent('cx-blueprints:learnBlueprint', function(blueprintName)
    local src = source
    if type(blueprintName) ~= 'string' then return end

    local player = getPlayer(src)
    if not player then return end

    local learned = ensureBlueprintTable(player)

    -- already learned
    if learned[blueprintName] then
        return
    end

    local count = getBlueprintItemCount(src, blueprintName)
    local itemName = getBlueprintItemName(blueprintName)

    if count < 1 then
        local snapshot = buildBlueprintSnapshot(src, player)
        TriggerClientEvent('cx-blueprints:updateBlueprints', src, snapshot)

        TriggerClientEvent('cx-blueprints:notify', src, {
            title = 'Blueprint',
            description = ('You are missing %s.'):format(itemName),
            type = 'error'
        })
        return
    end

    -- find label for UI
    local prettyLabel = blueprintName
    for _, bp in ipairs(Config.Blueprints) do
        if bp.name == blueprintName then
            prettyLabel = bp.label or prettyLabel
            break
        end
    end

    -- consume 1 blueprint item
    exports.ox_inventory:RemoveItem(src, itemName, 1)

    -- mark as learned
    learned[blueprintName] = true
    player.Functions.SetMetaData(metadataKey, learned)

    local snapshot = buildBlueprintSnapshot(src, player)
    TriggerClientEvent('cx-blueprints:updateBlueprints', src, snapshot)

    -- NUI toast
    TriggerClientEvent('cx-blueprints:nuiLearned', src, prettyLabel)

    -- normal notify
    TriggerClientEvent('cx-blueprints:notify', src, {
        title = 'Blueprint Learned',
        description = ('You learned how to craft %s.'):format(prettyLabel),
        type = 'success'
    })
end)

----------------------------------------------------------------------
-- EXPORTS
----------------------------------------------------------------------

--- Check if a player has learned the blueprint for an item.
--- @param src number      -- player server id
--- @param itemName string -- crafted item name, e.g. "weapon_pistol"
--- @return boolean
exports('HasBlueprint', function(src, itemName)
    local player = getPlayer(src)
    if not player then return false end
    return hasBlueprintForItem(player, itemName)
end)

--- Convenience export for recipes that use "item" or "name" field.
--- @param src number
--- @param recipe table    -- expects recipe.item or recipe.name
--- @return boolean
exports('HasBlueprintForRecipe', function(src, recipe)
    if type(recipe) ~= 'table' then return false end
    local itemName = recipe.item or recipe.name
    if not itemName then return false end

    local player = getPlayer(src)
    if not player then return false end

    return hasBlueprintForItem(player, itemName)
end)
