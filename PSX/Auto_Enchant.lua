
local Library, Blacklist, BUID, BankInfo, Functions
do--//Init
    repeat wait(1) until game:IsLoaded() and game:GetService('Players').LocalPlayer ~= nil and game:GetService('Players').LocalPlayer:FindFirstChild('__LOADED')
    Library     = require(game:GetService('ReplicatedStorage').Framework:FindFirstChild('Library'))
    Functions   = Library.Functions
    Blacklist   = {}
    BUID        = Library.Network.Invoke('Get my Banks')[_G.BankIndex].BUID
    BankInfo    = Library.Network.Invoke('Get Bank', BUID)
end

do --//Checks&Functions
    table.foreach(Library.Directory.Pets, function(i, v)
        if v.rarity == "Mythical" or v.rarity == "Exclusive" then
            Blacklist[tostring(i)] = v.rarity
        end
    end)
    function GetPetInfo(uid)
        for i,v in pairs(Library.Save.Get().Pets) do
            if v.uid == uid then
                return v
            end
        end
    end
    function PetToValidTable(petpowers)
        local temptable = {}
        if petpowers then
            table.foreach(petpowers, function(i, powers)
                temptable[powers[1]] = powers[2]
            end)
        end 
        return temptable
    end
    function Time(End)
        local Hours = math.floor(math.floor(End / 60) / 60)
        local Minutes = math.floor(End / 60)
        local Seconds = math.floor(End)
        local MilliSeconds = (End * 100)
        local Format = ""
        if Hours > 0 then
            Format = Format..string.format("%d:", Hours % 60)
        end
        if Minutes > 0 then
            Format = Format..string.format("%d:", Minutes % 60)
        end
        if Seconds > 0 then
            Format = Format..string.format("%d.", Seconds % 60)
        end
        if MilliSeconds > 0 then
            Format = Format..string.format("%dms", MilliSeconds)
        end
        return Format
    end
end

do--//AutoEnch
    for i,v in pairs(Library.Save.Get().Pets) do
        if v.e and not Blacklist[v.id] and _G.Stop ~= true then
            local HasPower = false
            local startTime = tick()
            spawn(function()
                repeat
                    if not Library.Functions.CompareTable(_G.Wanted, PetToValidTable(GetPetInfo(v.uid).powers)) and not HasPower and not _G.Stop then
                        if #GetPetInfo(v.uid).powers > 1 then
                            warn('Pet: '..v.nk..'('..v.uid..')')
                            warn("      ", GetPetInfo(v.uid).powers[1][1], Functions.ToRomanNum(GetPetInfo(v.uid).powers[1][2]))
                            warn("      ", GetPetInfo(v.uid).powers[2][1], Functions.ToRomanNum(GetPetInfo(v.uid).powers[2][2]).."\n------------")
                        else
                            table.foreach(GetPetInfo(v.uid).powers, function(_, __)
                                warn('Pet: '..v.nk..'('..v.uid..')')
                                warn("      ",__[1],Functions.ToRomanNum(__[2]).."\n------------")
                            end)
                        end
                        Library.Network.Invoke("Enchant Pet", v.uid)
                    else
                        local _end = tick() - startTime
                        warn('Pet: '..v.nk..'('..v.uid..')'.." has wanted enchants. It took:", Time(_end))
                        HasPower = true
                    end
                    if Library.Save.Get().Diamonds < 500000 and _G.Stop ~= true and _G.AutoWithdraw then
                        Library.Network.Invoke('Bank withdraw', BUID, (function()
                            if (1000000000000 - BankInfo.Storage.Currency.Diamonds) > 25000000000 then
                                return (25000000000 - Library.Save.Get().Diamonds) 
                            else
                                return (1000000000000 - BankInfo.Storage.Currency.Diamonds) 
                            end
                        end))
                    end
                    task.wait()
                until HasPower == true or _G.Stop 
            end)
        end
    end
end
