local punchedIn = false
local randPackage = nil
local carryingBox = false
local activeZone = nil
local boxObject = nil
local animDict = "anim@heists@box_carry@"
searchProps = {}
Props = {}

function Disable()
    if punchedIn then 
        if activeZone then
            exports.ox_target:removeZone(activeZone)
            activeZone = nil
        end

        punchedIn = false
    end

    if randPackage then
        SetEntityDrawOutline(randPackage, false)
        randPackage = nil
    end
    
    carryingBox = false
    boxObject = nil
    searchProps = {}
    Props = {}
end

local blips = {
     {title="Genbrugsstation", colour=69, id=467, x = 237.2699, y = -1854.9811, z = 26.8289}
  }

Citizen.CreateThread(function()

    for _, info in pairs(blips) do
      info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 1.0)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, true)
	  BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
    end
end)

function HoldBox()
    local playerPed = GetPlayerPed(-1)

    local boxModel = GetHashKey("prop_cs_cardbox_01")
    RequestModel(boxModel)
    while not HasModelLoaded(boxModel) do
        Citizen.Wait(0)
    end

    boxObject = CreateObject(boxModel, 0, 0, 0, true, true, true)
    AttachEntityToEntity(boxObject, playerPed, GetPedBoneIndex(playerPed, 0x49D9), 0.14958754132738, 0.00048084661165959, 0.23682357403272, 23.867112834595, -39.879443335001, 10.477985942299, true, true, false, true, 1, true)

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(playerPed, animDict, "idle", 8.0, -8.0, -1, 50, 0, false, false, false)
    SetEntityAsNoLongerNeeded(boxObject)
end

function DropBox()
    local playerPed = GetPlayerPed(-1)
    ClearPedTasks(playerPed)
    DetachEntity(boxObject, true, true)
    SetEntityAsMissionEntity(boxObject, true, true)
    DeleteEntity(boxObject)
    boxObject = nil
end

function loadModel(model)
    local time = 1000
    if not HasModelLoaded(model) then if Config.Debug then print("^5Debug^7: ^2Loading Model^7: '^6"..model.."^7'") end
	while not HasModelLoaded(model) do if time > 0 then time = time - 1 RequestModel(model)
		else time = 1000 print("^5Debug^7: ^3LoadModel^7: ^2Timed out loading model ^7'^6"..model.."^7'") break end
		Wait(10) end
	end
end

function makeProp(data, freeze, synced)
    loadModel(data.prop)
    local prop = CreateObject(data.prop, data.coords.x, data.coords.y, data.coords.z, synced or 0, synced or 0, 0)
    SetEntityHeading(prop, data.coords.w)
    FreezeEntityPosition(prop, freeze or 0)
    if Config.Debug then print("^5Debug^7: ^6Prop ^2Created ^7: '^6"..prop.."^7'") end
    return prop
end

function destroyProp(entity)
	if Config.Debug then print("^5Debug^7: ^2Destroying Prop^7: '^6"..entity.."^7'") end
	SetEntityAsMissionEntity(entity) Wait(5)
	DetachEntity(entity, true, true) Wait(5)
	DeleteEntity(entity)
end

function unloadModel(model) if Config.Debug then print("^5Debug^7: ^2Removing Model^7: '^6"..model.."^7'") end SetModelAsNoLongerNeeded(model) end

RegisterNetEvent('Johnny-genbrug:searchBin', function()
local time = Config.SearchTime
    if not carryingBox then
        if lib.progressBar({
            duration = time,
            label = 'Leder i kassen...',
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
            anim = {
                dict = 'amb@prop_human_bum_bin@base',
                clip = 'base'
            },
        }) then
            lib.notify({
                title = 'Genbrugsstationen',
                description = 'Du har taget en kasse, gå hen og bortskaf den.',
                type = 'success'
            })
            carryingBox = true
            HoldBox()
            SetEntityDrawOutline(randPackage, false)
            SetEntityDrawOutline(`prop_recyclebin_04_a`, true)
            SetEntityDrawOutlineColor(255, 255, 255, 1.0)
            SetEntityDrawOutlineShader(1)
        else
            lib.notify({
                title = 'Genbrugsstation',
                description = 'Du annullerede søgningen.',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Genbrugsstation',
            description = 'Du har allerede en kasse!',
            type = 'error'
        })
    end
end)

function GetReward()
    local totalPercentage = 0
    local playerBoost = 1.0
    local playerLevel = 1

    ESX.TriggerServerCallback('Johnny-genbrug:getBoostedChance', function(level, boost, totalPerc)
        playerLevel = level
        playerBoost = boost
        totalPercentage = totalPerc

        if totalPercentage > 0 then
            local randomPercentage = math.random() * totalPercentage
            local selectedRewardIndex = 1

            for i, rewardData in ipairs(Config.Rewards) do
                local boostedPercentage = rewardData.percentage or 0
                if rewardData.rare then
                    boostedPercentage = boostedPercentage * playerBoost
                end
                randomPercentage = randomPercentage - boostedPercentage
                if randomPercentage <= 0 then
                    selectedRewardIndex = i
                    break
                end
            end

            local rewardData = Config.Rewards[selectedRewardIndex]
            local amount = math.random(rewardData.min, rewardData.max)
            local reward = rewardData.item

            if carryingBox then
                if lib.progressCircle({
                    duration = Config.DisposeTime,
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        move = true,
                        car = true,
                        combat = true,
                    },
                }) then
                    local ChallengeChance = math.random(1, 10)
                    if ChallengeChance < 3 then
                        local success = lib.skillCheck({'easy', 'easy', 'medium', {areaSize = 60, speedMultiplier = 1}, 'hard'}, {'w', 'a', 's', 'd'})
                        if success then
                            ESX.TriggerServerCallback('Johnny-genbrug:giveItem', function() end, reward, amount)
                            ESX.TriggerServerCallback('Johnny-genbrug:giveItem', function() end, reward, amount)
                            TriggerEvent('Johnny-genbrug:newLoc')
                            DropBox()
                            carryingBox = false
                            lib.notify({
                                title = 'Genbrugsstation',
                                description = 'Du klarede ekstra challenge!',
                                type = 'success'
                            })
                        else
                            ESX.TriggerServerCallback('Johnny-genbrug:giveItem', function() end, reward, amount)
                            TriggerEvent('Johnny-genbrug:newLoc')
                            DropBox()
                            carryingBox = false
                            lib.notify({
                                title = 'Genbrugsstation',
                                description = 'Du fejlende ekstra challenge.',
                                type = 'error'
                            })
                        end
                    else
                        lib.notify({
                            title = 'Genbrugsstationen',
                            description = 'Du bortskaffede kassen, hent en ny!',
                            type = 'success'
                        })
                        ESX.TriggerServerCallback('Johnny-genbrug:giveItem', function() end, reward, amount)
                        TriggerEvent('Johnny-genbrug:newLoc')
                        DropBox()
                        carryingBox = false
                    end
                else
                    lib.notify({
                        title = 'Genbrugsstation',
                        description = 'Du annullerede afskaffelse.',
                        type = 'error'
                    })
                end
            else
                lib.notify({
                    title = 'Genbrugsstation',
                    description = 'Kig i en af kasserne først',
                    type = 'error'
                })
            end
        end
    end)
end

function GoComputer()
    if lib.progressCircle({
        duration = Config.ComputerTime,
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true,
        },
        anim = {
            dict = 'mp_safehousevagos@boss',
            clip = 'vagos_boss_keyboard_b'
        },
    }) then
        OpenRecycleComputer()
    end
end

OpenRecycleComputer = function()
    local options = {}
    ESX.TriggerServerCallback('Johnny-genbrug:getInfo', function(data)
        if data then
            local level = data.level
            local xp = data.xp
            local boost = data.boost

            table.insert(options, {
                title = 'Oplysninger',
                description = 'Du er niveu ' .. level .. ' - x' .. boost .. ' boost',
                progress = xp,
                colorScheme = '#137bc3',
                icon = 'user'
            })

            if punchedIn == true then
                table.insert(options, { 
                    title = "Log ind", 
                    description = 'Log ind og lav noget arbejde', 
                    icon = 'right-to-bracket', 
                    disabled = true 
                })
            else
                table.insert(options, {
                    title = 'Log ind',
                    description = 'Log ind og lav noget arbejde',
                    icon = 'right-to-bracket',
                    event = 'Johnny-genbrug:punchIn'
                })
            end

            table.insert(options, {
                title = 'Sælg materialer',
                description = 'Sælg items du modtager fra arbejdet.',
                icon = 'circle-check',
                disabled = false,
                onSelect = function()
                    SetNewWaypoint(-97.2633, -1013.9756, 27.2752, 350.0696)
                    lib.notify({
                        title = 'Genbrugsstation',
                        description = 'Kør ned og sælg dine items. Har sat en GPS!',
                        duration = 5000,
                        type = 'success'
                    })
                end
            })

            lib.registerContext({
                id = 'ComputerMenu',
                title = 'Genbrugsstationen',
                options = options
            })

            lib.showContext('ComputerMenu')
        else
            lib.notify({
                title = 'Genbrugsstation',
                description = 'Kunne ikke hente din information. Prøv igen senere.',
                duration = 5000,
                type = 'error'
            })
        end
    end)
end




RegisterNetEvent('Johnny-genbrug:punchIn')
AddEventHandler('Johnny-genbrug:punchIn', function()
    lib.hideContext(onExit)
    if not punchedIn then
        punchedIn = true
        if lib.progressCircle({
            duration = Config.PunchInTime,
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
            anim = {
                dict = 'mp_safehousevagos@boss',
                clip = 'vagos_boss_keyboard_b'
            },
        }) then

            lib.notify({
                title = 'Genbrugsstationen',
                description = 'Du er nu stemplet ind, gå hen til den markeret kasse og led.',
                type = 'success'
            })
        
            randPackage = searchProps[math.random(1, #searchProps)]
            SetEntityDrawOutline(randPackage, true)
            SetEntityDrawOutlineColor(255, 255, 255, 1.0)
            SetEntityDrawOutlineShader(1)
            local coords = GetEntityCoords(randPackage)
            activeZone = exports.ox_target:addSphereZone({
                name = 'led_kasse',
                coords = vec3(coords.x, coords.y, coords.z + 1),
                radius = 1.5,
                debug = Config.Debug,
                options = {
                    {
                        name = 'search',
                        label = 'Led i kassen',
                        distance = 2.5,
                        event = 'Johnny-genbrug:searchBin',
                        icon = 'fa-sharp fa-regular fa-hand'
                    }
                }
            })
        else
            lib.notify({
                title = 'Genbrugsstation',
                description = 'Du er alleredet stemplet ind, start med arbejdet!',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Genbrugsstation',
            description = 'Du er alleredet stemplet ind, start med arbejdet!',
            type = 'error'
        })
    end
end)


RegisterNetEvent('Johnny-genbrug:newLoc')
AddEventHandler('Johnny-genbrug:newLoc', function()
    if activeZone ~= nil then
        exports.ox_target:removeZone(activeZone)
        SetEntityDrawOutline(randPackage, false)
    end

    randPackage = searchProps[math.random(1, #searchProps)]
    SetEntityDrawOutline(randPackage, true)
    SetEntityDrawOutlineColor(255, 255, 255, 1.0)
    SetEntityDrawOutlineShader(1)
    local coords = GetEntityCoords(randPackage)
    activeZone = exports.ox_target:addSphereZone({
        name = 'led_kasse2',
        coords = vec3(coords.x, coords.y, coords.z + 1),
        radius = 1.5,
        debug = Config.Debug,
        options = {
            {
                name = 'search',
                label = 'Led i kassen',
                event = 'Johnny-genbrug:searchBin',
                distance = 2.5,
                icon = 'fa-sharp fa-regular fa-circle'
            }
        }
    })
end)


function onEnter(self)
    local alert = lib.alertDialog({
        header = 'Genbrugsstationen',
        content = 'For at begynde dit arbejde og stemple ind, skal du bruge computeren.',
        centered = true,
        cancel = false
    })
    makeProp({prop = `prop_recyclebin_04_a`,		coords = vector4(993.26165771484, -3109.0383300781, -39.999885559082, 0.0)}, 1, 0) --
	searchProps[#searchProps+1] = makeProp({prop = `prop_cratepile_07a`,		coords = vector4(1003.6661376953, -3091.849609375, -39.999885559082, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ba_prop_battle_crate_art_02_bc`,		coords = vector4(1006.0225830078, -3091.7231445313, -39.872150421143, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ba_prop_battle_crate_biohazard_bc`,		coords = vector4(1008.5004272461, -3091.7231445313, -39.884292602539, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `sm_prop_smug_crate_m_tobacco`,		coords = vector4(1010.8915405273, -3091.9899902344, -39.999885559082, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `sm_prop_smug_crate_01a`,		coords = vector4(1013.2913208008, -3091.9899902344, -40.000034332275, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ba_prop_battle_crate_med_bc`,		coords = vector4(1018.1947021484, -3091.6889648438, -39.875385284424, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `prop_cratepile_07a`,		coords = vector4(1018.1841430664, -3096.9411621094, -39.995037841797, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `sm_prop_smug_crate_m_tobacco`,		coords = vector4(1015.65625, -3096.9411621094, -40.00577545166, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `prop_drop_crate_01_set2`,		coords = vector4(11010.9002685547, -3096.9411621094, -39.468029022217, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ba_prop_battle_crate_art_02_bc`,		coords = vector4(1008.5, -3096.9411621094, -39.881149291992, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `sm_prop_smug_crate_01a`,		coords = vector4(1006.0223388672, -3096.9411621094, -40.004768371582, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `sm_prop_smug_crate_01a`,		coords = vector4(1003.716003418, -3102.7248535156, -40.004768371582, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ba_prop_battle_crate_biohazard_bc`,		coords = vector4(1006.1392822266, -3102.7348632813, -39.878765106201, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ex_Prop_Crate_Closed_BC`,		coords = vector4(1008.4108886719, -3102.7348632813, -39.898906707764, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ex_prop_crate_wlife_sc`,		coords = vector4(1013.2644042969, -3102.7348632813, -40.013065338135, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ex_Prop_Crate_furJacket_SC`,		coords = vector4(1015.639831543, -3102.7348632813, -40.012802124023, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ex_Prop_Crate_Elec_BC`,		coords = vector4(1015.6989135742, -3108.2502441406, -39.990798339844, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ex_Prop_Crate_Jewels_racks_BC`,		coords = vector4(1010.9719238281, -3108.2502441406, -39.9989282226563, 0.0)}, 1, 0) --
end

function onExit(self)
        punchedIn = false
        if Config.Debug then print("^5Debug^7: ^3ClearProps^7() ^2Exiting building^7, ^2clearing previous props ^7(^2if any^7)") end
        for _, v in pairs(searchProps) do unloadModel(GetEntityModel(v)) DeleteObject(v) end searchProps = {}
        for _, v in pairs(Props) do unloadModel(GetEntityModel(v)) DeleteObject(v) end Props = {}
end
 
local poly = lib.zones.poly({
    points = {
        vec(990.2048, -3087.7419, -38),
        vec(990.9404, -3114.7329, -38),
        vec(1028.2522, -3113.5142, -38),
        vec(1028.1239, -3089.1282, -38),
    },
    thickness = 10,
    debug = Config.DebugPoly,
    onEnter = onEnter,
    onExit = onExit,
})

function teleOut2()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do	Citizen.Wait(10) end
    SetEntityCoords(PlayerPedId(), Config.Enter)
    DoScreenFadeIn(500)
end


-- AddEventHandler('onResourceStop', function(resource)
-- 	if resource == GetCurrentResourceName() then
--         if punchedIn == true then
--             local punchedIn = false
--             local randPackage = nil
--             local carryingBox = false
--             local activeZone = nil
--             local boxObject = nil

--             lib.notify({
--                 title = 'Genbrugsstation',
--                 description = 'Vi havde en lille opdatering. Gå venligst ind igen, for at fortsætte.',
--                 type = 'inform'
--             })
--         else
--             Wait(100)
--         end
-- 	end
-- end)