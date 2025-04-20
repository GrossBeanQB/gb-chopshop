local QBCore = exports['qb-core']:GetCoreObject()
local isChopping = false
local currentVehicle = nil
local choppedParts = {} -- Tracks chopped parts

-- Global variable for the drill prop
local drillProp = nil

-- Global mapping for doors and wheels
local doorMapping = { 
    ["door_dside_f"] = 0, 
    ["door_pside_f"] = 1, 
    ["door_dside_r"] = 2, 
    ["door_pside_r"] = 3, 
    ["bonnet"] = 4, 
    ["boot"] = 5 
}
local wheelMapping = { 
    ["wheel_lf"] = 0, 
    ["wheel_rf"] = 1, 
    ["wheel_lr"] = 2, 
    ["wheel_rr"] = 3 
}

local COOLDOWN = 20 * 60 * 1000
local lastChopTime = GetGameTimer() - COOLDOWN

function attachDrillProp()
    local playerPed = PlayerPedId()
    if not drillProp then
        local drillModel = GetHashKey("prop_tool_drill")
        RequestModel(drillModel)
        while not HasModelLoaded(drillModel) do
            Wait(100)
        end
        drillProp = CreateObject(drillModel, 1.0, 1.0, 1.0, true, true, false)
        local boneIndex = GetPedBoneIndex(playerPed, 18905)
        AttachEntityToEntity(
            drillProp,
            playerPed,
            boneIndex,
            0.0, 0.0, 0.0,
            0.0, 0.0, 180.0,
            true, true, false, true, 1, true
        )
    end
end

function removeDrillProp()
    if drillProp then
        DetachEntity(drillProp, true, true)
        DeleteEntity(drillProp)
        drillProp = nil
    end
end

function IsNearChopShop()
    local playerPos = GetEntityCoords(PlayerPedId())
    for _, chopLoc in ipairs(Config.ChopLocations) do
        local chopPos = vector3(chopLoc.x, chopLoc.y, chopLoc.z)
        if #(playerPos - chopPos) < 10.0 then
            return true
        end
    end
    return false
end

function PlayChopAnimation()
    local playerPed = PlayerPedId()
    RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
        Wait(100)
    end
    TaskPlayAnim(playerPed, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 8.0, -8.0, -1, 1, 0, false, false, false)
    attachDrillProp()
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'impactdrill', 0.7)
end

Citizen.CreateThread(function()
    RequestModel(`s_m_y_dealer_01`)
    while not HasModelLoaded(`s_m_y_dealer_01`) do
        Wait(100)
    end

    local npc = CreatePed(4, `s_m_y_dealer_01`, Config.NPCLocation.x, Config.NPCLocation.y, Config.NPCLocation.z - 1.0, Config.NPCLocation.w, false, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    FreezeEntityPosition(npc, true)

    exports['qb-target']:AddTargetEntity(npc, {
        options = {
            {
                type = "client",
                event = "gb-chopshop:requestChopJob",
                icon = "fa-solid fa-car",
                label = "Steal a Vehicle for Chopping"
            }
        },
        distance = 2.5
    })
end)

RegisterNetEvent("gb-chopshop:requestChopJob")
AddEventHandler("gb-chopshop:requestChopJob", function()
    local currentTime = GetGameTimer()
    if currentTime - lastChopTime < COOLDOWN then
        local remaining = math.floor((COOLDOWN - (currentTime - lastChopTime)) / 60000)
        QBCore.Functions.Notify("You must wait " .. remaining .. " more minute(s) before starting another chop job!", "error")
        return
    end

    if not Config.ChopVehicles or #Config.ChopVehicles == 0 then
        QBCore.Functions.Notify("Error: ChopVehicles list is empty!", "error")
        return
    end

    local randomVehicle = Config.ChopVehicles[math.random(#Config.ChopVehicles)]
    local randomLocation = Config.VehicleSpawnLocations[math.random(#Config.VehicleSpawnLocations)]
    TriggerServerEvent("gb-chopshop:spawnChopVehicle", randomVehicle, randomLocation)
end)

RegisterNetEvent("gb-chopshop:spawnVehicleClient")
AddEventHandler("gb-chopshop:spawnVehicleClient", function(vehicleModel, coords)
    local model = GetHashKey(vehicleModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    SetVehicleDoorsLocked(vehicle, 1)
    currentVehicle = vehicle

    QBCore.Functions.Notify("The vehicle has been marked on your map!", "success")
    SetNewWaypoint(coords.x, coords.y)
    TriggerEvent("gb-chopshop:setPlayerVehicle", vehicle)
end)

RegisterNetEvent("gb-chopshop:setPlayerVehicle")
AddEventHandler("gb-chopshop:setPlayerVehicle", function(vehicle)
    Citizen.CreateThread(function()
        while DoesEntityExist(vehicle) do
            Wait(1000)
            if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
                local randomChopLoc = Config.ChopLocations[math.random(#Config.ChopLocations)]
                SetNewWaypoint(randomChopLoc.x, randomChopLoc.y)
                QBCore.Functions.Notify("Take the vehicle to the Chop Shop!", "success")
                Citizen.CreateThread(function()
                    while DoesEntityExist(vehicle) do
                        Wait(1000)
                        if not IsPedInVehicle(PlayerPedId(), vehicle, false) and IsNearChopShop() then
                            exports['qb-target']:AddTargetEntity(vehicle, {
                                options = {
                                    {
                                        type = "client",
                                        event = "gb-chopshop:startChopping",
                                        icon = "fa-solid fa-wrench",
                                        label = "Start Chopping"
                                    }
                                },
                                distance = 2.0
                            })
                            break
                        end
                    end
                end)
                break
            end
        end
    end)
end)

RegisterNetEvent("gb-chopshop:startChopping")
AddEventHandler("gb-chopshop:startChopping", function()
    if not IsNearChopShop() then
        QBCore.Functions.Notify("You must be at the Chop Shop to start chopping!", "error")
        return
    end

    exports['qb-target']:RemoveTargetEntity(currentVehicle, "Start Chopping")
    isChopping = true
    choppedParts = {}

    if currentVehicle and DoesEntityExist(currentVehicle) then
        for i = 0, 5 do
            SetVehicleDoorOpen(currentVehicle, i, false, false)
        end
    end

    for bone, partData in pairs(Config.ChopBones) do
        local boneIndex = GetEntityBoneIndexByName(currentVehicle, bone)
        local isMissing = false

        if boneIndex == -1 then
            isMissing = true
        else
            if doorMapping[bone] then
                if IsVehicleDoorDamaged(currentVehicle, doorMapping[bone]) then
                    isMissing = true
                end
            elseif wheelMapping[bone] then
                if IsVehicleTyreBurst(currentVehicle, wheelMapping[bone], false) then
                    isMissing = true
                end
            end
        end

        if not isMissing then
            local partLabel = partData.label
            exports['qb-target']:AddTargetBone(bone, {
                options = {
                    {
                        type = "client",
                        event = "gb-chopshop:chopPart",
                        icon = "fa-solid fa-scissors",
                        label = "Chop " .. partLabel,
                        bone = bone,
                        entity = currentVehicle
                    }
                },
                distance = 1.5
            })
        else
            choppedParts[bone] = true
        end
    end

    QBCore.Functions.Notify("You started chopping! Walk to the available parts of the vehicle.", "success")
end)

RegisterNetEvent("gb-chopshop:chopPart")
AddEventHandler("gb-chopshop:chopPart", function(data)
    if not isChopping then
        QBCore.Functions.Notify("You need to start chopping first!", "error")
        return
    end

    local vehicle, bone = currentVehicle, data.bone
    if vehicle and bone and not choppedParts[bone] then
        choppedParts[bone] = true
        PlayChopAnimation()
        QBCore.Functions.Progressbar("chop_part", "Chopping " .. Config.ChopBones[bone].label .. "...", 5000, false, true, {}, {}, {}, {}, function()
            ClearPedTasks(PlayerPedId())
            removeDrillProp()
            TriggerServerEvent("gb-chopshop:givePartReward", bone, GetEntityModel(vehicle))
            RemoveVehiclePart(vehicle, bone)
            exports['qb-target']:RemoveTargetBone(bone)
            TriggerEvent("gb-chopshop:checkIfFullyChopped", vehicle)
        end, function()
            ClearPedTasks(PlayerPedId())
            removeDrillProp()
        end)
    else
        QBCore.Functions.Notify("You already chopped this part!", "error")
    end
end)

function RemoveVehiclePart(vehicle, bone)
    if doorMapping[bone] then
        SetVehicleDoorBroken(vehicle, doorMapping[bone], false)
    elseif wheelMapping[bone] then
        BreakOffVehicleWheel(vehicle, wheelMapping[bone], true, false, true, false)
    end
end

RegisterNetEvent("gb-chopshop:checkIfFullyChopped")
AddEventHandler("gb-chopshop:checkIfFullyChopped", function(vehicle)
    local allChopped = true
    for bone, _ in pairs(Config.ChopBones) do
        if doorMapping[bone] then
            if not IsVehicleDoorDamaged(vehicle, doorMapping[bone]) and not choppedParts[bone] then
                allChopped = false
                break
            end
        elseif wheelMapping[bone] then
            if not IsVehicleTyreBurst(vehicle, wheelMapping[bone], false) and not choppedParts[bone] then
                allChopped = false
                break
            end
        else
            if GetEntityBoneIndexByName(vehicle, bone) ~= -1 and not choppedParts[bone] then
                allChopped = false
                break
            end
        end
    end

    if allChopped then
        QBCore.Functions.Notify("All available parts have been chopped! Finalize when ready.", "success")
        exports['qb-target']:AddTargetEntity(vehicle, {
            options = {
                {
                    type = "client",
                    event = "gb-chopshop:finalizeChop",
                    icon = "fa-solid fa-check",
                    label = "Finalize Chopping"
                }
            },
            distance = 2.0
        })
    end
end)

RegisterNetEvent("gb-chopshop:finalizeChop")
AddEventHandler("gb-chopshop:finalizeChop", function()
    exports['qb-target']:RemoveTargetEntity(currentVehicle, "Finalize Chopping")
    PlayChopAnimation()
    QBCore.Functions.Progressbar("finalize_chopping", "Finalizing Chopping...", 3000, false, true, {}, {}, {}, {}, function()
        ClearPedTasks(PlayerPedId())
        removeDrillProp()
        TriggerServerEvent("gb-chopshop:giveFinalReward")
        QBCore.Functions.Notify("Chopping finalized!", "success")
        if currentVehicle and DoesEntityExist(currentVehicle) then
            DeleteVehicle(currentVehicle)
        end
        isChopping = false
        currentVehicle = nil
        choppedParts = {}
        lastChopTime = GetGameTimer()
    end, function()
        ClearPedTasks(PlayerPedId())
        removeDrillProp()
    end)
end)
