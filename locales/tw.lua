local Translations = {
    ['washing_count'] = '黑錢金額',
    ['washing_money'] = '洗錢中...',
    ['wash_fail']     = '洗錢失敗',
    ['no_enough_black'] = '無足夠黑錢',
    ['count_empty']     = '請輸入金額',
    ['press_to_open']   = '[E] 洗錢點 - %{position}',
    ['moneywash']       = '洗錢 - %{position}',
    -- server
    ['washed_money'] = '清洗黑錢 $%{black}, 獲得 %{white}',
    ['cheating'] = '疑似使用外掛```\nSteam名字: %{name}\n角色姓名 %{charName}\nSteam: %{steamID}\n時間: %{time}```<@%{discord}>',
    ['mechanism'] = '嘗試使用機制```\nSteam名字: %{name}\n角色姓名 %{charName}\nSteam: %{steamID}\n時間: %{time}```<@%{discord}>',
    ['defaultLog'] = '玩家: %{name} [%{steamID}]\n角色姓名: %{charName}\n黑錢: %{black}\n現金: %{white}\n地點 %{position}\n時間: %{time}'
}

if GetConvar('qb_locale', 'en') == 'tw' then
    Lang = Lang or Locale:new({
        phrases = Translations,
        warnOnMissing = true
    })
end