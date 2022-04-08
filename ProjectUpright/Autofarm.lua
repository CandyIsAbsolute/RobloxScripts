local tweenService = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")
local ability = game:GetService("ReplicatedStorage"):FindFirstChild("Ability")
local spawn, wait = task.spawn, task.wait 

local player = game:GetService("Players").LocalPlayer
local chr = player.Character


local library = loadstring(game:HttpGet("https://pastebin.com/raw/ikz1WLPr", true))()

local npcFarm = library:CreateWindow("NPC Farm")
--local itemFarm = library:CreateWindow("Item Farm")

local options = {
    npcFarm = {
        abilities = {}
    },
    itemFarm = {}
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
end

do --npcFarm
    local enemies = {}

    do--update enemies
        for _, v in next, game:GetService("Workspace").Alive:GetChildren() do
			table.insert(enemies, v)
		end
		game:GetService("Workspace").Alive.ChildAdded:connect(function(v)
			table.insert(enemies, v)
		end)
		game:GetService("Workspace").Alive.ChildRemoved:connect(function(v)
			table.remove(enemies, table.find(enemies, v))
		end)
    end

    npcFarm:Section("")
    local toggle = npcFarm:Toggle("Enabled", {
        location = options.npcFarm,
        flag = "enabled"
    }, function()
        task.spawn(startNpcFarm)
        if options.npcFarm.enabled then
            chr:FindFirstChild('HumanoidRootPart').bV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
            chr:FindFirstChild('HumanoidRootPart').bAV.MaxTorque = Vector3.new(1/0, 1/0, 1/0)
        else
            chr:FindFirstChild('HumanoidRootPart').bV.MaxForce = Vector3.new()
            chr:FindFirstChild('HumanoidRootPart').bAV.MaxTorque = Vector3.new()
        end
    end)

    npcFarm:Section("")
    local distance = npcFarm:Slider("Distance", {
        location = options.npcFarm,
        flag = "selectedDistance",
        min = 1, 
        max = 20,
        default = 8,
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
                    until chr:FindFirstChild("Summoned").Value == true and chr:FindFirstChild('Stand').HumanoidRootPart ~= nil
                end
                useAbilities()
                if enemy:FindFirstChild('Humanoid') ~= nil and enemy.Humanoid.Health < 1 then
                    for _,v in next, game:GetService("Workspace").Alive:GetChildren() do
                        if v:WaitForChild('Humanoid').Health > 0 and tostring(v) == tostring(enemy) then
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
                        ability:FireServer('Punch', {})
                        wait()
                    end
                elseif tostring(i) == "barrage" then
                    ability:FireServer('Barrage', {true, 'Hand'})
                else
                    presskey(i, 0)
                end
            end
        end
    end
end
