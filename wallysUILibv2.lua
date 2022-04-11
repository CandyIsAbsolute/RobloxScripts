local tweenService = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")
local ability = game:GetService("ReplicatedStorage"):FindFirstChild("Ability")
local spawn, wait = task.spawn, task.wait 

local player = game:GetService("Players").LocalPlayer
local chr = player.Character


local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/CandyIsAbsolute/RobloxScripts/main/wallysUILibv2.lua", true))()

local npcFarm = library:CreateWindow("NPC Farm")
local itemFarm = library:CreateWindow("Item Farm")
local standFarm = library:CreateWindow("Stand Farm")
local standFarmConfigs = library:CreateWindow("Configs")


local options = {
    npcFarm = {
        abilities = {}
    },
    itemFarm = {},
    standFarm = {}
}

do --update stuff
    local bVelocity = Instance.new("BodyVelocity")
	bVelocity.MaxForce = Vector3.new()
	bVelocity.Velocity = Vector3.new()
	bVelocity.Name = "bV"
    local bAngularVelocity = Instance.new("BodyAngularVelocity")
    bAngularVelocity.AngularVelocity = Vector3.new()
    bAngularVelocity.MaxTorque = Vector3.new()
    bAngularVelocity.Name = "bAV"

	bVelocity:Clone().Parent = chr.HumanoidRootPart
    bAngularVelocity:Clone().Parent = chr.HumanoidRootPart

    player.CharacterAdded:Connect(function(v)
        chr = v
        bVelocity:Clone().Parent = v:WaitForChild("HumanoidRootPart", 9e99)
        bAngularVelocity:Clone().Parent = v:WaitForChild("HumanoidRootPart", 9e99)
    end)
    for _,v in next, game:GetService("Workspace"):GetDescendants() do
        if v:IsA("Seat") then
            v:Destroy()
        end
    end
end
do --npc Farm
    local enemies = {}

    do--update enemies
        for _, v in next, game:GetService("Workspace").Alive:GetChildren() do
            enemies[v] = v
		end
		game:GetService("Workspace").Alive.ChildAdded:connect(function(v)
            enemies[v] = v
		end)
		game:GetService("Workspace").Alive.ChildRemoved:connect(function(v)
			table.remove(enemies, table.find(enemies, v))
		end)
    end

    npcFarm:Section("")
    toggleNPCFarm = npcFarm:Toggle("Enabled", {
        location = options.npcFarm,
        flag = "enabled"
    }, function()
        task.spawn(startNpcFarm)
        if options.npcFarm.enabled then
            chr:FindFirstChild("HumanoidRootPart").bV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
            chr:FindFirstChild("HumanoidRootPart").bAV.MaxTorque = Vector3.new(1/0, 1/0, 1/0)
        else
            chr:FindFirstChild("HumanoidRootPart").bV.MaxForce = Vector3.new()
            chr:FindFirstChild("HumanoidRootPart").bAV.MaxTorque = Vector3.new()
        end
        if options.itemFarm.enabled then toggleItemFarm:Set(false) end
        if options.standFarm.enabled then toggleNPCFarm:Set(false)  end
    end)
    npcFarm:Section("")
    local distance = npcFarm:Slider("Distance", {
        location = options.npcFarm,
        flag = "selectedDistance",
        min = 1, 
        default = 8,
        max = 20,
    })
    npcFarm:Section("")
    local enemy = npcFarm:Dropdown("Enemy", {
        location = options.npcFarm,
        flag = "selectedEnemy",
        list = enemies,
    })
    npcFarm:Section("")
    npcFarm:Toggle("MB1", {location = options.npcFarm.abilities, flag = "punch"}):Set(true)
    npcFarm:Toggle("E", {location = options.npcFarm.abilities, flag = "barrage"}):Set(true)
    npcFarm:Toggle("R", {location = options.npcFarm.abilities, flag = "R"}):Set(true)
    npcFarm:Toggle("T", {location = options.npcFarm.abilities, flag = "T"}):Set(true)
    npcFarm:Toggle("Y", {location = options.npcFarm.abilities, flag = "Y"})
    npcFarm:Toggle("F", {location = options.npcFarm.abilities, flag = "F"})
    npcFarm:Toggle("H", {location = options.npcFarm.abilities, flag = "H"})
    npcFarm:Toggle("J", {location = options.npcFarm.abilities, flag = "J"})
    npcFarm:Toggle("Z", {location = options.npcFarm.abilities, flag = "Z"})
    npcFarm:Toggle("X", {location = options.npcFarm.abilities, flag = "X"})
    npcFarm:Section("")

    function startNpcFarm()
        while options.npcFarm.enabled == true do wait()
            chr = player.Character
            enemy = options.npcFarm.selectedEnemy
            if chr ~= nil and enemy:FindFirstChild("HumanoidRootPart") ~= nil then
                chr.HumanoidRootPart.CFrame = CFrame.new(enemy.HumanoidRootPart.Position.X, enemy.HumanoidRootPart.Position.Y + options.npcFarm.selectedDistance, enemy.HumanoidRootPart.Position.Z) * CFrame.Angles(-math.rad(90), 0, -math.rad(180))
                
                if chr:FindFirstChild("Summoned").Value == false then
                    repeat wait() 
                        ability:FireServer("Stand Summon", {})
                    until chr:FindFirstChild("Summoned").Value == true and chr:FindFirstChild("Stand"):WaitForChild("HumanoidRootPart") ~= nil
                end
                useAbilities()
                if enemy:FindFirstChild("Humanoid") ~= nil and enemy.Humanoid.Health < 1 then
                    for _,v in next, game:GetService("Workspace").Alive:GetChildren() do
                        if v:WaitForChild("Humanoid").Health > 0 and tostring(v) == tostring(enemy) then
                            options.npcFarm.selectedEnemy = v
                            break
                        end
                    end
                end
            end
        end

    end
    function useAbilities()
        local function presskey(keyCode, time) 
            vim:SendKeyEvent(true, Enum.KeyCode[keyCode], false, game)
            wait(time)
            vim:SendKeyEvent(false, Enum.KeyCode[keyCode], false, game)
        end
        for i, v in next, options.npcFarm.abilities do
            if v == true then
                if tostring(i) == "punch" then
                    for i=1, 3 do
                        ability:FireServer("Punch", {})
                        wait()
                    end
                elseif tostring(i) == "barrage" then
                    ability:FireServer("Barrage", {true, "Hand"})
                else
                    presskey(i, 0)
                end
            end
        end
    end
end
do --item Farm
    itemFarm:Section("")
    toggleItemFarm = itemFarm:Toggle("Enabled", {
        location = options.itemFarm,
        flag = "enabled"
    }, function()
        print("?")
        spawn(startItemFarm)
        if options.npcFarm.enabled then toggleNPCFarm:Set(false) end
        if options.standFarm.enabled then toggleItemFarm:Set(false) end
    end)
    itemFarm:Section("")
    local speed = itemFarm:Slider("Speed", {
        location = options.itemFarm,
        flag = "selectedSpeed",
        min = 30,
        default = 60,
        max = 240
    })
    itemFarm:Section("")

    function startItemFarm()
        while options.itemFarm.enabled do wait()
            if options.npcFarm.enabled then toggleNPCFarm:Set(false) end
            for i, v in next, game:GetService("Workspace"):GetChildren() do
                if options.npcFarm.enabled == true then
                    break
                end
                if v:FindFirstChild("Handler") and not v:IsA("Model") and v:FindFirstChildOfClass("TouchTransmitter") then
                    local anim = tweenService:Create(chr.HumanoidRootPart, TweenInfo.new((chr.HumanoidRootPart.Position - v.Position).Magnitude / options.itemFarm.selectedSpeed), {CFrame = v.CFrame})
                    anim:Play()
                    anim.Completed:wait()
                end
            end
        end
    end
end
do --stand Farm
    local stands = {}
    local attributes = {}
    local configs = {
        {"The World OVA", "None"},
        {"Dio's The World", "None"},
        {"White Snake", "None"},
        {"Jotaro's Star Platinum", "None"},
        {"Premier Macho", "None"},
        {"Star Platinum OVA", "None"},
        {"None", "Legendary"},
    }
    do--add stands & attributes
        local blacklist = {
            [1] = "King Crimson Requiem",
            [2] = "DIO's The World Over Heaven",
            [3] = "Jotaro's Star Platinum Over Heaven",
            [4] = "Silver Chariot Requiem",
            [5] = "Made In Heaven",
            [6] = "Golden Experience Requiem",
            [7] = "The World OVA Over Heaven",
            [8] = "Star Platinum Over Heaven",
            [9] = "The Hand Requiem",
            [10] = "Star Platinum OVA Over Heaven",
            [11] = "The World Over Heaven",
            [12] = "C-Moon",
        }
        for _,v in next, require(game:GetService("Lighting").StandStats) do
            if not table.find(blacklist, v.Name) then
                stands[#stands+1] = v.Name
            end
        end
        for _,v in next, require(game:GetService("Lighting").AttributeStats) do
            attributes[#attributes+1] = v.Attribute
        end
        for _,v in next, configs do
            local stand = standFarmConfigs:Section('Stand: '..v[1])
            local attr = standFarmConfigs:Section('Attribute: '..v[2])
            standFarmConfigs:Button("Remove", function(self)
                local cache = {v[1], v[2]}
                stand:Destroy()
                attr:Destroy()
                self:Destroy()
                table.remove(configs, table.find(configs, cache))
            end)
        end
    end
    standFarm:Section("")
    toggleStandFarm = standFarm:Toggle("Enabled", {
        location = options.standFarm,
        flag = "enabled",
    }, function()
        spawn(startStandFarm)
    end)
    standFarm:Section("")
    standFarm:Dropdown("Prioritize", {
        location = options.standFarm,
        options = "prioritize",
        list = {"Attribute", "Stand", "Any", "Both"}
    }):Refresh({"Any", "Stand", "Attribute", "Both"})
    standFarm:Section("")
    standFarm:SearchBox("Select Stand", {
        location = options.standFarm,
        flag = "selectedStand",
        list = stands,
    }):Set("None")
    standFarm:SearchBox("Selected Attribute", {
        location = options.standFarm,
        flag = "selectedAttr",
        list = attributes
    }):Set("None")
    standFarm:Button("Add Config", function()
        local stand = standFarmConfigs:Section("Stand: "..tostring(options.standFarm.selectedStand)) 
        local attr = standFarmConfigs:Section("Attribute: "..tostring(options.standFarm.selectedAttr)) 
        standFarmConfigs:Button("Remove", function(self)
            local cache = {tostring(options.standFarm.selectedStand), tostring(options.standFarm.selectedAttr)}
            stand:Destroy()
            attr:Destroy()
            self:Destroy()
            table.remove(configs, table.find(configs, cache))
        end)
        table.insert(configs, {tostring(options.standFarm.selectedStand), tostring(options.standFarm.selectedAttr)})
    end)
    standFarm:Section("")
    function startStandFarm()
        local curr = player.Data.Stand.Value.."/"..player.Data.Attribute.Value
        local data = curr:split("/")
        function useItem()
            local useItem = game:GetService("ReplicatedStorage").Useitem
            if player.PlayerGui:FindFirstChild("ItemPrompt") ~= nil then
                player.PlayerGui:FindFirstChild("ItemPrompt"):Destroy()
            end
            if data[1] == "None" then
                local arr = player.Backpack:FindFirstChild("Unusual Arrow") or player.Backpack:FindFirstChild("Stand Arrow") 
                chr:WaitForChild("Humanoid", 9e9):EquipTool(arr)
                do
                    repeat wait() 
                        useItem:FireServer(arr) 
                    until player.PlayerGui:FindFirstChild("ItemPrompt") ~= nil and player.PlayerGui.ItemPrompt.Frame:FindFirstChild("Yes") ~= nil
                    local itemPrompt = player.PlayerGui:FindFirstChild("ItemPrompt").Frame
                    repeat wait(0.5)
                        vim:SendMouseButtonEvent(itemPrompt.Yes.AbsolutePosition.X + (itemPrompt.Yes.AbsoluteSize.X / 2), itemPrompt.Yes.AbsolutePosition.Y + (itemPrompt.Yes.AbsoluteSize.Y) , 0, true, game, 0)
                        wait()
                        vim:SendMouseButtonEvent(itemPrompt.Yes.AbsolutePosition.X + (itemPrompt.Yes.AbsoluteSize.X / 2), itemPrompt.Yes.AbsolutePosition.Y + (itemPrompt.Yes.AbsoluteSize.Y), 0, false, game, 0)
                    until player.PlayerGui:FindFirstChild("ItemPrompt") == nil 
                end
            else
                local roka = player.Backpack:FindFirstChild("Rokakaka")
                chr:WaitForChild("Humanoid", 9e9):EquipTool(roka)
                do
                    repeat wait() 
                        useItem:FireServer(roka) 
                    until player.PlayerGui:FindFirstChild("ItemPrompt") ~= nil and player.PlayerGui.ItemPrompt.Frame:FindFirstChild("Yes") ~= nil
                    local itemPrompt = player.PlayerGui:FindFirstChild("ItemPrompt").Frame
                    repeat wait(0.5)
                        vim:SendMouseButtonEvent(itemPrompt.Yes.AbsolutePosition.X + (itemPrompt.Yes.AbsoluteSize.X / 2), itemPrompt.Yes.AbsolutePosition.Y + (itemPrompt.Yes.AbsoluteSize.Y) , 0, true, game, 0)
                        wait()
                        vim:SendMouseButtonEvent(itemPrompt.Yes.AbsolutePosition.X + (itemPrompt.Yes.AbsoluteSize.X / 2), itemPrompt.Yes.AbsolutePosition.Y + (itemPrompt.Yes.AbsoluteSize.Y), 0, false, game, 0)
                    until player.PlayerGui:FindFirstChild("ItemPrompt") == nil
                end
            end
        end
        while options.standFarm.enabled do
            if options.standFarm.prioritize == "Attribute" then
                for _,v in next, configs do
                    if table.find(v, data[2]) then
                        toggleStandFarm:Set(false)
                        break
                    end
                end
            elseif options.standFarm.prioritize == "Stand" then
                for _,v in next, configs do
                    if table.find(v, data[1]) then
                        toggleStandFarm:Set(false)
                        break
                    end
                end
            elseif options.standFarm.prioritize == "Any" then
                for _,v in next, configs do
                    if table.find(v, data[1]) or table.find(v, data[2]) then
                        toggleStandFarm:Set(false)
                        break
                    end
                end
            elseif options.standFarm.prioritize == "Both" then
                for _,v in next, configs do
                    if table.find(v, data[1]) and table.find(v, data[2]) then
                        toggleStandFarm:Set(false)
                        break
                    end
                end
            end
            useItem()
            curr = player.Data.Stand.Value.."/"..player.Data.Attribute.Value
            data = curr:split("/")
        end
    end
end
