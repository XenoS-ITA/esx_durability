ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_durability:update')
AddEventHandler('esx_durability:update', function(itemName)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)

	local identifier = GetPlayerIdentifiers(source)[1]

		local durability = MySQL.Sync.fetchScalar("SELECT durability FROM user_inventory WHERE identifier = @identifier AND item = @item", 
		{
			['@identifier'] 	= identifier,
			['@item']			= itemName
		})

		if durability > 1 then
			MySQL.Async.execute("UPDATE user_inventory SET durability = @durability WHERE identifier = @identifier AND item = @item",
			{
				['@identifier']		= identifier,
				['@item']			= itemName,
				['@durability']		= durability - 1
			})
			if Config.Debug then
				print("the durability of the item :" .. itemName .. " for the player :" .. identifier .. "has been lowered by 1")
				print("")
				print("the oldest durability is " .. durability)
				print("the new durability is " .. durability - 1)
			end
		elseif durability == 1 then
			if Config.Debug then
				print("Player :" .. identifier .. " - the durability of the item :" .. itemName .. " was at 0 and was been removed")
			end

            
			------------------------------------------------------------------------------------------- CHANGE THE TEXT OF MESSAGE HERE
			if Config.MythicNotify then
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 	   'The object was broken!'})
			else

				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 								   '~r~The object was broken!')
			end
            ------------------------------------------------------------------------------------------- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


			MySQL.Async.execute("UPDATE user_inventory SET durability = @durability, count = @count WHERE identifier = @identifier AND item = @item",
			{
				['@identifier']		= identifier,
				['@item']			= itemName,
				['@durability']		= 0,
				['@count']			= 0
			})

			sourceXPlayer.removeInventoryItem(itemName, 1)
		elseif durability == 0 then

			MySQL.Async.execute("UPDATE user_inventory SET durability = @durability WHERE identifier = @identifier AND item = @item",
			{
				['@identifier']		= identifier,
				['@item']			= itemName,
				['@durability']		= Config.MaxDurability
			})
			if Config.Debug then
				print("default durability setted for item : " .. itemName .. " of player :"  .. identifier)
				print("the new durability is " .. Config.MaxDurability)
			end
		end
end)