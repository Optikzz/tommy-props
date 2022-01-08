QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("medbag", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    TriggerClientEvent('attach:medicalBag', src)
end)

RegisterNetEvent("tommy:takemedkit", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem("medbag", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["medbag"], "remove")
end)

RegisterNetEvent("tommy:givebackmedkit", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem("medbag", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["medbag"], "add")
end)