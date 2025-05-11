
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/CandyIsAbsolute/RobloxScripts/main/wallysUILibv2.lua", true))()

local LocalPlayer = game:GetService("Players").LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local wait = task.wait

local Function  = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteFunction
local Event = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent

local BoardUtil = require(ReplicatedStorage.Shared.Utils.BoardUtil)

--Dice
local AutoDice = Library:CreateWindow("Smart Dice") do
    local StatusText = ""

    AutoDice:Section("made by ydnac#2110")
    local AutoRoll, DefaultDice, GoldenDice
    AutoRoll = AutoDice:Toggle("Auto Roll", {})
    AutoDice:Section("Configuration").Self:FindFirstChild("section_lbl").TextColor3 = Color3.new(0.662745, 0.403921, 1)
    DefaultDice = AutoDice:Dropdown("Default Dice", {
        list = {
            "Dice",
            "Giant Dice",
            "Golden Dice"
        }
    })
    AutoDice:Section("Depth Settings")
    GoldenDice = AutoDice:Slider("Golden Dice <", {
        min = 1,
        max = 6,
        default = 3
    })
    
    local Status = AutoDice:Section("test").Self
    local LastRolled = AutoDice:Section("test").Self

    local function RollDice(DiceType)
        local Returned
        repeat wait()
            Returned = Function:InvokeServer("RollDice", DiceType)
            Event:FireServer("ClaimTile")
        until Returned ~= nil
        return Returned.Tile.Index
    end
    local function NextDice(TileIndex)
        print(TileIndex)
        for Tile=1, 10 do
            local TileIndex = TileIndex+Tile

            if TileIndex > 88 then
                StatusText = `Reached the end of the game board, starting over.`
                return "Dice"
            end

            if BoardUtil.Nodes[TileIndex].Type == "infinity" then
                StatusText = `Infinity Elixir at Tile: {Tile} | TileIndex: {TileIndex}`
                print(Tile, GoldenDice.Flag)
                if Tile <= GoldenDice.Flag then
                    return "Golden Dice"
                end
                if Tile > GoldenDice.Flag and Tile < 9 then
                    return "Dice"
                end 
                if Tile >= 9 then
                    return "Giant Dice"
                end
            end
        end
        StatusText = `Current tile: {BoardUtil.Nodes[TileIndex].Type} | TileIndex: {TileIndex}`
        return DefaultDice.Flag
    end

    local Rolled = RollDice("Dice")
    task.spawn(function()
        while true do
            if AutoRoll.Flag then
                print("ASFASF???")
                print(NextDice(Rolled))
                Rolled = RollDice(NextDice(Rolled))
            end

            do -- etc
                Status:FindFirstChild("section_lbl").Text = StatusText
                LastRolled:FindFirstChild("section_lbl").Text = "*BRAAAAAAAP*!"
            end
            wait()
        end
    end)
end
local AutoClaw = Library:CreateWindow("Robot Claw") do
    AutoClaw:Section("")
    local ClawToggledFast, ClawToggled, Difficulty, AutoRewards
    ClawToggledFast = AutoClaw:Toggle("Auto Claw [FAST]", {}, function()
        if not ClawToggledFast.Flag then
            Event:FireServer("FinishMinigame")
            pcall(function()
                workspace:FindFirstChild('ClawMachine'):Destroy()
            end)
        end
    end)
    ClawToggled = AutoClaw:Toggle("Auto Claw", {}, function()
        if ClawToggled.Flag then
            task.spawn(function()
                Event:FireServer("FinishMinigame")
                Event:FireServer("SkipMinigameCooldown", "Robot Claw")
                wait(2)
                Event:FireServer("StartMinigame", "Robot Claw", Difficulty.Flag)            
            end)
        else
            Event:FireServer("FinishMinigame")
            pcall(function()
                workspace:FindFirstChild('ClawMachine'):Destroy()
            end)
        end
    end)
    AutoClaw:Section("Configuration").Self:FindFirstChild("section_lbl").TextColor3 = Color3.new(0.662745, 0.403921, 1)
    Difficulty = AutoClaw:Dropdown("Difficulty", {
        list = {
            "Insane",
            "Hard",
            "Medium",
            "Easy"
        },
    })
    AutoRewards = AutoClaw:Toggle("Auto Claim Rewards", {default = true})
    local function ClickButton(Button)
        local pos   = Button.AbsolutePosition
        local size  = Button.AbsoluteSize
        local x     = pos.X + size.X/2
        local y     = (pos.Y + size.Y*1.5)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, Button, 0)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, Button, 0)
    end
    task.spawn(function()
        -- local special_wait;special_wait = hookfunction(task.wait, function(a)
        --     if not checkcaller() and ClawToggledFast.Flag then
        --         a = 0
        --     end
        --     return special_wait(a)
        -- end)
        local RobotClaw = require(game:GetService("ReplicatedStorage").Client.Gui.Frames.Minigames["Robot Claw"])
        local instant_finish; instant_finish = hookfunction(RobotClaw, function(a)
            local cleanup, useless = instant_finish(a)
            if ClawToggledFast.Flag and not ClawToggled.Flag then
                cleanup() 
            end
            return cleanup, useless
        end)

        workspace.ChildAdded:Connect(function(Child)
            if ClawToggled.Flag and not ClawToggledFast.Flag and tostring(Child) == "ClawMachine" then
                local ClawMachine = Child
                wait(2)
                local FirstItem = ClawMachine:FindFirstChild("Capsule")
                Event:FireServer("GrabMinigameItem", FirstItem:GetAttribute("ItemGUID"))
                FirstItem:Destroy()

                for _,v in ClawMachine:GetChildren() do
                    if tostring(v) == "Capsule" then
                        task.wait(3.25)
                        Event:FireServer("GrabMinigameItem", v:GetAttribute("ItemGUID"))
                        v:Destroy()
                    end
                end
                wait(.5)
                Event:FireServer("FinishMinigame")
            end
        end)
        workspace.ChildRemoved:Connect(function(Child)
            if ClawToggled.Flag and not ClawToggledFast.Flag and tostring(Child) == "ClawMachine" then
                Event:FireServer("SkipMinigameCooldown", "Robot Claw")
                Event:FireServer("StartMinigame", "Robot Claw", Difficulty.Flag)
            end
        end)

        while true do
            if ClawToggledFast.Flag and not ClawToggled.Flag then
                Event:FireServer("StartMinigame", "Robot Claw", Difficulty.Flag)
                Event:FireServer("FinishMinigame")
                Event:FireServer("SkipMinigameCooldown", "Robot Claw")
            end
            if AutoRewards.Flag then
                pcall(function()
                    ClickButton(LocalPlayer.PlayerGui.ScreenGui.Prompt.Frame.Main.Buttons.Template.Button) 
                end)
            end
            wait()
        end
    end)
    AutoClaw:Section("plain auto claw gets everything")
    AutoClaw:Section("and it's 13/s faster [Insane]")
    AutoClaw:Section("dont have both enabled or you die")
end
