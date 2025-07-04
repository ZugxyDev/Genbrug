ESX = nil

ESX = exports["es_extended"]:getSharedObject()

local allowedArea = { x = 994.021972, y = -3109.173584, z = -39.012452, radius = 5.0 }

ESX.RegisterServerCallback('Johnny-genbrug:giveItem', function(source, cb, reward, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerCoords = xPlayer.getCoords(true)
    local distance = #(playerCoords - vector3(allowedArea.x, allowedArea.y, allowedArea.z))

    if xPlayer then 
        xPlayer.addInventoryItem(reward, amount)
        if reward == 'steel' or reward == 'copper' or reward == 'iron' or reward == 'black_money' or reward == 'painting_2' or reward == 'lockpick_advanced' then
            Log(GetPlayerName(source).. ' modtog lige ' ..amount.. ' stk. ' ..reward)
        else
            PerformHttpRequest('https://discord.com/api/webhooks/1346462965984919562/Ynsz0Y5FEjVyHk997BC7z7VdT8uBKDF-yUM05W7phlBiPJDf7Q4zBrOhcvcvCya4cqEG', function(err, text, headers) end, 'POST', json.encode({username = "Genbrug-antimodder.", content = " @everyone **ID - ".. source .. " " .. xPlayer.getName() .. "** [" .. xPlayer.getIdentifier() .. "] | Modtog " .. amount .." x " ..reward.. " som reward fra genbrugsstationen. | " .. os.date("(%d-%m-%Y kl %X)")}), { ['Content-Type'] = 'application/json' })
            exports['at-player']:fg_BanPlayer(source, "Modtog en anden item end fra configgen - Genbrug.", true)
            DropPlayer(source, "Sikkerhedsban - Opret ticket for information.")
            return
        end
        local randomXP = math.random(Config.MinXP, Config.MaxXP)
        MySQL.Async.fetchAll('SELECT * FROM genbrug WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        }, function(result)
            if #result > 0 then
                local newXP = result[1].xp + randomXP
                local newLevel = result[1].level
                local newBoost = result[1].boost
                if newXP >= 100 then
                    newLevel = newLevel + 1
                    newXP = newXP - 100
                    newBoost = newBoost + 0.10
                    TriggerClientEvent('ox_lib:notify', source, {
                        title = 'Genbrugsstationen',
                        description = 'Du er nu i level ' ..newLevel.. '!',
                        type = 'success'
                    })
                    Log(GetPlayerName(source).. ' er lige staget til level ' ..newLevel.. ' og har nu x' ..newBoost.. ' boost')
                end
                if newLevel > 10 then
                    newLevel = 10
                    TriggerClientEvent('ox_lib:notify', source, {
                        title = 'Genbrugsstationen',
                        description = 'Du har nået level 10 og maks XP og vil derfor ikke stige i level.',
                        type = 'inform'
                    })
                end
                MySQL.Async.execute('UPDATE genbrug SET xp = @xp, level = @level, boost = @boost WHERE identifier = @identifier', {
                    ['@identifier'] = xPlayer.identifier,
                    ['@xp'] = newXP,
                    ['@level'] = newLevel,
                    ['@boost'] = newBoost
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        cb({ level = newLevel, xp = newXP, boost = newBoost })
                    else
                        cb(nil)
                    end
                end)
            else
                local defaultLevel = 1
                local defaultXP = randomXP
                local defaultBoost = 1.0
                MySQL.Async.execute('INSERT INTO genbrug (identifier, level, xp, boost) VALUES (@identifier, @level, @xp, @boost)', {
                    ['@identifier'] = xPlayer.identifier,
                    ['@level'] = defaultLevel,
                    ['@xp'] = defaultXP,
                    ['@boost'] = defaultBoost
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        cb({ level = defaultLevel, xp = defaultXP, boost = defaultBoost })
                    else
                        cb(nil)
                    end
                end)
            end
        end)
    end
end)


ESX.RegisterServerCallback('Johnny-genbrug:getBoostedChance', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerBoost = 1.0
    local playerLevel = 1
    local totalPercentage = 0

    MySQL.Async.fetchAll('SELECT * FROM genbrug WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if #result > 0 then
            playerLevel = result[1].level
            playerBoost = result[1].boost
        end

        for _, rewardData in ipairs(Config.Rewards) do
            local boostedPercentage = rewardData.percentage or 0
            if rewardData.rare then
                boostedPercentage = boostedPercentage * playerBoost
            end
            totalPercentage = totalPercentage + boostedPercentage
        end

        cb(playerLevel, playerBoost, totalPercentage)
    end)
end)



ESX.RegisterServerCallback('Johnny-genbrug:getInfo', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT * FROM genbrug WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if #result > 0 then
            cb({
                level = result[1].level,
                xp = result[1].xp,
                boost = result[1].boost
            })
        else
            local defaultLevel = 0
            local defaultXP = 0
            local defaultBoost = 1.0

            MySQL.Async.execute('INSERT INTO genbrug (identifier, level, xp, boost) VALUES (@identifier, @level, @xp, @boost)', {
                ['@identifier'] =  xPlayer.identifier,
                ['@level'] = defaultLevel,
                ['@xp'] = defaultXP,
                ['@boost'] = defaultBoost
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    cb({
                        level = defaultLevel,
                        xp = defaultXP,
                        boost = defaultBoost
                    })
                else
                    cb(nil)
                end
            end)
        end
    end)
end)

ESX.RegisterServerCallback('Johnny-genbrug:sellitems', function(source, cb, item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = GetPlayerName(source)

    if item == 'steel' then
        if xPlayer.getInventoryItem('steel').count >= amount then
            local SellPaySteel = 300 * amount 
            xPlayer.removeInventoryItem(item, amount)
            xPlayer.addMoney(SellPaySteel)
            LogSell(name.. ' solgte lige ' ..amount.. ' x ' ..item.. ' og modtog ' ..SellPaySteel.. ' DKK')
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Genbrugsstation',
                description = 'Du solgte ' ..amount.. ' ' ..item.. ' og modtog ' ..SellPaySteel.. ' DKK',
                type = 'success'
            })
        else 
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Genbrugsstation',
                description = 'Du har ikke nok stål!',
                type = 'error'
            })
        end
    elseif item == 'iron' then
        if xPlayer.getInventoryItem('iron').count >= amount then
            local SellPayIron = 300 * amount
            xPlayer.removeInventoryItem(item, amount)
            xPlayer.addMoney(SellPayIron)
            LogSell(name.. ' solgte lige ' ..amount.. ' x ' ..item.. ' og modtog ' ..SellPayIron.. ' DKK')
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Genbrugsstation',
                description = 'Du solgte ' ..amount.. ' ' ..item.. ' og modtog ' ..SellPayIron.. ' DKK',
                type = 'success'
            })
        else 
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Genbrugsstation',
                description = 'Du har ikke nok stål!',
                type = 'error'
            })
        end
    elseif item == 'copper' then
        if xPlayer.getInventoryItem('copper').count >= amount then
            local SellPayCopper = 300 * amount
            xPlayer.removeInventoryItem(item, amount)
            xPlayer.addMoney(SellPayCopper)
            LogSell(name.. ' solgte lige ' ..amount.. ' x ' ..item.. ' og modtog ' ..SellPayCopper.. ' DKK')
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Genbrugsstation',
                description = 'Du solgte ' ..amount.. ' ' ..item.. ' og modtog ' ..SellPayCopper.. ' DKK',
                type = 'success'
            })
        else 
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Genbrugsstation',
                description = 'Du har ikke nok stål!',
                type = 'error'
            })
        end
    end
end)


function Log(msg)
    local embeds = {
        {
            ["color"] = "8663711",
            ["title"] = "Gebrugsstationen",
            ["description"] = msg,
            ["footer"] = {
                ["text"] = "Genbrugs script - logs.",
            },
        }
    }
    PerformHttpRequest('https://discord.com/api/webhooks/1346462965984919562/Ynsz0Y5FEjVyHk997BC7z7VdT8uBKDF-yUM05W7phlBiPJDf7Q4zBrOhcvcvCya4cqEG', function(err, text, headers) end, 'POST', json.encode({username = 'System', embeds = embeds, avatar_url = 'https://cdn.mos.cms.futurecdn.net/7GCPeSkqz3duhcXkg7E6H7-320-80.jpg'}), { ['Content-Type'] = 'application/json' })
end

function LogSell(msg)
    local embeds = {
        {
            ["color"] = "8663711",
            ["title"] = "Gebrugsstationen",
            ["description"] = msg,
            ["footer"] = {
                ["text"] = "Genbrugs script - logs.",
            },
        }
    }
    PerformHttpRequest('https://discord.com/api/webhooks/1346462965984919562/Ynsz0Y5FEjVyHk997BC7z7VdT8uBKDF-yUM05W7phlBiPJDf7Q4zBrOhcvcvCya4cqEG', function(err, text, headers) end, 'POST', json.encode({username = 'System', embeds = embeds, avatar_url = 'https://cdn.mos.cms.futurecdn.net/7GCPeSkqz3duhcXkg7E6H7-320-80.jpg'}), { ['Content-Type'] = 'application/json' })
end

