local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("gb-chopshop:spawnChopVehicle")
AddEventHandler("gb-chopshop:spawnChopVehicle", function(vehicleModel, coords)
    local src = source
    TriggerClientEvent("gb-chopshop:spawnVehicleClient", src, vehicleModel, coords)
end)

RegisterNetEvent("gb-chopshop:givePartReward")
AddEventHandler("gb-chopshop:givePartReward", function(bone, vehicleModel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local partData = Config.ChopBones[bone]
    if not partData then return end

    if type(partData.reward) == "table" then
        for i, item in ipairs(partData.reward) do
            local amount = math.random(partData.min[i], partData.max[i])
            Player.Functions.AddItem(item, amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
            TriggerClientEvent("QBCore:Notify", src, "You received " .. amount .. "x " .. item, "success")
        end
    else
        local amount = math.random(partData.min, partData.max)
        Player.Functions.AddItem(partData.reward, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[partData.reward], "add")
        TriggerClientEvent("QBCore:Notify", src, "You received " .. amount .. "x " .. partData.reward, "success")
    end
end)

RegisterNetEvent("gb-chopshop:giveFinalReward")
AddEventHandler("gb-chopshop:giveFinalReward", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local reward = math.random(Config.FinalizeChopReward.min, Config.FinalizeChopReward.max)
        Player.Functions.AddItem(Config.FinalizeChopReward.item, reward)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.FinalizeChopReward.item], "add")
        TriggerClientEvent("QBCore:Notify", src, "Chopping completed! You received $" .. reward .. " as a cash item", "success")
    end
end)
