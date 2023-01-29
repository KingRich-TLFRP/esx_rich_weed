ESX = nil

ESX = exports['es_extended']:getSharedObject()

--- dont mess with this, just dont touch
local PlayersApanhandoWeeds = {}
local PlayersPlantandoWeeds = {}
local LockApanha = {}
local LockPlantar = {}
local CurrentWeather = 0
---


--- EDIT THIS LINE!!!!!---
local savet = 10 -- savetime in seconds
--- EDIT THIS LINE!!!!!---



---
local savetimems = savet * 1000
---

function sendToDiscord (name,message)
    local DiscordWebHook = "https://discordapp.com/api/webhooks/595742809856802835/JVYecbAq7TfZVKV01BO3e58alEBLhmghy4hPclFLYFJbvXicjRziNmqceKQhMWWjGq8o" -- Chat #Log-Chat
  
    local embeds = {
        {
            ["title"]=message,
            ["type"]="rich",
            ["color"] = 2061822,
            ["footer"]=  {
                ["text"]= "The Liberty Family - Discord Bot Log",
            },
        }
    }
  
    if message == nil or message == '' then 
        return FALSE 
    end

    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent("weedz:savecampo")
AddEventHandler("weedz:savecampo", function(fm, sd, nd, mm, ad, qd)
	local qdc = 0
	local stt = 1
	MySQL.Async.fetchAll('SELECT * FROM weed WHERE Spot=@spt', {['@spt'] = fm}, function(gotInfo)
		if gotInfo[1] ~= nil then
            MySQL.Async.execute("UPDATE weed SET Timer=@TIMER WHERE Spot=@spt", {["@TIMER"] = sd, ['@spt'] = fm})
			MySQL.Async.execute("UPDATE weed SET Status=@STATUS WHERE Spot=@spt", {["@STATUS"] = stt, ['@spt'] = fm})
	        MySQL.Async.execute("UPDATE weed SET Ready=@READY WHERE Spot=@spt", {["@READY"] = nd, ['@spt'] = fm})
		    MySQL.Async.execute("UPDATE weed SET Water=@WATER WHERE Spot=@spt", {["@WATER"] = mm, ['@spt'] = fm})
			MySQL.Async.execute("UPDATE weed SET Fertilizer=@FERTILIZER WHERE Spot=@spt", {["@FERTILIZER"] = ad, ['@spt'] = fm})
			MySQL.Async.execute("UPDATE weed SET Quality=@QUALITY WHERE Spot=@spt", {["@QUALITY"] = qd, ['@spt'] = fm})
			MySQL.Async.execute("UPDATE weed SET QualityCounter=@QUALITYCOUNTER WHERE Spot=@spt", {["@QUALITYCOUNTER"] = qdc, ['@spt'] = fm})
		else
			MySQL.Async.execute("INSERT INTO weed (Spot, Timer, Status, Ready, Water, Fertilizer, Quality, QualityCounter) VALUES (@Spot,@Timer,@Status,@Ready,@Water,@Fertilizer,@Quality,@QualityCounter)", {['@Spot'] = fm, ['@Timer'] = sd, ['@Status'] = stt, ['@Ready'] = nd, ['@Water'] = mm, ['@Fertilizer'] = ad, ['@Quality'] = qd, ['@QualityCounter'] = qdc})
		end
	end)
end)


-- WHEN SOMEONE PICKS THE WEED FROM CAMP Nº1 IT SAVES IN THE DATABASE AND MAKE THE CAMP CLEAR FOR NEW PLANTS
RegisterServerEvent("weedz:saveapanhado")
AddEventHandler("weedz:saveapanhado", function(sd, stt, nd, mm, ad, qd, spt)
	local dados   = MySQL.Sync.fetchAll('SELECT * FROM weed')
	local qdc = 0
    for i=1, #dados, 1 do
	    if dados[i].Spot == spt then -- CAMP nº1
            MySQL.Async.execute("UPDATE weed SET Timer=@TIMER WHERE ID=@ii", {["@TIMER"] = sd, ['@ii'] = dados[i].ID})
			MySQL.Async.execute("UPDATE weed SET Status=@STATUS WHERE ID=@ii", {["@STATUS"] = stt, ['@ii'] = dados[i].ID})
	        MySQL.Async.execute("UPDATE weed SET Ready=@READY WHERE ID=@ii", {["@READY"] = nd, ['@ii'] = dados[i].ID})
			MySQL.Async.execute("UPDATE weed SET Water=@WATER WHERE ID=@ii", {["@WATER"] = mm, ['@ii'] = dados[i].ID})
			MySQL.Async.execute("UPDATE weed SET Fertilizer=@FERTILIZER WHERE ID=@ii", {["@FERTILIZER"] = ad, ['@ii'] = dados[i].ID})
			MySQL.Async.execute("UPDATE weed SET Quality=@QUALITY WHERE ID=@ii", {["@QUALITY"] = qd, ['@ii'] = dados[i].ID})
			MySQL.Async.execute("UPDATE weed SET QualityCounter=@QUALITYCOUNTER WHERE ID=@ii", {["@QUALITYCOUNTER"] = qdc, ['@ii'] = dados[i].ID})
		end
	end
end)


-- CHECK IF THE PLANT IS IN A EARLY STAGE, MID STAGE OR FARM STAGE
RegisterServerEvent("weedz:checktempo")
AddEventHandler("weedz:checktempo", function()
	local dados   = MySQL.Sync.fetchAll('SELECT * FROM weed')
    for i=1, #dados, 1 do
	    if dados[i].Spot > 0 and dados[i].Status == 1 then
		    local tempo = dados[i].Timer - 1
			local adubo = dados[i].Fertilizer
			if adubo == 1 then 
			    tempo = tempo - (fertilizerextra/savetime) 
			end
			if dados[i].Ready == 1 then TriggerClientEvent("weedz:pronto", -1, dados[i].Spot) end
		    if tempo <= 1 and dados[i].Ready == 0 then -- FARM STAGE, READY TO SMOKE HEHE
				local pronto1 = 1
		        MySQL.Async.execute("UPDATE weed SET Ready=@READY WHERE ID=@ii", {["@READY"] = pronto1, ['@ii'] = dados[i].ID})
		        TriggerClientEvent("weedz:pronto", -1, dados[i].Spot)
				-- Quality Calculation
				if dados[i].Fertilizer == 0 then
				    local totalsavetime = savetime
					local growcounter = growtime/totalsavetime
					local plantgrowcounter = dados[i].QualityCounter
					local ratio = growcounter/plantgrowcounter
					if ratio < 0.25 then
						Qualidade(dados[i].Quality, 1, dados[i].ID)
					end
					if ratio >= 0.25 and ratio < 0.50 then
						Qualidade(dados[i].Quality, 2, dados[i].ID)
					end
					if ratio >= 0.50 and ratio < 0.75 then
						Qualidade(dados[i].Quality, 3, dados[i].ID)
					end
					if ratio >= 0.75 and ratio <= 1 then
						Qualidade(dados[i].Quality, 4, dados[i].ID)
					end
				else
				    local totalsavetime = savetime + fertilizerextra
					local growcounter = growtime/totalsavetime
					local plantgrowcounter = dados[i].QualityCounter
					local ratio = growcounter/plantgrowcounter 
					if ratio < 0.25 then
					    Qualidade(dados[i].Quality, 1, dados[i].ID)
					end
					if ratio >= 0.25 and ratio < 0.50 then
						Qualidade(dados[i].Quality, 2, dados[i].ID)
					end
					if ratio >= 0.50 and ratio < 0.75 then
						Qualidade(dados[i].Quality, 3, dados[i].ID)
					end
					if ratio >= 0.75 and ratio <= 1 then
						Qualidade(dados[i].Quality, 4, dados[i].ID)
					end
				end
			end
			if dados[i].Ready == 0 then -- EARLY STAGE
			    if tempo >= changetime then
			        TriggerClientEvent("weedz:plantadissimo", -1, dados[i].Spot)
				end
				if tempo < changetime and tempo > 1 then -- MID STAGE
			        TriggerClientEvent("weedz:plantadissimo1", -1, dados[i].Spot)
				end
			end
		end
	end
end)

--
RegisterServerEvent("weedz:checkcolheita1")
AddEventHandler("weedz:checkcolheita1", function()
	local dados   = MySQL.Sync.fetchAll('SELECT * FROM weed')
	local check = {}
    for i=1, #dados, 1 do
	    if dados[i].Spot > 0 and dados[i].Status == 1 then
            TriggerClientEvent("weedz:senddata", -1, dados[i].Status, dados[i].Ready, dados[i].Timer, dados[i].Water, dados[i].Spot)
			TriggerClientEvent("weedz:info", -1, dados[i].Water, dados[i].Fertilizer, dados[i].Quality, dados[i].Spot)		
		end
	end
end)

RegisterServerEvent("weedz:water")
AddEventHandler("weedz:water", function(water, plantanr)
	
	local xPlayer = ESX.GetPlayerFromId(source)
	local playerName = GetPlayerName(source)
	--local acquaQTY = xPlayer.getInventoryItem('acqua')
	
	--if acquaQTY ~= 0 then
		local dados   = MySQL.Sync.fetchAll('SELECT * FROM weed')
		--TriggerClientEvent('weedz:notification', source, 'Acqua aggiunta.')

		xPlayer.removeInventoryItem('acqua', 1)
		sendToDiscord('📝 Log Weed', 'Il giocatore __**' .. playerName .. '**__ ha usato dell\'acqua in una pianta di marijuana')
		for i=1, #dados, 1 do
			if dados[i].Spot == plantanr then 
				if dados[i].Ready == 0 then
					MySQL.Async.execute("UPDATE weed SET Water=@WATER WHERE ID=@ii", {["@WATER"] = water, ['@ii'] = dados[i].ID})
				end
			end
		end
	--else
		--TriggerClientEvent('weedz:notification', source, 'Non hai dell\'acqua nel tuo inventario.')
	--end
end)

RegisterServerEvent("weedz:fertilizer")
AddEventHandler("weedz:fertilizer", function(fertilizer, plantanr)

	local xPlayer = ESX.GetPlayerFromId(source)
	local playerName = GetPlayerName(source)
	--local fertilizzateQTY = xPlayer.getInventoryItem('fertilizzante')

	--if fertilizzateQTY ~= 0 then
		local dados   = MySQL.Sync.fetchAll('SELECT * FROM weed')
		--TriggerClientEvent('weedz:notification', source, 'Fertilizzante aggiunto.')

		xPlayer.removeInventoryItem('fertilizzante', 1)
		sendToDiscord('📝 Log Weed', 'Il giocatore __**' .. playerName .. '**__ ha usato del fertilizzante in una pianta di marijuana')
		for i=1, #dados, 1 do
			if dados[i].Spot == plantanr then 
				if dados[i].Ready == 0 then
					MySQL.Async.execute("UPDATE weed SET Fertilizer=@FERTILIZER WHERE ID=@ii", {["@FERTILIZER"] = fertilizer, ['@ii'] = dados[i].ID})
				end
			end
		end
	--else
	--	TriggerClientEvent('weedz:notification', source, 'Non hai del fertilizzante nel tuo inventario.')
	--end
end)

RegisterServerEvent('weedz:updateWeather3')
AddEventHandler('weedz:updateWeather3', function(ok)
    if weatheron then
        CurrentWeather = ok
	end
end)



-------------------------------------


function PlantarWeed(source, spt)

	SetTimeout(10000, function()

		if PlayersPlantandoWeeds[source] == true then

			local xPlayer = ESX.GetPlayerFromId(source)
			local playerName = GetPlayerName(source)
		    -- IN THIS VERSION (STANDALONE) THE ITEMS DONT COME INCLUDED, CAUSE EACH SERVER HAVE DIFERENT DB'S AND ITEMS!
			-- HERE IF YOU WANT, AND YOU SHOULD ADD ONE LINE THAT REMOVES THE SEED FROM THE PLAYER
			--local seedQTY = xPlayer.getInventoryItem('cannabis').count

			--if seedQTY > 0 then
				xPlayer.removeInventoryItem('cannabis', 1)
				TriggerClientEvent('weedz:notification', source, 'Erba piantata con successo.')
				PlayersPlantandoWeeds[source] = false
				TriggerClientEvent("weedz:sucessplanted", source, spt)
				TriggerClientEvent("weedz:plantadissimo", -1, spt)
				TriggerClientEvent("weedz:plantadissimot", -1, spt)
				print("SOURCE PLANTAR:" .. LockPlantar[spt])
				LockPlantar[spt] = nil
				print("SPOT PLANTAR:" .. spt)
				sendToDiscord('📝 Log Weed', 'Il giocatore __**' .. playerName .. '**__ ha piantato un seme di marijuana nello spot n°' .. spt)
			--else
			--	TriggerClientEvent('weedz:notification', source, 'Non hai dei semi nell\'inventario.')
			--end
		end
	end)
end 

RegisterServerEvent('weedz:startPlantarWeed')
AddEventHandler('weedz:startPlantarWeed', function(Spot)

	if LockPlantar[Spot] == nil then
		
		--local xPlayer = ESX.GetPlayerFromId(_source)
		--local seedQTY = xPlayer.getInventoryItem('cannabis').count

		--if seedQTY > 0 then
			local _source = source
			PlayersPlantandoWeeds[_source] = true
			TriggerClientEvent('weedz:notification', _source, 'Stai piantando semi di erba...')
			LockPlantar[Spot] = _source
			PlantarWeed(_source, Spot)
			print("SOURCE PLANTAR:" .. LockPlantar[Spot])
			print("SPOT PLANTAR:" .. Spot)
		--else
		--	TriggerClientEvent('weedz:notification', source, 'Non hai dei semi nell\'inventario.')
		--end
    else
	    TriggerClientEvent('weedz:notification', source, 'Qualcuno sta già piantnado in questo punto!')
	end
end)

RegisterServerEvent('weedz:stopPlantarWeed')
AddEventHandler('weedz:stopPlantarWeed', function()
	local _source = source
	PlayersPlantandoWeeds[_source] = false
end)




--------------------------------

function ApanhaWeed(source, spt)

	SetTimeout(10000, function()

		if PlayersApanhandoWeeds[source] == true then

			local xPlayer = ESX.GetPlayerFromId(source)
			local grammiQTY = xPlayer.getInventoryItem('marijuana')
			local playerName = GetPlayerName(source)

			if grammiQTY.limit ~= -1 and grammiQTY.count >= grammiQTY.limit then
				TriggerClientEvent('weedz:notification', source, 'Hai troppa marijuana nel tuo inventario')
				PlayersApanhandoWeeds[source] = false
				LockApanha[spt] = nil
			else
				xPlayer.addInventoryItem('marijuana', 30)
				TriggerClientEvent('weedz:notification', source, 'Erba coltivata con successo')
				PlayersApanhandoWeeds[source] = false
				TriggerClientEvent("weedz:sucessfarm", source, spt)
				TriggerClientEvent("weedz:desplantadissimo", -1, spt)
				print("SOURCE APANHA:" .. LockApanha[spt])
				print("SPOT APANHA:" .. spt)
				sendToDiscord('📝 Log Weed', 'Il giocatore __**' .. playerName .. '**__ ha finito di coltivare una pianata di marijuana nello spot n°' .. spt)
				LockApanha[spt] = nil
			end

		end
	end)
end 

RegisterServerEvent('weedz:startApanhaWeed')
AddEventHandler('weedz:startApanhaWeed', function(Spot)
    
	if LockApanha[Spot] == nil then
	    local _source = source
	    PlayersApanhandoWeeds[_source] = true
	    LockApanha[Spot] = _source
	    TriggerClientEvent('weedz:notification', source, 'Stai coltivando erba...')
	    ApanhaWeed(_source, Spot)
		print("SOURCE APANHA:" .. LockApanha[Spot])
	    print("SPOT APANHA:" .. Spot)
    else
	    TriggerClientEvent('weedz:notification', source, 'Qualcuno sta già coltivando in questo punto!')
	end
end)

RegisterServerEvent('weedz:stopApanhaWeed')
AddEventHandler('weedz:stopApanhaWeed', function()
	local _source = source
	PlayersApanhandoWeeds[_source] = false
end)

-------------------------------------------------------

-- RETURN INVENTORY TO CLIENT
RegisterServerEvent('weedz:GetUserInventory')
AddEventHandler('weedz:GetUserInventory', function(currentZone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('weedz:ReturnInventory',
	_source, 
    xPlayer.getInventoryItem('cannabis').count, 
	xPlayer.getInventoryItem('marijuana').count,
	xPlayer.getInventoryItem('acqua').count,
	xPlayer.getInventoryItem('fertilizzante').count,
	xPlayer.job.name,
	currentZone
	)
    -- IN THIS STANDALONE VERSION THE JOB, AND INVENTORY CHECK DONT COMES IN THIS VERSION, CAUSE EACH SERVER IS DIFERENT!
	-- ADD THE CHECKS HERE, TO RETURN THE PLAYER JOB TO THE CLIENT SO COPS CANT FARM, BYT IF YOU DONT WANT THAT YOU CAN CHANGE IT, AND SEND THE NUMBER OF SEEDS THE PLAYER HAVE!
	--[[ if xPlayer.job.name == 'police' or xPlayer.job.name == 'ambulance' or xPlayer.job.name == 'state' or xPlayer.job.name == 'sheriff' then
		TriggerClientEvent('weedz:notification', source, 'Non puoi piantare drogha!')
	else
		TriggerClientEvent('weedz:ReturnInventory', _source, 100, 0, currentZone)
	end ]]
end)

---------------------

function Qualidade(qualidadedados, ratio, id)
    local qualidadefinal = qualidadedados + ratio
	if qualidadefinal > 8 then qualidadefinal = 8 end
    local aleatorio = math.random(100)
	if aleatorio > 95 then
		qualidadefinal = qualidadefinal + 2
	end
	if aleatorio > 75 then
		qualidadefinal = qualidadefinal + 1
	end
	MySQL.Async.execute("UPDATE weed SET Quality=@QUALITY WHERE ID=@ii", {["@QUALITY"] = qualidadefinal, ['@ii'] = id})
end

---------------------
function savetempo()
	SetTimeout(savetimems, function()
	    local identifier = 1
        local dados   = MySQL.Sync.fetchAll('SELECT * FROM weed')
        for i=1, #dados, 1 do
		    if dados[i] ~= nil then
		        if dados[i].Spot > 0 and dados[i].Ready == 0 and dados[i].Status == 1  then
				    local passingby = dados[i].QualityCounter + 1
					MySQL.Async.execute("UPDATE weed SET QualityCounter=@QUALITYCOUNTER WHERE ID=@yo", {["@QUALITYCOUNTER"] = passingby, ['@yo'] = dados[i].ID})
			        local tempo = dados[i].Timer
					local agua = dados[i].Water
					local adubo = dados[i].Fertilizer
			        if tempo > 0 then
						if adubo == 1 then
							if weatheron == true then
								if CurrentWeather == 1 then
							        agua = agua + rainamountofwater
								    if agua > 100 then agua = 100 end
								else
								    agua = agua - totalwaterpersavetime
								end
							else
								agua = agua - totalwaterpersavetime
							end
							tempo = tempo - (savetime + fertilizerextra)
							if tempo < 0 then tempo = 0 end
							if agua < 0 then agua = 0 end
							if dados[i].Water > 0 then
							    MySQL.Async.execute("UPDATE weed SET Timer=@TIMER WHERE ID=@yo", {["@TIMER"] = tempo, ['@yo'] = dados[i].ID})
							end
							MySQL.Async.execute("UPDATE weed SET Water=@WATER WHERE ID=@yo", {["@WATER"] = agua, ['@yo'] = dados[i].ID})
						else
							if weatheron == true then
								if CurrentWeather == 1 then
									agua = agua + rainamountofwater
								    if agua > 100 then agua = 100 end
								else
                                    agua = agua - totalwaterpersavetime
								end
							else
								agua = agua - totalwaterpersavetime
							end
							tempo = tempo - savetime
							if tempo < 0 then tempo = 0 end
							if agua < 0 then agua = 0 end
				            if dados[i].Water > 0 then
							    MySQL.Async.execute("UPDATE weed SET Timer=@TIMER WHERE ID=@yo", {["@TIMER"] = tempo, ['@yo'] = dados[i].ID})
							end
							MySQL.Async.execute("UPDATE weed SET Water=@WATER WHERE ID=@yo", {["@WATER"] = agua, ['@yo'] = dados[i].ID})
						end
				    end
				end
			end
		end
		savetempo()
	end)
end

savetempo()

---------------------

