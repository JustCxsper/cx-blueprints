local Config = Config

local tabletOpen = false

local function setTabletFocus(state)
    tabletOpen = state
    SetNuiFocus(state, state)
    SetNuiFocusKeepInput(false)
end

local function notify(payload)
    if not lib or not lib.notify then return end

    lib.notify({
        title = payload.title or 'Blueprint',
        description = payload.description or '',
        type = payload.type or 'info',
    })
end

local function openTablet()
    if tabletOpen then return end

    local blueprints = lib.callback.await('cx-blueprints:getBlueprints', false)
    if not blueprints then return end

    setTabletFocus(true)

    SendNUIMessage({
        app = 'cx_bptablet',
        action = 'open',
        data = blueprints
    })
end

local function closeTablet()
    if not tabletOpen then return end

    setTabletFocus(false)

    SendNUIMessage({
        app = 'cx_bptablet',
        action = 'close'
    })
end

-- Command to open tablet
RegisterCommand('bp', function()
    openTablet()
end, false)

-- Optional keybind (F6)
if lib and lib.addKeybind then
    lib.addKeybind({
        name = 'cx_blueprints_open',
        description = 'Open Blueprint Tablet',
        defaultKey = 'F6',
        onPressed = function()
            openTablet()
        end
    })
end

-- NUI: learn blueprint
RegisterNUICallback('learnBlueprint', function(data, cb)
    if data and data.name then
        TriggerServerEvent('cx-blueprints:learnBlueprint', data.name)
    end
    cb({})
end)

-- NUI: close
RegisterNUICallback('close', function(_, cb)
    closeTablet()
    cb({})
end)

-- Server: update list
RegisterNetEvent('cx-blueprints:updateBlueprints', function(blueprints)
    if not tabletOpen then return end

    SendNUIMessage({
        app = 'cx_bptablet',
        action = 'update',
        data = blueprints
    })
end)

-- Server: generic notify
RegisterNetEvent('cx-blueprints:notify', function(payload)
    notify(payload or {})
end)

-- Server: learned ping inside tablet
RegisterNetEvent('cx-blueprints:nuiLearned', function(label)
    if not tabletOpen then return end

    SendNUIMessage({
        app = 'cx_bptablet',
        action = 'learned',
        label = label
    })
end)
