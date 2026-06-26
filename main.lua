-- ==================== SOFT STATIC HUB ====================
-- Grow a Garden 2 | discord.gg/nyhH3MvWmG

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ==================== CONFIG (no secrets here) ====================
local API_URL = "https://softstatic-keys.vercel.app/api/validate"
local LOOTLAB_URL = "https://loot-link.com/s?CCtVwXpS"
local DISCORD = "discord.gg/nyhH3MvWmG"

-- ==================== UNIVERSAL HTTP ====================
local function httpRequest(options)
    if syn and syn.request then
        return syn.request(options)
    elseif request then
        return request(options)
    elseif http and http.request then
        return http.request(options)
    elseif http_request then
        return http_request(options)
    elseif fluxus and fluxus.request then
        return fluxus.request(options)
    else
        error("No HTTP request function found")
    end
end

-- ==================== UNIVERSAL CLIPBOARD ====================
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    elseif Clipboard and Clipboard.set then
        Clipboard.set(text)
    elseif syn and syn.setclipboard then
        syn.setclipboard(text)
    end
end

-- ==================== HWID ====================
local function getHWID()
    return tostring(player.UserId) .. "_" .. tostring(game.JobId):sub(1, 8)
end
local HWID = getHWID()

-- ==================== STATE ====================
local State = {
    isDupeOn = false,
    isFlyOn = false,
    isNoclipOn = false,
    speed = 16,
    jumpPower = 50,
    flySpeed = 50,
    bodyVelocity = nil,
    bodyGyro = nil,
}

-- ==================== SCREEN GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SoftStaticHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function setupGui()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    elseif protect_gui then
        protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    else
        local ok = pcall(function()
            ScreenGui.Parent = game:GetService("CoreGui")
        end)
        if not ok then
            ScreenGui.Parent = player:WaitForChild("PlayerGui")
        end
    end
end
setupGui()

-- ==================== HELPERS ====================
local function makeTween(obj, props, t, style, dir)
    return TweenService:Create(obj, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function makeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function openURL(url)
    local ok = pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow(url)
    end)
    if not ok then
        copyToClipboard(url)
    end
end

-- ==================== COLORS ====================
local C = {
    bg =          Color3.fromRGB(8, 8, 14),
    card =        Color3.fromRGB(14, 14, 22),
    accent =      Color3.fromRGB(0, 210, 200),
    accentDim =   Color3.fromRGB(0, 140, 133),
    accentDark =  Color3.fromRGB(0, 40, 38),
    text =        Color3.fromRGB(235, 235, 255),
    textDim =     Color3.fromRGB(120, 122, 145),
    textMuted =   Color3.fromRGB(50, 52, 70),
    border =      Color3.fromRGB(22, 24, 38),
    toggleOff =   Color3.fromRGB(20, 20, 32),
    knobOff =     Color3.fromRGB(65, 68, 95),
    red =         Color3.fromRGB(255, 75, 75),
    sliderBg =    Color3.fromRGB(16, 16, 26),
}

-- ==================== KEY SCREEN ====================
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.new(0, 360, 0, 240)
KeyFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
KeyFrame.BackgroundColor3 = C.bg
KeyFrame.BorderSizePixel = 0
KeyFrame.Parent = ScreenGui

makeCorner(KeyFrame, 16)
makeStroke(KeyFrame, C.accent, 1.5)

local KeyGlow = Instance.new("ImageLabel")
KeyGlow.Size = UDim2.new(1, 80, 1, 80)
KeyGlow.Position = UDim2.new(0, -40, 0, -40)
KeyGlow.BackgroundTransparency = 1
KeyGlow.Image = "rbxassetid://6014261993"
KeyGlow.ImageColor3 = C.accent
KeyGlow.ImageTransparency = 0.84
KeyGlow.ScaleType = Enum.ScaleType.Slice
KeyGlow.SliceCenter = Rect.new(49, 49, 450, 450)
KeyGlow.ZIndex = -1
KeyGlow.Parent = KeyFrame

local KTitle = Instance.new("TextLabel")
KTitle.Size = UDim2.new(1, 0, 0, 28)
KTitle.Position = UDim2.new(0, 0, 0, 24)
KTitle.BackgroundTransparency = 1
KTitle.Font = Enum.Font.GothamBold
KTitle.Text = "⚡ Soft Static"
KTitle.TextColor3 = C.text
KTitle.TextSize = 22
KTitle.Parent = KeyFrame

local KSub = Instance.new("TextLabel")
KSub.Size = UDim2.new(1, 0, 0, 16)
KSub.Position = UDim2.new(0, 0, 0, 54)
KSub.BackgroundTransparency = 1
KSub.Font = Enum.Font.Gotham
KSub.Text = "Enter your key to continue"
KSub.TextColor3 = C.textDim
KSub.TextSize = 11
KSub.Parent = KeyFrame

local InputBg = Instance.new("Frame")
InputBg.Size = UDim2.new(1, -48, 0, 40)
InputBg.Position = UDim2.new(0, 24, 0, 84)
InputBg.BackgroundColor3 = C.card
InputBg.BorderSizePixel = 0
InputBg.Parent = KeyFrame
makeCorner(InputBg, 8)
local InputStroke = makeStroke(InputBg, C.border, 1)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.Text = ""
KeyInput.PlaceholderText = "SS-XXXX-XXXX-XXXX"
KeyInput.PlaceholderColor3 = C.textMuted
KeyInput.TextColor3 = C.text
KeyInput.TextSize = 13
KeyInput.ClearTextOnFocus = false
KeyInput.Parent = InputBg

KeyInput.Focused:Connect(function()
    makeTween(InputStroke, {Color = C.accent}):Play()
end)
KeyInput.FocusLost:Connect(function()
    makeTween(InputStroke, {Color = C.border}):Play()
end)

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, -48, 0, 14)
KeyStatus.Position = UDim2.new(0, 24, 0, 130)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Font = Enum.Font.Gotham
KeyStatus.Text = ""
KeyStatus.TextColor3 = C.textDim
KeyStatus.TextSize = 10
KeyStatus.TextXAlignment = Enum.TextXAlignment.Left
KeyStatus.Parent = KeyFrame

local BtnRow = Instance.new("Frame")
BtnRow.Size = UDim2.new(1, -48, 0, 42)
BtnRow.Position = UDim2.new(0, 24, 0, 152)
BtnRow.BackgroundTransparency = 1
BtnRow.Parent = KeyFrame

local BtnLayout = Instance.new("UIListLayout")
BtnLayout.FillDirection = Enum.FillDirection.Horizontal
BtnLayout.Padding = UDim.new(0, 10)
BtnLayout.Parent = BtnRow

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.48, 0, 1, 0)
GetKeyBtn.BackgroundColor3 = C.accentDark
GetKeyBtn.Text = "🔗 Get Key"
GetKeyBtn.TextColor3 = C.accent
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 12
GetKeyBtn.AutoButtonColor = false
GetKeyBtn.LayoutOrder = 1
GetKeyBtn.Parent = BtnRow
makeCorner(GetKeyBtn, 8)
makeStroke(GetKeyBtn, C.accentDim, 1)

GetKeyBtn.MouseEnter:Connect(function()
    makeTween(GetKeyBtn, {BackgroundColor3 = Color3.fromRGB(0, 55, 52)}):Play()
end)
GetKeyBtn.MouseLeave:Connect(function()
    makeTween(GetKeyBtn, {BackgroundColor3 = C.accentDark}):Play()
end)
GetKeyBtn.MouseButton1Click:Connect(function()
    copyToClipboard(LOOTLAB_URL)
    openURL(LOOTLAB_URL)
    KeyStatus.Text = "🔗 Link copied! Paste in browser."
    KeyStatus.TextColor3 = C.accent
    task.wait(2)
    KeyStatus.Text = "After completing go to: softstatic-keys.vercel.app"
    KeyStatus.TextColor3 = C.textDim
end)

local CheckKeyBtn = Instance.new("TextButton")
CheckKeyBtn.Size = UDim2.new(0.48, 0, 1, 0)
CheckKeyBtn.BackgroundColor3 = C.accent
CheckKeyBtn.Text = "✓ Check Key"
CheckKeyBtn.TextColor3 = C.bg
CheckKeyBtn.Font = Enum.Font.GothamBold
CheckKeyBtn.TextSize = 12
CheckKeyBtn.AutoButtonColor = false
CheckKeyBtn.LayoutOrder = 2
CheckKeyBtn.Parent = BtnRow
makeCorner(CheckKeyBtn, 8)

CheckKeyBtn.MouseEnter:Connect(function()
    makeTween(CheckKeyBtn, {BackgroundColor3 = Color3.fromRGB(100, 230, 220)}):Play()
end)
CheckKeyBtn.MouseLeave:Connect(function()
    makeTween(CheckKeyBtn, {BackgroundColor3 = C.accent}):Play()
end)

local KFooter = Instance.new("TextLabel")
KFooter.Size = UDim2.new(1, 0, 0, 14)
KFooter.Position = UDim2.new(0, 0, 1, -18)
KFooter.BackgroundTransparency = 1
KFooter.Font = Enum.Font.Gotham
KFooter.Text = DISCORD
KFooter.TextColor3 = C.textMuted
KFooter.TextSize = 9
KFooter.Parent = KeyFrame

-- ==================== KEY VALIDATION ====================
local function validateKey(key)
    KeyStatus.Text = "⏳ Validating key..."
    KeyStatus.TextColor3 = C.textDim

    local ok, result = pcall(function()
        return httpRequest({
            Url = API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
            },
            Body = HttpService:JSONEncode({
                key = key,
                hwid = HWID,
            })
        })
    end)

    if not ok then
        KeyStatus.Text = "✗ Connection failed. Try again."
        KeyStatus.TextColor3 = C.red
        return false
    end

    local data
    local parseOk = pcall(function()
        data = HttpService:JSONDecode(result.Body)
    end)

    if not parseOk or not data then
        KeyStatus.Text = "✗ Server error. Try again."
        KeyStatus.TextColor3 = C.red
        return false
    end

    if not data.valid then
        local msg = data.error or "Invalid key"
        if msg == "Key locked to another device" then
            KeyStatus.Text = "✗ Key locked to another device."
        elseif msg == "Key expired" then
            KeyStatus.Text = "✗ Key expired. Get a new one."
        else
            KeyStatus.Text = "✗ " .. msg
        end
        KeyStatus.TextColor3 = C.red
        return false
    end

    KeyStatus.Text = "✓ Key valid! Loading hub..."
    KeyStatus.TextColor3 = C.accent
    return true
end

-- ==================== MAIN HUB ====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 430)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -215)
MainFrame.BackgroundColor3 = C.bg
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

makeCorner(MainFrame, 14)
makeStroke(MainFrame, C.accent, 1.5)

local MainGlow = Instance.new("ImageLabel")
MainGlow.Size = UDim2.new(1, 80, 1, 80)
MainGlow.Position = UDim2.new(0, -40, 0, -40)
MainGlow.BackgroundTransparency = 1
MainGlow.Image = "rbxassetid://6014261993"
MainGlow.ImageColor3 = C.accent
MainGlow.ImageTransparency = 0.84
MainGlow.ScaleType = Enum.ScaleType.Slice
MainGlow.SliceCenter = Rect.new(49, 49, 450, 450)
MainGlow.ZIndex = -1
MainGlow.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local HTitle = Instance.new("TextLabel")
HTitle.Size = UDim2.new(1, -55, 0, 24)
HTitle.Position = UDim2.new(0, 16, 0, 10)
HTitle.BackgroundTransparency = 1
HTitle.Font = Enum.Font.GothamBold
HTitle.Text = "⚡ Soft Static"
HTitle.TextColor3 = C.text
HTitle.TextSize = 17
HTitle.TextXAlignment = Enum.TextXAlignment.Left
HTitle.Parent = Header

local HSub = Instance.new("TextLabel")
HSub.Size = UDim2.new(1, -55, 0, 14)
HSub.Position = UDim2.new(0, 16, 0, 34)
HSub.BackgroundTransparency = 1
HSub.Font = Enum.Font.Gotham
HSub.Text = "Grow a Garden 2"
HSub.TextColor3 = C.accent
HSub.TextSize = 10
HSub.TextXAlignment = Enum.TextXAlignment.Left
HSub.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -40, 0, 12)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = C.textDim
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextSize = 28
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

CloseBtn.MouseEnter:Connect(function() makeTween(CloseBtn, {TextColor3 = C.red}):Play() end)
CloseBtn.MouseLeave:Connect(function() makeTween(CloseBtn, {TextColor3 = C.textDim}):Play() end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -32, 0, 1)
Divider.Position = UDim2.new(0, 16, 0, 52)
Divider.BackgroundColor3 = C.border
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, -62)
Scroll.Position = UDim2.new(0, 0, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 2
Scroll.ScrollBarImageColor3 = C.accentDim
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = MainFrame

local SLayout = Instance.new("UIListLayout")
SLayout.SortOrder = Enum.SortOrder.LayoutOrder
SLayout.Padding = UDim.new(0, 6)
SLayout.Parent = Scroll

local SPad = Instance.new("UIPadding")
SPad.PaddingLeft = UDim.new(0, 14)
SPad.PaddingRight = UDim.new(0, 14)
SPad.PaddingTop = UDim.new(0, 6)
SPad.PaddingBottom = UDim.new(0, 14)
SPad.Parent = Scroll

local function sectionLabel(text, order)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.Text = text
    l.TextColor3 = C.accent
    l.TextSize = 9
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = order
    l.Parent = Scroll
end

local function toggleRow(title, desc, order, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 54)
    card.BackgroundColor3 = C.card
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = Scroll
    makeCorner(card, 8)
    makeStroke(card, C.border, 1)

    local t1 = Instance.new("TextLabel")
    t1.Size = UDim2.new(1, -70, 0, 18)
    t1.Position = UDim2.new(0, 12, 0, 9)
    t1.BackgroundTransparency = 1
    t1.Font = Enum.Font.GothamBold
    t1.Text = title
    t1.TextColor3 = C.text
    t1.TextSize = 12
    t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.Parent = card

    local t2 = Instance.new("TextLabel")
    t2.Size = UDim2.new(1, -70, 0, 14)
    t2.Position = UDim2.new(0, 12, 0, 29)
    t2.BackgroundTransparency = 1
    t2.Font = Enum.Font.Gotham
    t2.Text = desc
    t2.TextColor3 = C.textDim
    t2.TextSize = 10
    t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.Parent = card

    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0, 44, 0, 22)
    tog.Position = UDim2.new(1, -56, 0.5, -11)
    tog.BackgroundColor3 = C.toggleOff
    tog.Text = ""
    tog.AutoButtonColor = false
    tog.Parent = card
    makeCorner(tog, 20)
    local ts = makeStroke(tog, C.border, 1.5)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = C.knobOff
    knob.BorderSizePixel = 0
    knob.Parent = tog
    makeCorner(knob, 20)

    local on = false
    tog.MouseButton1Click:Connect(function()
        on = not on
        if on then
            makeTween(tog, {BackgroundColor3 = C.accentDim}, 0.2):Play()
            makeTween(ts, {Color = C.accent}, 0.2):Play()
            makeTween(knob, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.25, Enum.EasingStyle.Back):Play()
        else
            makeTween(tog, {BackgroundColor3 = C.toggleOff}, 0.2):Play()
            makeTween(ts, {Color = C.border}, 0.2):Play()
            makeTween(knob, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = C.knobOff}, 0.25, Enum.EasingStyle.Back):Play()
        end
        callback(on)
    end)
end

local function sliderRow(title, min, max, default, order, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 64)
    card.BackgroundColor3 = C.card
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = Scroll
    makeCorner(card, 8)
    makeStroke(card, C.border, 1)

    local t1 = Instance.new("TextLabel")
    t1.Size = UDim2.new(1, -70, 0, 16)
    t1.Position = UDim2.new(0, 12, 0, 8)
    t1.BackgroundTransparency = 1
    t1.Font = Enum.Font.GothamBold
    t1.Text = title
    t1.TextColor3 = C.text
    t1.TextSize = 12
    t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.Parent = card

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0, 55, 0, 16)
    val.Position = UDim2.new(1, -67, 0, 8)
    val.BackgroundTransparency = 1
    val.Font = Enum.Font.GothamBold
    val.Text = tostring(default)
    val.TextColor3 = C.accent
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 4)
    track.Position = UDim2.new(0, 12, 0, 40)
    track.BackgroundColor3 = C.sliderBg
    track.BorderSizePixel = 0
    track.Parent = card
    makeCorner(track, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    makeCorner(fill, 4)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min)/(max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = C.text
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.ZIndex = 2
    knob.Parent = track
    makeCorner(knob, 20)

    local dragging = false
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + rel * (max - min))
            val.Text = tostring(v)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -7, 0.5, -7)
            callback(v)
        end
    end)
end

-- ==================== SECTIONS ====================
sectionLabel("  MOVEMENT", 1)

sliderRow("Walk Speed", 16, 250, 16, 2, function(v)
    State.speed = v
    if humanoid then humanoid.WalkSpeed = v end
end)

sliderRow("Jump Power", 50, 350, 50, 3, function(v)
    State.jumpPower = v
    if humanoid then humanoid.JumpPower = v end
end)

sectionLabel("  ABILITIES", 4)

toggleRow("Fly", "WASD to move • Space up • Shift down", 5, function(on)
    State.isFlyOn = on
    if on then
        if not State.bodyVelocity then
            State.bodyVelocity = Instance.new("BodyVelocity")
            State.bodyVelocity.Velocity = Vector3.zero
            State.bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            State.bodyVelocity.Parent = rootPart
        end
        if not State.bodyGyro then
            State.bodyGyro = Instance.new("BodyGyro")
            State.bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            State.bodyGyro.D = 100
            State.bodyGyro.Parent = rootPart
        end
    else
        if State.bodyVelocity then State.bodyVelocity:Destroy(); State.bodyVelocity = nil end
        if State.bodyGyro then State.bodyGyro:Destroy(); State.bodyGyro = nil end
    end
end)

toggleRow("Noclip", "Walk through any wall or object", 6, function(on)
    State.isNoclipOn = on
end)

sectionLabel("  EXPLOIT", 7)

toggleRow("Dupe Bug", "Private server only — duplicates items", 8, function(on)
    State.isDupeOn = on
end)

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, 0, 0, 14)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Font = Enum.Font.Gotham
FooterLabel.Text = "⚡ Soft Static  •  " .. DISCORD
FooterLabel.TextColor3 = C.textMuted
FooterLabel.TextSize = 9
FooterLabel.LayoutOrder = 99
FooterLabel.Parent = Scroll

-- ==================== DRAGGING ====================
local dragOn, dragInput, dragStart, startPos

Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragOn = true
        dragStart = i.Position
        startPos = MainFrame.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragOn = false end
        end)
    end
end)
Header.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i end
end)
UserInputService.InputChanged:Connect(function(i)
    if i == dragInput and dragOn then
        local d = i.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ==================== RUNTIME ====================
RunService.Heartbeat:Connect(function()
    if State.isFlyOn and State.bodyVelocity and State.bodyGyro then
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        State.bodyVelocity.Velocity = dir * State.flySpeed
        State.bodyGyro.CFrame = cam.CFrame
    end

    if State.isNoclipOn and character then
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    if State.isDupeOn then
        local gui = player:FindFirstChild("PlayerGui")
        if gui then
            for _, node in ipairs(gui:GetDescendants()) do
                if node:IsA("TextLabel") then
                    local m = string.match(node.Text, "^x(%d+)$")
                    if m then node.Text = "x" .. (tonumber(m) + 1) end
                end
            end
        end
    end
end)

-- ==================== CHECK KEY ====================
CheckKeyBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    if key == "" then
        KeyStatus.Text = "✗ Enter a key first."
        KeyStatus.TextColor3 = C.red
        return
    end

    local valid = validateKey(key)
    if valid then
        task.wait(0.8)
        for _, obj in ipairs(KeyFrame:GetDescendants()) do
            pcall(function()
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    makeTween(obj, {TextTransparency = 1}, 0.3):Play()
                end
                if obj:IsA("Frame") or obj:IsA("ImageLabel") then
                    makeTween(obj, {BackgroundTransparency = 1, ImageTransparency = 1}, 0.3):Play()
                end
            end)
        end
        makeTween(KeyFrame, {BackgroundTransparency = 1}, 0.35):Play()
        task.wait(0.4)
        KeyFrame.Visible = false
        MainFrame.Visible = true
        MainFrame.BackgroundTransparency = 1
        for _, obj in ipairs(MainFrame:GetDescendants()) do
            pcall(function()
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    obj.TextTransparency = 1
                    makeTween(obj, {TextTransparency = 0}, 0.4):Play()
                end
            end)
        end
        makeTween(MainFrame, {BackgroundTransparency = 0}, 0.4):Play()
    end
end)
