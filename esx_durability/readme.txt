open the folder of esx_inventoryhud


Go to line 205 and add this 

TriggerServerEvent("esx_durability:update", data.item.name)


just below this

TriggerServerEvent("esx:useItem", data.item.name)