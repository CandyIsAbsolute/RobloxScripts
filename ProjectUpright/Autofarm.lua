
local library = loadstring(game:HttpGet("https://pastebin.com/raw/AN3u83ts", true))()

local mainWindow = library:CreateWindow('got damn')

local Options = {}

local Enemies = {}
local Abilities = {
	["Ab_MB1"] = "rep-3",
	["Ab_E"] = "hold-6",
	["Ab_R"] = "norm-1",
	["Ab_T"] = "norm-1",
	["Ab_F"] = "norm-1",
	["Ab_H"] = "norm-1",
	["Ab_Z"] = "norm-1",
}

do
	mainWindow:Section('')
	do
		mainWindow:Toggle('Enabled', {
			location = Options,
			flag = "enabled"
		}, function()
            if Options.enabled then
                oldpos = game:GetService('Players').LocalPlayer.Character.HumanoidRootPart.CFrame
            else
                local anim = game:GetService('TweenService'):Create(game:GetService('Players').LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(2), {CFrame = oldpos})
                anim:Play()
                anim.Completed:Wait()
            end
        end)
	end
	mainWindow:Section('')
	do
		mainWindow:Dropdown('Enemy', {
			location = Options,
			flag = "selectedEnemy",
			list = Enemies
		})
		mainWindow:Slider('Distance', {
			location = Options,
			flag = "selectedDistance",
			min = 1,
			max = 20,
			default = 8
		})
	end
	mainWindow:Section('')
	do
		for _, v in pairs(Abilities) do
			if _ ~= nil then
				mainWindow:Toggle(_:gsub('Ab_', ''), {
					location = Options,
					flag = tostring(_)
				})
			end
		end
	end
end
do
	task.spawn(function()
		for _, v in next, game:GetService("Workspace").Alive:GetChildren() do
			table.insert(Enemies, v)
		end
		game:GetService("Workspace").Alive.ChildAdded:connect(function(v)
			table.insert(Enemies, v)
		end)
		game:GetService("Workspace").Alive.ChildRemoved:connect(function(v)
			table.remove(Enemies, table.find(Enemies, v))
		end)
	end)
	task.spawn(function()
		function useAbility()
			local virtualInputManager = game:GetService('VirtualInputManager')
			for i, v in next, Abilities do
				if Options[i] == true then
					local key = i:gsub('Ab_', '')
					local todo = tostring(v)
					if todo:match('norm') then
						virtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
						task.wait()
						virtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
					elseif todo:match('rep') then
						for i = 1, tonumber(todo:split('-')[2]) do
							virtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
							task.wait()
							virtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
						end
					elseif todo:match('hold') then
						virtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
						task.wait(tonumber(todo:split('-')[2]))
						virtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
					end
				end
			end
		end
		while task.wait() do
			chr = game:GetService('Players').LocalPlayer.Character
			if Options.enabled and chr:FindFirstChild('HumanoidRootPart') ~= nil then
				chr.HumanoidRootPart.CFrame = CFrame.new(Options.selectedEnemy:WaitForChild('HumanoidRootPart').Position.X, Options.selectedEnemy.HumanoidRootPart.Position.Y + Options.selectedDistance, Options.selectedEnemy.HumanoidRootPart.Position.Z) * CFrame.Angles(-math.rad(90), 0, -math.rad(180))
				task.spawn(useAbility)
                if not chr:FindFirstChild('Summoned').Value == true then
                    local virtualInputManager = game:GetService('VirtualInputManager')
                    repeat
                        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                        wait()
                        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                    until chr:FindFirstChild('Summoned').Value == true
                end
                if 1 > Options.selectedEnemy.Humanoid.Health then
                    for _,v in next, game:GetService("Workspace").Alive:GetChildren() do
                        if v:WaitForChild('Humanoid').Health > 0 and tostring(v) == tostring(Options.selectedEnemy) then
                            Options.selectedEnemy = v
                            break
                        end
                    end
                end
			end
		end
	end)
end
