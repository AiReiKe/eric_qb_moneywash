QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Server:UpdateObject', function()
	if source ~= '' then return false end
	QBCore = exports['qb-core']:GetCoreObject()
end)

local serverID = nil

local function discordLogs(msg, color)
    if Config.Discord.enable then
        PerformHttpRequest(Config.Discord.webhook, function(err, Content, Head) end, 'POST', json.encode({username = "Eric Money Wash", embeds = {
            {
                ["color"] = color,
                ["title"] = "**Eric Money Wash**",
                ["description"] = msg,
                ["footer"] = {
                    ["text"] = "",
                },
            }
        }, avatar_url = Config.Discord.imgURL}), {['Content-Type'] = 'application/json'})
    end
end

RegisterServerEvent("eric_moneywash:WashMoney")
AddEventHandler("eric_moneywash:WashMoney", function(count, zone, cbID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if serverID and cbID == serverID then
        if (Config.UseOxInventory and Player.Functions.GetItemByName(Config.BlackMoneyItem).count or Player.Functions.GetItemByName(Config.BlackMoneyItem).amount) >= count then
            Player.Functions.RemoveItem('black_money', count)
            Player.Functions.AddMoney('cash', math.ceil(count * Config.Zone[zone].rate))
            TriggerClientEvent("eric_moneywash:notify", src, Lang:t("washed_money", {black = count, white = math.ceil(count * Config.Zone[zone].rate)}), 'success')
            discordLogs(Lang:t("defaultLog", {name = GetPlayerName(src), steamID = GetPlayerIdentifier(src), charName = Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname, black = count, white = math.ceil(count * Config.Zone[zone].rate), position = Config.Zone[zone].name, time = os.date("%Y/%m/%d %X")}), 155400)
        else
            TriggerClientEvent("eric_moneywash:notify", src, Lang:t('no_enough_black'), 'error')
            local steam, discord = nil, nil
            for k, v in pairs(GetPlayerIdentifiers(src)) do
                if string.sub(v, 1, string.len('steam:')) == 'steam:' then
                    steam = string.sub(v, string.len('steam:') + 1, -1)
                elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
                    discord = string.sub(v, string.len('discord:') + 1, -1)
                end
            end
            discordLogs(Lang:t('mechanism', {name = GetPlayerName(src), charName = Player and Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname or "N/A", steamID = steam or "N/A", time = os.date("%Y/%m/%d %X"), discord = discord or "N/A"}), 16765702)
        end
    else
        local steam, discord = nil, nil
        for k, v in pairs(GetPlayerIdentifiers(src)) do
            if string.sub(v, 1, string.len('steam:')) == 'steam:' then
                steam = string.sub(v, string.len('steam:') + 1, -1)
            elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
                discord = string.sub(v, string.len('discord:') + 1, -1)
            end
        end
        discordLogs(Lang:t('cheating', {name = GetPlayerName(src), charName = Player and Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname or "N/A", steamID = steam or "N/A", time = os.date("%Y/%m/%d %X"), discord = discord or "N/A"}), 16711680)
        print(string.format("%s[%s] tried to cheating", GetPlayerName(src), ("steam:%s"):format(steam) or "N/A"))
    end
end)

QBCore.Functions.CreateCallback("eric_moneywash:haveEnoughBlack", function(source, cb, count)
    local Player = QBCore.Functions.GetPlayer(source)

    if Config.UseOxInventory then
        if Player.Functions.GetItemByName(Config.BlackMoneyItem).count >= count then
            cb(true)
        else
            cb(false)
        end
    else
        if Player.Functions.GetItemByName(Config.BlackMoneyItem).amount >= count then
            cb(true)
        else
            cb(false)
        end
    end
end)

QBCore.Functions.CreateCallback("eric_moneywash:getServerValue", function(source, cb)
    cb(serverID)
end)

Citizen.CreateThread(function()
    while true do
        serverID = math.random(1000, 9999)
        TriggerClientEvent("eric_moneywash:updateValue", -1, serverID)
        Citizen.Wait(15*60*1000)
    end
end)

print("This script is a free script created by AiReiKe")