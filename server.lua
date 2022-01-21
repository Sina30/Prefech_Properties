local owned = {}
local temp = {}

RegisterCommand('buy', function(source, args, RawCommand)
    local id = ExtractIdentifiers(source)
    for k,v in pairs(Config.Business) do
        if #(v['sign'].loc - GetEntityCoords(GetPlayerPed(source))) <= v.range then
            if checkOwned(k) then
                if owned[id] then
                    return message(source, 'You can only have one property at a time.')
                end
                return buyProperty(source, args, RawCommand, k, id)
            end
        end
    end

    for k,v in pairs(Config.Agency) do
        if #(v.loc - GetEntityCoords(GetPlayerPed(source))) <= v.range then
            if args[1] then
                local k = table.concat(args, ""):lower()
                if Config.Business[k] then
                    if checkOwned(k) then
                        if owned[id] then
                            return message(source, 'You can only have one property at a time.')
                        end
                        return buyProperty(source, args, RawCommand, k, id)
                    end
                else
                    return message(source, ('It doesn\t look like^1 %s ^0is a property you can buy. ^1Please check your spelling.^0'):format(table.concat(args, "")))
                end
            else
                return message(source, 'Please use: /buy [Property Name].')
            end
        end
    end
end)

RegisterCommand('sell', function(source, args, RawCommand)
    local id = ExtractIdentifiers(source)
    if not owned[id] then
        return message(source, 'You don\'t own any properties you can sell.')
    end
    if args[1] ~= 'confirm' then
        return message(source, ('Please use ^1/sell confirm^0 if you want to sell the %s'):format(Config.Business[owned[id].Name].name))
    end
    message(-1, ('%s has sold the %s'):format(GetPlayerName(source), Config.Business[owned[id].Name].name))
    owned[id] = nil
    TriggerClientEvent('PFProperty:Sync', -1, owned)
end)

AddEventHandler("playerJoining", function(source, oldID)
	TriggerClientEvent('PFProperty:Sync', source, owned)
end)

function buyProperty(source, args, RawCommand, k, id)
    owned[id] = {
        ['Name'] = k,
        ['Owner'] = GetPlayerName(source)
    }
    TriggerClientEvent('PFProperty:Sync', -1, owned)
    message(-1, ('%s has bought the %s'):format(GetPlayerName(source), Config.Business[k].name))
end

function ExtractIdentifiers(src)
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "license:") then
            return id
        end
    end
    return
end

function checkOwned(x)
    for k,v in pairs(owned) do table.insert(temp, v.Name) end
    if not has_val(temp, x) then
        temp = {}
        return true
    end
    temp = {}
    return false
end

function has_val(tab, val)
    for _, i in pairs(tab) do
        if i == val then
            return true
        end
    end
    return false
end

function message(target, msg)
    exports['chat']:addMessage(target, msg) --[[ Replace this with your notifcation resource :) ]]
end


--[[

-- This is what i used to add the properties faster.
-- just use the command /sc [Name] to get the marker location and then walk to where you want the sign and run the command again.
-- Keep going until you have added everything you want and there should be a file in your server-data folder (where your resource folder is) with the saved coords. :)

]]

if Config.DevTools then
    saves = {}
    RegisterCommand('sc', function(source, args, RawCommand)
        if not args[1] then
        return message(source, '/sc [name]')
        end
        if saves['marker'] ~= nil then
            local name = table.concat(args, " ")
            local bname = table.concat(args, ""):lower()
            local ploc = GetEntityCoords(GetPlayerPed(source))
            local heading = GetEntityHeading(GetPlayerPed(source))
            local string = ("['%s'] = { name = '%s', marker = { loc = vec3(%s, %s, %s), blip =  { forsale = 375, sold = 374 } }, sign = { loc = vec3(%s, %s, %s - 1.0), headding = %s }, range = 2 },\n"):format(bname, name, decimal(saves['marker'].x), decimal(saves['marker'].y), decimal(saves['marker'].z), decimal(ploc.x), decimal(ploc.y), decimal(ploc.z), decimal(heading))
            addToFile(string, 'savedcoords.lua')
            saves['marker'] = nil
            message(source, 'Saved in file.')
        else
            saves['marker'] = GetEntityCoords(GetPlayerPed(source))
            message(source, 'Map marker saved. Run the command again to finish.')
        end
    end)

    function addToFile(srting, file)
        file = io.open(file, 'a')
        io.output(file)
        local data = srting
        io.write(data)
        io.close(file)
    end

    function decimal(i)
        return math.floor(i * 100) / 100
    end
end