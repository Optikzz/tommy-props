QBCore = exports['qb-core']:GetCoreObject()

local attachPropList = {
    ["medicalBag"] = {
        ["model"] = "xm_prop_x17_bag_med_01a", ["bone"] = 28422, ["x"] = 0.37, ["y"] = 0.0, ["z"] = 0.0, ["xR"] = -50.0, ["yR"] = -90.0, ["zR"] = 0.0, ["anim"] = 'pick'
    },
}

local attachedPropThing = 0
local BigBone = 0
local SomethingX = 0.0
local SomethingY = 0.0
local SomethingZ = 0.0
local SomethingxR = 0.0
local SomethingxY = 0.0
local SomethingzR = 0.0
local holdingPackage = false
local toggleShit = false
local droppedmedkit = nil

RegisterNetEvent('attach:medicalBag')
AddEventHandler('attach:medicalBag', function()
    TriggerEvent("attachItem", "medicalBag")
end)

RegisterNetEvent('attachItem')
AddEventHandler('attachItem', function(item)
    TriggerEvent("attachProp", attachPropList[item]["model"], attachPropList[item]["bone"], attachPropList[item]["x"], attachPropList[item]["y"], attachPropList[item]["z"], attachPropList[item]["xR"], attachPropList[item]["yR"], attachPropList[item]["zR"])
end)

RegisterNetEvent('attachProp')
AddEventHandler('attachProp', function(attachModelSent, boneNumberSent, x, y, z, xR, yR, zR)

    if attachedPropThing ~= 0 then
        removeattachedPropThing()
        return
    end

    holdingPackage = true
    toggleShit = true
    attachModel = GetHashKey(attachModelSent)
    boneNumber = boneNumberSent
    SetCurrentPedWeapon(PlayerPedId(), 0xA2719263)
    local bone = GetPedBoneIndex(PlayerPedId(), boneNumberSent)
    RequestModel(attachModel)
    while not HasModelLoaded(attachModel) do
        Citizen.Wait(100)
    end
    attachedPropThing = CreateObject(attachModel, 1.0, 1.0, 1.0, 1, 1, 0)
    GlobalObject(attachedPropThing)

    AttachEntityToEntity(attachedPropThing, PlayerPedId(), bone, x, y, z, xR, yR, zR, 1, 1, 0, 0, 2, 1)

    BigBone = bone
    SomethingX = x
    SomethingY = y
    SomethingZ = z
    SomethingxR = xR
    SomethingxY = yR
    SomethingzR = zR

end)

function removeattachedPropThing()
    if DoesEntityExist(attachedPropThing) then
        DeleteEntity(attachedPropThing)
        attachedPropThing = 0
    end
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
end

function randPickupAnim()
    loadAnimDict('random@domestic')
    TaskPlayAnim(PlayerPedId(), 'random@domestic', 'pickup_low', 5.0, 1.0, 1.0, 48, 0.0, 0, 0, 0)
    Wait(1000)
end

function holdAnim()
    loadAnimDict("anim@heists@box_carry@")
    TaskPlayAnim((PlayerPedId()), "anim@heists@box_carry@", "idle", 4.0, 1.0, -1, 49, 0, 0, 0, 0)
end

function GlobalObject(object)
    NetworkRegisterEntityAsNetworked(object)
    local netid = ObjToNet(object)
    SetNetworkIdExistsOnAllMachines(netid, true)
    NetworkSetNetworkIdDynamic(netid, true)
    SetNetworkIdCanMigrate(netid, false)
    for i = 1, 32 do
        SetNetworkIdSyncToPlayer(netid, i, true)
    end
    print("Net: " .. netid)
end

RegisterNetEvent("tommy:dropmedkit")
AddEventHandler("tommy:dropmedkit", function()
    if (toggleShit == true) then
        if (attachedPropThing ~= nil) then
            randPickupAnim()
            DeleteEntity(attachedPropThing)
            attachedPropThing = nil
            x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
            droppedmedkit = CreateObject("xm_prop_x17_bag_med_01a", x, y + 0.5, z, true, true, true)
            TriggerServerEvent("tommy:takemedkit")
        end
        PlaceObjectOnGroundProperly(droppedmedkit)
    end
end)

RegisterNetEvent("tommy:pickupmedkit")
AddEventHandler("tommy:pickupmedkit", function()
    if (droppedmedkit ~= nil) and (attachedPropThing == nil) then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local object = droppedmedkit
        local objcoords = GetEntityCoords(object)
        local dist = #(pos - objcoords)
        if dist < 2 then
            randPickupAnim()
            DeleteEntity(droppedmedkit)
            droppedmedkit = nil
            toggleShit = not toggleShit
            TriggerServerEvent("tommy:givebackmedkit")
            attachedPropThing = 0
            TriggerEvent("attachItem", "medicalBag")
        else
            QBCore.Functions.Notify("Wheres the bag?", "error")
        end
    end
end)

RegisterCommand("pickupmedkit", function(source, args, raw)
    TriggerEvent('tommy:pickupmedkit')
end, false)

RegisterCommand("dropmedkit", function(source, args, raw)
    TriggerEvent('tommy:dropmedkit')
end, false)