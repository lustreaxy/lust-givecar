local letters = 'ABCDEFGHIJKLMNPORSTWUXYZ1234567890'

local function generatePlate()
    local plate = ''
    repeat
        for i = 1, 8 do
            local random = math.random(1, letters:len())
            local letter = letters:sub(random, random)
            plate = plate..''..letter
        end
    until (not MySQL.single.await('SELECT * FROM owned_vehicles WHERE plate = ? LIMIT 1', {plate}))
    return plate
end

ESX.RegisterCommand('givecar', {'owner', 'best', 'admin'}, function(xPlayer, args, showError)
    if not args.playerId then
        return xPlayer.showNotification('Podaj ID Gracza')
    end

    if not args.model then
        return xPlayer.showNotification('Podaj model pojazdu')
    end
    
    local xTarget = ESX.GetPlayerFromId(args.playerId)
    if not xTarget then
        return xPlayer.showNotification('Gracz o takim ID jest niedostępny')
    end

    local newPlate = generatePlate()
    MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type, job) VALUES (?, ?, ?, ?, ?, ?)', {
        xTarget.identifier, newPlate, json.encode({model = args.model, plate = newPlate, fuelLevel = 100, engineHealth = 1000, bodyHealth = 1000}), 1, 'car', args.job
    }, function(affectedRows)
        if affectedRows > 0 then
            xPlayer.showNotification(('Nadano pojazd %s dla %s'):format(args.model, xTarget.getName()))
        end
    end)
end, true, {help = 'Nadaj pojazd', arguments = {
    {name = 'playerId', help = 'ID Gracza', type = 'number'},
    {name = 'model', help = 'Model pojazdu', type = 'string'},
    {name = 'job', help = 'Praca (Opcjonalne)', type = 'string'},
}})
