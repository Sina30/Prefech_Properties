local owned = {}
local Sync = {}
local blips = {}
local blips2 = {}
local notif = {}
local marker = {}
local signs = {}
local displayBlips = true

if GetResourceKvpFloat('PFPropertyBlips') == nil then
    SetResourceKvpFloat('PFPropertyBlips', 1.0)
else
    if GetResourceKvpFloat('PFPropertyBlips') == 1.0 then
        displayBlips = true
    else
        displayBlips = false
    end
end

RegisterCommand('properties', function(source, args, RawCommand)
    if displayBlips then
        SetResourceKvpFloat('PFPropertyBlips', 0.0)
        status = 'Disabled'
    else
        SetResourceKvpFloat('PFPropertyBlips', 1.0)
        status = 'Enabled'
    end
    message(('Property blips have been %s'):format(status))
    displayBlips = not displayBlips
end)

exports['chat']:addSuggestion('/sell', 'Sell a property you own.')
exports['chat']:addSuggestion('/buy', 'Buy a property.')
exports['chat']:addSuggestion('/properties', 'Disable or Enable the property blips.')


RegisterNetEvent('PFProperty:Sync')
AddEventHandler('PFProperty:Sync', function(tab)
    owned = tab
    Sync = {}
    for k,v in pairs(tab) do
        table.insert(Sync, v.Name)
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        for k,v in pairs(Config.Business) do
            if blips[k] and displayBlips then
                if not has_val(Sync,k) then
                    setBlip(k, v['marker'].blip['forsale'])
                    sign('add', k)
                else
                    setBlip(k, v['marker'].blip['sold'])
                    sign('delete', k)
                end
            end
        end
        createBlips()
    end
end)

function has_val(tab, val)
    for _, i in pairs(tab) do
        if i == val then
            return true
        end
    end
    return false
end

function sign(type, name)
    if type == 'delete' then
        if signs[name] then
            DeleteEntity(signs[name])
            signs[name] = nil
        end
    else
        if not signs[name] then
            signs[name] = CreateObject("prop_forsale_sign_05", Config.Business[name].sign.loc, true, true, false)
            Wait(1)
            SetEntityHeading(signs[name], Config.Business[name].sign.headding)
            SetEntityInvincible(signs[name])
            FreezeEntityPosition(signs[name], true)
        end
    end
end

function createBlips()
    if displayBlips then
        for k,v in pairs(Config.Business) do
            if not blips[k] then
                local blip = AddBlipForCoord(v.marker.loc)
                SetBlipSprite(blip, 375)
                SetBlipCategory(blip, 10)
                SetBlipAsShortRange(blip, true)
                blips[k] = blip
            end
        end
        for k,v in pairs(Config.Agency) do
            if not blips2[k] then
                local blip = AddBlipForCoord(v.loc)
                SetBlipSprite(blip, 442)
                SetBlipCategory(blip, 3)
                SetBlipAsShortRange(blip, true)
                blips2[k] = blip
                Wait(1)
                setBlipAgency(k, v)
            end
        end
    else
        for k,v in pairs(blips) do
           RemoveBlip(v)
           blips[k] = nil
        end
        for k,v in pairs(blips2) do
            RemoveBlip(v)
            blips2[k] = nil
         end
    end
end

function setBlip(k, v)
    SetBlipSprite(blips[k], v)
    AddTextEntry('MYBLIP'..k, Config.Business[k].name)
    BeginTextCommandSetBlipName('MYBLIP'..k)
    AddTextComponentSubstringPlayerName('me')
    EndTextCommandSetBlipName(blips[k])
end

function setBlipAgency(k, v)
    AddTextEntry('MYBLIP'..k, Config.Agency[k].name)
    BeginTextCommandSetBlipName('MYBLIP'..k)
    AddTextComponentSubstringPlayerName('me')
    EndTextCommandSetBlipName(blips2[k])
end

function message(msg)
    exports['chat']:addMessage(msg) --[[ Replace this with your notifcation resource :) ]]
end