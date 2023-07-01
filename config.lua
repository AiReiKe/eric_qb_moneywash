Config = {}

Config.Discord = {  -- Discord 紀錄
    enable = true,  -- 是否啟用
    webhook = '',   -- WebHook
    imgURL = '',    -- 伺服器頭像
}

Config.UseOxInventory = false   --使用 ox_inventory
Config.BlackMoneyItem = 'black_money'  --黑錢物品
Config.UseTarget      = GetConvar('UseTarget', 'false') == 'true'

Config.Zone = {
    {
        pos = vec3(835.49, -1211.52, 28.01),   --位置
        rate = 1,       --黑錢To白錢x多少
        jobs = 'admin',  --職業, 無須限制填nil
        blip = true,    --是否要在地圖放圖標
        name = '測試點一',   --顯示名稱
        dispatchRate = 20,   --觸發警察通報機率(須自己寫入警察通報內容)
        ped = {
            pos = vec4(835.49, -1211.44, 27.01, 279.43),
            model = 's_m_m_movprem_01',
        },
        target = {  -- 眼睛系統設置
            type = 'ped',    --'ped' or 'zone'
        }
    },
    {
        pos = vec3(1136.35, -992.12, 46.11),
        rate = 0.8,
        jobs = {
            ['gang'] = 3,   --[職位]=最低可用位階
            ['gang2'] = 3,
            ['gang3'] = 3
        },
        name = '測試點二',
        blip = false,
        target = {
            type = 'zone',    --'ped' or 'zone'
            zone = {
                pos = vec4(1135.93, -992.15, 46.11, 5),
                width = 1.2,
                length = 0.35,
            }
        }
    },
}

Config.PriceTime = 40   --基底讀條為8秒, 每洗1000黑錢, 讀條增加多少毫秒

if not IsDuplicityVersion() then
    function TextUI(msg) -- 顯示自己常用的TextUI, 例: qb、ox、okok
        exports['qb-core']:DrawText(msg)
        --lib.showTextUI(msg)
        --exports['okokTextUI']:Open(msg, 'lightblue', 'right')
    end
    
    function HideUI()   --隱藏TextUI
        exports['qb-core']:HideText()
        --lib.hideTextUI()
        --exports['okokTextUI']:Close()
    end
    
    function ProgressBar(duration, label, anim, scenario, onFinish, onCancel)   -- 自己常用的讀條, 例: qb、ox、mythic
        exports['progressbar']:Progress({   -- QBCore
            name = 'eric_moneywash',
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = true,
                disableCombat = true,
            },
            animation = {
                task = scenario or nil,
                animDict = anim and anim.dict,
                anim = anim and anim.clip
            },
            prop = {},
            propTwo = {},
        }, function(cancelled)
            if not cancelled then
                if onFinish then
                    onFinish()
                end
            else
                if onCancel then
                    onCancel()
                end
            end
        end)
        --[[if lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                move = true,
                combat = true,
                mouse = true
            },
            anim = {
                scenario = scenario or nil,
                dict = anim and anim.dict,
                clip = anim and anim.clip
            }
        }) then
            if onFinish then
                onFinish()
            end
        else
            if onCancel then
                onCancel()
            end
        end]]
        --[[TriggerEvent("mythic_progbar:client:progress", {
            name = "eric_moneywash",
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = true,
                disableCombat = true,
            },
            animation = {
                animDict = anim and anim.dict,
                anim = anim and anim.clip,
                task = scenario or nil
            }
        }, function(status)
            if not status then
                if onFinish then
                    onFinish()
                end
            else
                if onCancel then
                    onCancel()
                end
            end
        end)]]
    end

    function CancelProgress(onCancel)   -- 取消讀條
        --lib.cancelProgress()
        --TriggerEvent("mythic_progbar:client:cancel")
    end

    RegisterNetEvent("eric_moneywash:notify")   --自己常用的Notify, 例: esx、ox、okokNotify、mythic
    AddEventHandler("eric_moneywash:notify", function(msg, type)
        TriggerEvent('QBCore:Notify', msg, type or 'inform')
        --TriggerEvent("ox_lib:notify", {description = msg, type = type})
        --exports.okokNotify:Alert("黑錢", msg, 3000, type, true)
        --exports['mythic_notify']:SendAlert(type, msg, 5000)
    end)

    RegisterNetEvent("eric_moneywash:dispatch")
    AddEventHandler("eric_moneywash:dispatch", function(coords)
    end)
end
