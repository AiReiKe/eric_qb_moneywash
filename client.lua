local NPCs = {}

QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('QBCore:Client:UpdateObject', function()
	QBCore = exports['qb-core']:GetCoreObject()
end)

RegisterNetEvent("QBCore:Player:SetPlayerData")
AddEventHandler("QBCore:Player:SetPlayerData", function(data)
    PlayerData = data
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload")
AddEventHandler("QBCore:Client:OnPlayerUnload", function()
    PlayerData = nil
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        if Config.UseTarget then
            for key, value in pairs(Config.Zone) do
                if value.target.type == 'zone' then
                    exports['qb-target']:RemoveZone('moneywash_'..key)
                end
            end
        end
        for a, b in pairs(NPCs) do
            if Config.UseTarget and Config.Zone[a].target.type == 'ped' then
                exports['qb-target']:RemoveTargetEntity(b, Lang:t('moneywash', {position = Config.Zone[a].name}))
            end
            DeleteEntity(b)
        end
    end
end)

Citizen.CreateThread(function()
    if QBCore.Functions.GetPlayerData() then
        PlayerData = QBCore.Functions.GetPlayerData()
    end
end)

local showText, washing = false, false
local eventID = nil

local function IsZoneJobs(zone)
    if type(Config.Zone[zone].jobs) == 'string' then
        if Config.Zone[zone].jobs == PlayerData.job.name then
            return true
        end
    elseif type(Config.Zone[zone].jobs) == 'table' then
        for k, v in pairs(Config.Zone[zone].jobs) do
            if k == PlayerData.job.name and PlayerData.job.grade.level >= v and PlayerData.job.onduty then
                return true
            end
        end
    end
    return false
end

local function WashingMoney(zone)
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        while washing do
            if Vdist(GetEntityCoords(playerPed), Config.Zone[zone].pos) > 1.7 then
                CancelProgress(function()
                    washing = false
                end)
            end
            Citizen.Wait(0)
        end
    end)
end

local WashMoney = function(zone)
    washing = true
    local data = exports['qb-input']:ShowInput({
        header = Lang:t("washing_count"),
        inputs = {
            {
                text = Lang:t("washing_count"), -- text you want to be displayed as a place holder
                name = "washing_count", -- name of the input should be unique otherwise it might override
                type = "number", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
            },
        }
    })

    if data then
        if data["washing_count"] and tonumber(data["washing_count"]) > 0 then
            QBCore.Functions.TriggerCallback("eric_moneywash:haveEnoughBlack", function(have)
                if have then
                    if math.random(1, 100) <= (Config.Zone[zone].dispatchRate or 0) then
                        TriggerEvent("eric_moneywash:dispatch", Config.Zone[zone].pos)
                    end
                    ProgressBar(8000 + math.ceil(tonumber(data["washing_count"])/1000*Config.PriceTime), Lang:t("washing_money"), {dict = 'amb@prop_human_bum_bin@idle_a', clip = 'idle_a'}, nil,
                    function()
                        while not eventID do
                            Wait(1)
                        end
                        TriggerServerEvent("eric_moneywash:WashMoney", tonumber(data["washing_count"]), zone, eventID)
                    end, function()
                        TriggerEvent("eric_moneywash:notify", Lang:t('wash_fail'), "error")
                    end)
                    
                else
                    TriggerEvent("eric_moneywash:notify", Lang:t('no_enough_black'), "error")
                end
            end, tonumber(data["washing_count"]))
        else
            TriggerEvent("eric_moneywash:notify", Lang:t('count_empty'), "error")
        end
    end
    washing = false
end

RegisterNetEvent("eric_moneywash:updateValue")
AddEventHandler("eric_moneywash:updateValue", function(value)
    eventID = value
end)

Citizen.CreateThread(function()
    QBCore.Functions.TriggerCallback("eric_moneywash:getServerValue", function(value)
        eventID = value
        print('MoneyWash created by AiReiKe')
    end)
    while true do
        local inZone, inTextZone = false, false
        local pedCoords = GetEntityCoords(PlayerPedId())
        for i = 1, #Config.Zone, 1 do
            local dist = Vdist(pedCoords, Config.Zone[i].pos)
            if Config.Zone[i].ped and Config.Zone[i].ped.pos then
                if dist <= 100 then
                    if not NPCs[i] or not DoesEntityExist(NPCs[i]) then
                        RequestModel(Config.Zone[i].ped.model or 's_m_m_fiboffice_01')

						while not HasModelLoaded(Config.Zone[i].ped.model or 's_m_m_fiboffice_01') do
							Wait(0)
						end

						NPCs[i] = CreatePed(0, Config.Zone[i].ped.model or 's_m_m_fiboffice_01', Config.Zone[i].ped.pos.xyz, Config.Zone[i].ped.pos.w, false, true)
            
                        SetPedFleeAttributes(NPCs[i], 2)
                        SetBlockingOfNonTemporaryEvents(NPCs[i], true)
                        SetPedCanRagdollFromPlayerImpact(NPCs[i], false)
                        SetPedDiesWhenInjured(NPCs[i], false)
                        FreezeEntityPosition(NPCs[i], true)
                        SetEntityInvincible(NPCs[i], true)
                        SetPedCanPlayAmbientAnims(NPCs[i], false)
						SetModelAsNoLongerNeeded(Config.Zone[i].ped.model or 's_m_m_fiboffice_01')

                        if Config.UseTarget and Config.Zone[i].target.type == 'ped' then
                            exports['qb-target']:AddTargetEntity(NPCs[i], {
                                options = {
                                    {
                                        icon = 'fas fa-sack-dollar',
                                        label = Lang:t('moneywash', {position = Config.Zone[i].name}),
                                        job = Config.Zone[i].jobs or nil,
                                        canInteract = function()
                                            return not washing
                                        end,
                                        action = function()
                                            WashMoney(i)
                                        end
                                    }
                                },
                                distance = 1.5
                            })
                        end
                    end
                else
                    if NPCs[i] and DoesEntityExist(NPCs[i]) then
                        if Config.UseTarget and Config.Zone[i].target.type == 'ped' then
                            exports['qb-target']:RemoveTargetEntity(NPCs[i], Lang:t('moneywash', {position = Config.Zone[i].name}))
                        end
                        DeleteEntity(NPCs[i])
                        NPCs[i] = nil
                    end
                end
            end
            if dist <= 25 and not Config.UseTarget then
                if not Config.Zone[i].jobs or IsZoneJobs(i) then
                    inZone = true
                    DrawMarker(1, Config.Zone[i].pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 0, 100, false, true, 2, true, false, false, false)
                    if dist <= 1.5 and not washing then
                        inTextZone = true
                        if not showText then
                            showText = true
                            TextUI(Lang:t("press_to_open", {position = Config.Zone[i].name}))
                        end

                        if IsControlJustReleased(0, 38) then
                            WashMoney(i)
                        end
                    end
                end
            end
        end

        if not inTextZone and showText then
            showText = false
            HideUI()
        end

        if not inZone then
            Citizen.Wait(500)
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    for key, value in pairs(Config.Zone) do
        if value.blip then
            local blip = AddBlipForCoord(value.pos)
            SetBlipSprite(blip, 500)
            SetBlipColour(blip, 1)
            SetBlipScale(blip, 0.8)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Lang:t('moneywash', {position = value.name}))
            EndTextCommandSetBlipName(blip)
        end
    end
end)

if Config.UseTarget then
    Citizen.CreateThread(function()
        for key, value in pairs(Config.Zone) do
            if value.target.type == 'zone' then
                exports['qb-target']:AddBoxZone('moneywash_'..key, value.target.zone.pos.xyz, value.target.zone.length, value.target.zone.width, {
                    name = 'moneywash_'..key,
                    heading = value.target.zone.pos.w,
                    debugPoly = false,
                    minZ = value.target.zone.pos.z - 1,
                    maxZ = value.target.zone.pos.z + 1,
                }, {
                    options = {
                        {
                            icon = 'fas fa-sack-dollar',
                            label = Lang:t('moneywash', {position = value.name}),
                            job = value.jobs or nil,
                            canInteract = function()
                                return not washing
                            end,
                            action = function()
                                WashMoney(key)
                            end
                        }
                    },
                    distance = 1.5
                })
            end
        end
    end)
end