exports.ox_target:addSphereZone({
	coords = vec3(993.5995, -3109.0598, -38.9999),
	radius = 1,
    debug = Config.Debug,
	options = {
		{
			name = 'dispose',
            distance = 1.2,
			icon = 'fa-solid fa-recycle',
			label = 'Afgiv',
			onSelect = function()
				GetReward()
			end
		}
	}
})

exports.ox_target:addSphereZone({
	coords = vec3(994.9576, -3100.0081, -39.1834),
	radius = 1,
    debug = Config.Debug,
	options = {
		{
			name = 'start',
            distance = 1.2,
			icon = 'fa-solid fa-computer',
			label = 'Åben computeren',
			onSelect = function()
				GoComputer()
			end
		}
	}
})

exports.ox_target:addSphereZone({
	coords = vec3(992.3944, -3097.8555, -38.9959),
	radius = 1,
    debug = Config.Debug,
	options = {
		{
			name = 'teleOut',
            distance = 1.2,
			icon = 'fa-solid fa-recycle',
			label = 'Gå ud af Genbrug',
			onSelect = function()
                teleOut()
				Disable()
            end
		}
	}
})

exports.ox_target:addSphereZone({
	coords = Config.Enter,
	radius = 1,
    debug = Config.Debug,
	options = {
		{
			name = 'teleInside',
            distance = 1.2,
			icon = 'fa-solid fa-recycle',
			label = 'Tilgå Genbrug',
			onSelect = function()
				if Config.DevMode then 
					lib.notify({
						title = 'Genbrugsstation',
						description = 'Genbrugsstationen er dsv. ikke tilgængelig lige pt. - Kom igen senere.',
						type = 'inform'
					})
					return 
				end

                teleInside()
            end
		}
	}
})

exports.ox_target:addSphereZone({
	coords = vector3(-97.1548, -1013.8693, 27.275),
	radius = 4,
    debug = Config.Debug,
	options = {
		{
			name = 'sell',
            distance = 1.2,
			icon = 'fa-solid fa-hammer',
			label = 'Sælg materialer',
			onSelect = function()
				if Config.DevMode then 
					lib.notify({
						title = 'Genbrugsstation',
						description = 'Genbrugsstationen er dsv. ikke tilgængelig lige pt. - Kom igen senere.',
						type = 'inform'
					})
					return 
				end

                sellMaterials()
            end
		}
	}
})



sellMaterials = function()
	lib.registerContext({
		 id = 'sellMaterials',
		 title = 'Sælg dine materialer',
	 
		options = {
			 {
				 title = 'Jern',
				 description = 'Pris: 500,- DKK per stk.',
				 icon = 'fa-solid fa-cubes',
				 arrow = true,
				 onSelect = function()
					local input = lib.inputDialog('Sælg matrialer', {
						{type = 'number', label = 'Antal', description = 'Hvor mange vil du sælge'},
					  })

					  if input then
						local amount = input[1]
					ESX.TriggerServerCallback('at-genbrug:sellitems', function() end, 'iron', amount)
					  else 
						lib.showContext('sellMaterials')
					end
				 end
				
			 },
			 {
				 title = 'Stål',
				 description = 'Pris: 500,- DKK per stk.',
				 icon = 'fa-solid fa-cubes',
				 arrow = true,
				 onSelect = function()
					local input = lib.inputDialog('Sælg matrialer', {
						{type = 'number', label = 'Antal', description = 'Hvor mange vil du sælge'},
					  })

					  if input then
						local amount = input[1]
					ESX.TriggerServerCallback('at-genbrug:sellitems', function() end, 'steel', amount)
					  else 
						lib.showContext('sellMaterials')
					end
				 end
			 },
			 {
				 title = 'Kobber',
				 description = 'Pris: 500,- DKK per stk.',
				 icon = 'fa-solid fa-cubes',
				 arrow = true,
				 onSelect = function()
					local input = lib.inputDialog('Sælg matrialer', {
						{type = 'number', label = 'Antal', description = 'Hvor mange vil du sælge'},
					  })

					  if input then
						local amount = input[1]
					ESX.TriggerServerCallback('at-genbrug:sellitems', function() end, 'copper', amount)
					  else 
						lib.showContext('sellMaterials')
					end
				 end
			 },
		 },
	 })
 
	 lib.showContext('sellMaterials')
 end

function teleInside()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do	Citizen.Wait(10) end
    SetEntityCoords(PlayerPedId(), vec3(992.3944, -3097.8555, -38.9959))
    DoScreenFadeIn(500)
end

function teleOut()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do	Citizen.Wait(10) end
    SetEntityCoords(PlayerPedId(), Config.Enter)
    DoScreenFadeIn(500)
end

local spawnped = false
CreateThread(function()
    while true do
        if spawnped == false then
            spawnped = true
            RequestModel(GetHashKey('s_m_y_construct_01'))
            while not HasModelLoaded(GetHashKey('s_m_y_construct_01')) do
                Wait(1)
            end

            ped1 = CreatePed(4, GetHashKey('s_m_y_construct_01'), -97.0987, -1013.4451, 26.2752, 164.3362, false, true) -- ændrer disse koordinater
            FreezeEntityPosition(ped1, true)
            SetEntityInvincible(ped1, true)
            SetBlockingOfNonTemporaryEvents(ped1, true)
        end
        Wait(10000)
    end
end)  
