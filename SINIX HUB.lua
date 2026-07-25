-- ═══════════════════════════════════════════════════════════
--  SINIX HUB STYLE  —  Roblox LocalScript
--  Toggle : RightShift
-- ═══════════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local lp   = Players.LocalPlayer
local pGui = lp:WaitForChild("PlayerGui")

-- ════════════════════════════════════════════════════════════
--  SAVE SYSTEM
-- ════════════════════════════════════════════════════════════
local SAVE_FILE = "sinixhub_config.json"

local SavedConfig = {
    walkSpeed   = 16,
    jumpPower   = 50,
    gravity     = 196,
    fov         = 70,
    fullBright  = false,
    xray        = false,
    radar       = false,
    unlockFPS   = false,
    antiAFK     = false,
    noclip      = false,
    fly         = false,
    infiniJump  = false,
    freezePos   = false,
    autoOpen    = false,
    espSkeleton = false,
    espNames    = false,
    espHPBar    = false,
    espColor    = 1,
    showFooter  = true,
    themeIndex  = 1,
}

local function serializeConfig()
    local parts = {}
    for k, v in pairs(SavedConfig) do
        local val
        if type(v) == "boolean" then
            val = v and "true" or "false"
        else
            val = tostring(v)
        end
        table.insert(parts, string.format('"%s":%s', k, val))
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

local function parseJSON(str)
    local result = {}
    for key, val in str:gmatch('"([^"]+)":([^,}]+)') do
        if val == "true" then
            result[key] = true
        elseif val == "false" then
            result[key] = false
        else
            result[key] = tonumber(val) or val
        end
    end
    return result
end

local function saveConfig()
    local ok = pcall(writefile, SAVE_FILE, serializeConfig())
    return ok
end

local function loadConfig()
    local ok, data = pcall(readfile, SAVE_FILE)
    if not ok or not data or data == "" then return end
    local parsed = parseJSON(data)
    for k, v in pairs(parsed) do
        if SavedConfig[k] ~= nil then
            SavedConfig[k] = v
        end
    end
end

-- Charge la config au démarrage
loadConfig()

local function cfg(key, value)
    SavedConfig[key] = value
    saveConfig()
end

-- ── PALETTE ─────────────────────────────────────────────────
local C = {
    bg       = Color3.fromRGB(18, 18, 18),
    sidebar  = Color3.fromRGB(24, 24, 24),
    card     = Color3.fromRGB(30, 30, 30),
    input    = Color3.fromRGB(38, 38, 38),
    accent   = Color3.fromRGB(120, 80, 220),
    accentD  = Color3.fromRGB(90, 55, 180),
    text     = Color3.fromRGB(230, 230, 230),
    muted    = Color3.fromRGB(110, 110, 110),
    white    = Color3.fromRGB(255, 255, 255),
    success  = Color3.fromRGB(60, 200, 100),
    err      = Color3.fromRGB(210, 60, 60),
    border   = Color3.fromRGB(45, 45, 45),
}

-- ── UTILS ───────────────────────────────────────────────────
local function rnd(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
end

local function bdr(p, col, t)
    local s = Instance.new("UIStroke")
    s.Color     = col or C.border
    s.Thickness = t or 1
    s.Parent    = p
    return s
end

local function lbl(p, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel        = 0
    for k, v in pairs(props) do l[k] = v end
    l.Parent = p
    return l
end

local function ripple(btn)
    btn.MouseButton1Click:Connect(function()
        local r = Instance.new("Frame")
        r.Size                   = UDim2.new(0,0,0,0)
        r.AnchorPoint            = Vector2.new(0.5,0.5)
        r.Position               = UDim2.new(0.5,0,0.5,0)
        r.BackgroundColor3       = Color3.fromRGB(255,255,255)
        r.BackgroundTransparency = 0.7
        r.BorderSizePixel        = 0
        r.ZIndex                 = btn.ZIndex + 3
        r.Parent                 = btn
        rnd(r, 9999)
        local t = TweenService:Create(r,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(2.5,0,2.5,0), BackgroundTransparency = 1 })
        t:Play()
        t.Completed:Connect(function() r:Destroy() end)
    end)
end

-- ── FIRE REMOTE ─────────────────────────────────────────────
local function fireRemote(name, ...)
    local rs  = game:GetService("ReplicatedStorage")
    local rem = rs:FindFirstChild(name, true)
    if rem and rem:IsA("RemoteEvent") then
        rem:FireServer(...)
    else
        warn("[SinixHub] Remote not found: " .. name)
    end
end

-- ── TOAST ───────────────────────────────────────────────────
local _tq, _tb = {}, false
local Root

local function toast(msg, col)
    col = col or C.success
    table.insert(_tq, { msg=msg, col=col })
    if _tb then return end
    _tb = true
    task.spawn(function()
        while #_tq > 0 do
            local e  = table.remove(_tq, 1)
            local tf = Instance.new("Frame")
            tf.Size                   = UDim2.new(0,0,0,42)
            tf.Position               = UDim2.new(0.5,0,1,-58)
            tf.AnchorPoint            = Vector2.new(0.5,1)
            tf.BackgroundColor3       = e.col
            tf.BackgroundTransparency = 0.1
            tf.BorderSizePixel        = 0
            tf.ZIndex                 = 90
            tf.Parent                 = Root
            rnd(tf, 8)
            lbl(tf, {
                Size           = UDim2.new(1,-16,1,0),
                Position       = UDim2.new(0,10,0,0),
                Font           = Enum.Font.GothamBold,
                TextSize       = 13,
                TextColor3     = C.white,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text           = msg,
                ZIndex         = 91,
            })
            TweenService:Create(tf,
                TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Size = UDim2.new(0,340,0,42) }):Play()
            task.wait(2.4)
            local o = TweenService:Create(tf,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { Size = UDim2.new(0,0,0,42), BackgroundTransparency = 1 })
            o:Play() ; o.Completed:Wait()
            tf:Destroy()
            task.wait(0.05)
        end
        _tb = false
    end)
end

-- ════════════════════════════════════════════════════════════
--  ROOT GUI
-- ════════════════════════════════════════════════════════════
Root = Instance.new("ScreenGui")
Root.Name           = "SinixHubUI"
Root.ResetOnSpawn   = false
Root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Root.Parent         = pGui

-- ── FENÊTRE PRINCIPALE ──────────────────────────────────────
local MW, MH = 860, 520
local SB_W   = 180
local menuOpen = true

local Win = Instance.new("Frame")
Win.Size             = UDim2.new(0, MW, 0, MH)
Win.AnchorPoint      = Vector2.new(0.5, 0.5)
Win.Position         = UDim2.new(0.5, 0, 0.5, 0)
Win.BackgroundColor3 = C.bg
Win.BorderSizePixel  = 0
Win.ClipsDescendants = false
Win.Active           = true
Win.Draggable        = true
Win.ZIndex           = 10
Win.Parent           = Root
rnd(Win, 10)
bdr(Win, C.border, 1.5)

local shadow = Instance.new("Frame")
shadow.Size                   = UDim2.new(1,20,1,20)
shadow.Position               = UDim2.new(0,-10,0,10)
shadow.BackgroundColor3       = Color3.fromRGB(0,0,0)
shadow.BackgroundTransparency = 0.6
shadow.BorderSizePixel        = 0
shadow.ZIndex                 = 9
shadow.Parent                 = Win
rnd(shadow, 14)

-- ── SIDEBAR ─────────────────────────────────────────────────
local Sidebar = Instance.new("Frame")
Sidebar.Size             = UDim2.new(0, SB_W, 1, 0)
Sidebar.BackgroundColor3 = C.sidebar
Sidebar.BorderSizePixel  = 0
Sidebar.ZIndex           = 12
Sidebar.Parent           = Win
rnd(Sidebar, 10)

local sbCover = Instance.new("Frame")
sbCover.Size             = UDim2.new(0,10,1,0)
sbCover.Position         = UDim2.new(1,-10,0,0)
sbCover.BackgroundColor3 = C.sidebar
sbCover.BorderSizePixel  = 0
sbCover.ZIndex           = 12
sbCover.Parent           = Sidebar

lbl(Sidebar, {
    Size           = UDim2.new(1,0,0,60),
    Position       = UDim2.new(0,0,0,0),
    Font           = Enum.Font.GothamBold,
    TextSize       = 20,
    TextColor3     = C.white,
    Text           = "Sinix Hub",
    ZIndex         = 13,
})

local sbSep = Instance.new("Frame")
sbSep.Size             = UDim2.new(1,0,0,1)
sbSep.Position         = UDim2.new(0,0,0,58)
sbSep.BackgroundColor3 = C.border
sbSep.BorderSizePixel  = 0
sbSep.ZIndex           = 13
sbSep.Parent           = Sidebar

local discordBtn = Instance.new("TextButton")
discordBtn.Size             = UDim2.new(1,-16,0,38)
discordBtn.Position         = UDim2.new(0,8,1,-48)
discordBtn.BackgroundColor3 = Color3.fromRGB(88,101,242)
discordBtn.BorderSizePixel  = 0
discordBtn.Font             = Enum.Font.GothamBold
discordBtn.TextSize         = 13
discordBtn.TextColor3       = Color3.fromRGB(255,255,255)
discordBtn.Text             = "     Discord"
discordBtn.AutoButtonColor  = false
discordBtn.ZIndex           = 14
discordBtn.Parent           = Sidebar
rnd(discordBtn, 8)

local dcIcon = Instance.new("ImageLabel")
dcIcon.Size                   = UDim2.new(0,22,0,22)
dcIcon.Position               = UDim2.new(0,10,0.5,-11)
dcIcon.BackgroundTransparency = 1
dcIcon.Image                  = "rbxassetid://3769040814"
dcIcon.ZIndex                 = 15
dcIcon.Parent                 = discordBtn

discordBtn.MouseEnter:Connect(function()
    TweenService:Create(discordBtn, TweenInfo.new(0.12),
        { BackgroundColor3 = Color3.fromRGB(71,82,196) }):Play()
end)
discordBtn.MouseLeave:Connect(function()
    TweenService:Create(discordBtn, TweenInfo.new(0.12),
        { BackgroundColor3 = Color3.fromRGB(88,101,242) }):Play()
end)
discordBtn.MouseButton1Click:Connect(function()
    local ok = pcall(setclipboard, "https://discord.gg/DbHsGBckyc")
    if ok then
        toast("󰙯  Lien copié — colle dans ton navigateur", Color3.fromRGB(88,101,242))
    else
        toast("󰙯  discord.gg/DbHsGBckyc", Color3.fromRGB(88,101,242))
    end
end)

local SbNav = Instance.new("Frame")
SbNav.Size                   = UDim2.new(1,0,1,-120)
SbNav.Position               = UDim2.new(0,0,0,66)
SbNav.BackgroundTransparency = 1
SbNav.ZIndex                 = 13
SbNav.Parent                 = Sidebar

local sbLayout = Instance.new("UIListLayout")
sbLayout.SortOrder = Enum.SortOrder.LayoutOrder
sbLayout.Padding   = UDim.new(0,0)
sbLayout.Parent    = SbNav

-- ── TOPBAR ──────────────────────────────────────────────────
local TopBar = Instance.new("Frame")
TopBar.Size             = UDim2.new(1,-SB_W,0,50)
TopBar.Position         = UDim2.new(0,SB_W,0,0)
TopBar.BackgroundColor3 = C.bg
TopBar.BorderSizePixel  = 0
TopBar.ZIndex           = 12
TopBar.Parent           = Win

local topSep = Instance.new("Frame")
topSep.Size             = UDim2.new(1,0,0,1)
topSep.Position         = UDim2.new(0,0,1,-1)
topSep.BackgroundColor3 = C.border
topSep.BorderSizePixel  = 0
topSep.ZIndex           = 13
topSep.Parent           = TopBar

lbl(TopBar, {
    Size       = UDim2.new(0,30,1,0),
    Position   = UDim2.new(0,14,0,0),
    Font       = Enum.Font.GothamBold,
    TextSize   = 16,
    TextColor3 = C.muted,
    Text       = "🔍",
    ZIndex     = 14,
})

local searchBox = Instance.new("TextBox")
searchBox.Size                   = UDim2.new(1,-100,0,32)
searchBox.Position               = UDim2.new(0,40,0.5,-16)
searchBox.BackgroundTransparency = 1
searchBox.BorderSizePixel        = 0
searchBox.Font                   = Enum.Font.Gotham
searchBox.TextSize               = 14
searchBox.TextColor3             = C.text
searchBox.PlaceholderText        = "Search"
searchBox.PlaceholderColor3      = C.muted
searchBox.ClearTextOnFocus       = false
searchBox.ZIndex                 = 14
searchBox.Parent                 = TopBar

local moveBtn = Instance.new("TextButton")
moveBtn.Size             = UDim2.new(0,36,0,36)
moveBtn.Position         = UDim2.new(1,-44,0.5,-18)
moveBtn.BackgroundColor3 = C.input
moveBtn.BorderSizePixel  = 0
moveBtn.Font             = Enum.Font.GothamBold
moveBtn.TextSize         = 18
moveBtn.TextColor3       = C.muted
moveBtn.Text             = "⤢"
moveBtn.AutoButtonColor  = false
moveBtn.ZIndex           = 14
moveBtn.Parent           = TopBar
rnd(moveBtn, 6)
moveBtn.MouseButton1Click:Connect(function()
    Win.Draggable = not Win.Draggable
    moveBtn.TextColor3 = Win.Draggable and C.muted or C.accent
end)

-- ── CONTENT ZONE ────────────────────────────────────────────
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size                   = UDim2.new(1,-SB_W-8,1,-58)
ContentScroll.Position               = UDim2.new(0,SB_W+4,0,54)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel        = 0
ContentScroll.ScrollBarThickness     = 3
ContentScroll.ScrollBarImageColor3   = C.accent
ContentScroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
ContentScroll.CanvasSize             = UDim2.new(0,0,0,0)
ContentScroll.ZIndex                 = 11
ContentScroll.Parent                 = Win

local czL = Instance.new("UIListLayout")
czL.Padding       = UDim.new(0,10)
czL.SortOrder     = Enum.SortOrder.LayoutOrder
czL.FillDirection = Enum.FillDirection.Vertical
czL.Parent        = ContentScroll

local czP = Instance.new("UIPadding")
czP.PaddingLeft   = UDim.new(0,10)
czP.PaddingRight  = UDim.new(0,10)
czP.PaddingTop    = UDim.new(0,10)
czP.PaddingBottom = UDim.new(0,10)
czP.Parent        = ContentScroll

local footer = lbl(Win, {
    Size           = UDim2.new(1,-SB_W,0,22),
    Position       = UDim2.new(0,SB_W,1,-22),
    Font           = Enum.Font.Gotham,
    TextSize       = 11,
    TextColor3     = C.muted,
    Text           = "No Footer",
    ZIndex         = 12,
})
footer.Visible = SavedConfig.showFooter

-- ════════════════════════════════════════════════════════════
--  COMPOSANTS UI
-- ════════════════════════════════════════════════════════════

local function makeCard(titleTxt, order, parent)
    parent = parent or ContentScroll

    local wrap = Instance.new("Frame")
    wrap.Size             = UDim2.new(1,0,0,0)
    wrap.AutomaticSize    = Enum.AutomaticSize.Y
    wrap.BackgroundColor3 = C.card
    wrap.BorderSizePixel  = 0
    wrap.LayoutOrder      = order
    wrap.ZIndex           = 12
    wrap.Parent           = parent
    rnd(wrap, 8)
    bdr(wrap, C.border, 1)

    local inner = Instance.new("Frame")
    inner.Size                   = UDim2.new(1,-16,0,0)
    inner.Position               = UDim2.new(0,8,0,36)
    inner.AutomaticSize          = Enum.AutomaticSize.Y
    inner.BackgroundTransparency = 1
    inner.ZIndex                 = 13
    inner.Parent                 = wrap

    local innerL = Instance.new("UIListLayout")
    innerL.Padding   = UDim.new(0,8)
    innerL.SortOrder = Enum.SortOrder.LayoutOrder
    innerL.Parent    = inner

    local innerPad = Instance.new("UIPadding")
    innerPad.PaddingBottom = UDim.new(0,10)
    innerPad.Parent        = inner

    lbl(wrap, {
        Size           = UDim2.new(1,-16,0,28),
        Position       = UDim2.new(0,10,0,4),
        Font           = Enum.Font.GothamBold,
        TextSize       = 14,
        TextColor3     = C.white,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text           = titleTxt,
        ZIndex         = 13,
    })

    return wrap, inner
end

-- mkToggle avec saveKey optionnel
local function mkToggle(parent, labelTxt, order, default, cb, saveKey)
    local state = (saveKey and SavedConfig[saveKey] ~= nil) and SavedConfig[saveKey] or (default or false)

    local row = Instance.new("Frame")
    row.Size                   = UDim2.new(1,0,0,32)
    row.BackgroundTransparency = 1
    row.LayoutOrder            = order
    row.ZIndex                 = 14
    row.Parent                 = parent

    lbl(row, {
        Size           = UDim2.new(1,-60,1,0),
        Position       = UDim2.new(0,0,0,0),
        Font           = Enum.Font.Gotham,
        TextSize       = 13,
        TextColor3     = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text           = labelTxt,
        ZIndex         = 15,
    })

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(0,44,0,22)
    track.Position         = UDim2.new(1,-46,0.5,-11)
    track.BackgroundColor3 = state and C.accent or C.input
    track.BorderSizePixel  = 0
    track.ZIndex           = 15
    track.Parent           = row
    rnd(track, 11)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0,16,0,16)
    knob.Position         = state and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 16
    knob.Parent           = track
    rnd(knob, 8)

    local hit = Instance.new("TextButton")
    hit.Size                   = UDim2.new(1,0,1,0)
    hit.BackgroundTransparency = 1
    hit.Text                   = ""
    hit.ZIndex                 = 17
    hit.Parent                 = row

    hit.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.15),
            { BackgroundColor3 = state and C.accent or C.input }):Play()
        TweenService:Create(knob,
            TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = state and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8) }):Play()
        if saveKey then cfg(saveKey, state) end
        if cb then cb(state) end
    end)

    -- Auto-fire si la valeur sauvegardée est true
    if state and cb then
        task.defer(function() cb(state) end)
    end

    return row
end

-- mkSlider avec saveKey optionnel
local function mkSlider(parent, labelTxt, minV, maxV, defV, order, cb, saveKey)
    local cur = (saveKey and SavedConfig[saveKey]) or defV

    local wrap = Instance.new("Frame")
    wrap.Size                   = UDim2.new(1,0,0,56)
    wrap.BackgroundTransparency = 1
    wrap.LayoutOrder            = order
    wrap.ZIndex                 = 14
    wrap.Parent                 = parent

    lbl(wrap, {
        Size           = UDim2.new(1,0,0,18),
        Position       = UDim2.new(0,0,0,0),
        Font           = Enum.Font.GothamBold,
        TextSize       = 12,
        TextColor3     = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text           = labelTxt,
        ZIndex         = 15,
    })

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(1,0,0,22)
    track.Position         = UDim2.new(0,0,0,24)
    track.BackgroundColor3 = C.input
    track.BorderSizePixel  = 0
    track.ZIndex           = 15
    track.Parent           = wrap
    rnd(track, 4)

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new((cur-minV)/(maxV-minV),0,1,0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 16
    fill.Parent           = track
    rnd(fill, 4)

    local valL = lbl(track, {
        Size       = UDim2.new(1,0,1,0),
        Font       = Enum.Font.GothamBold,
        TextSize   = 12,
        TextColor3 = C.white,
        Text       = cur .. "/" .. maxV,
        ZIndex     = 17,
    })

    local dragging = false
    local hit = Instance.new("TextButton")
    hit.Size                   = UDim2.new(1,0,1,0)
    hit.BackgroundTransparency = 1
    hit.Text                   = ""
    hit.ZIndex                 = 18
    hit.Parent                 = track

    local function upd(x)
        local r   = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        cur       = math.floor(minV + r*(maxV-minV))
        fill.Size = UDim2.new(r,0,1,0)
        valL.Text = cur .. "/" .. maxV
        if saveKey then cfg(saveKey, cur) end
        if cb then cb(cur) end
    end

    hit.MouseButton1Down:Connect(function()
        dragging = true
        upd(UserInputService:GetMouseLocation().X)
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            upd(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Applique la valeur sauvegardée au démarrage
    if saveKey and cb then
        task.defer(function() cb(cur) end)
    end

    return wrap
end

local function mkButton(parent, labelTxt, order, cb)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,0,0,32)
    btn.BackgroundColor3 = C.input
    btn.BorderSizePixel  = 0
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 13
    btn.TextColor3       = C.text
    btn.Text             = labelTxt
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = order
    btn.ClipsDescendants = true
    btn.ZIndex           = 14
    btn.Parent           = parent
    rnd(btn, 6)
    ripple(btn)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12),
            { BackgroundColor3 = C.accent }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12),
            { BackgroundColor3 = C.input }):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if cb then cb() end
    end)

    return btn
end

-- ════════════════════════════════════════════════════════════
--  TABS SYSTÈME
-- ════════════════════════════════════════════════════════════
local activeTabBtn = nil

local function mkSidebarTab(name, order, fn)
    local btn = Instance.new("TextButton")
    btn.Size                   = UDim2.new(1,0,0,42)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel        = 0
    btn.Font                   = Enum.Font.GothamSemibold
    btn.TextSize               = 15
    btn.TextColor3             = C.muted
    btn.TextXAlignment         = Enum.TextXAlignment.Left
    btn.Text                   = "   " .. name
    btn.AutoButtonColor        = false
    btn.LayoutOrder            = order
    btn.ClipsDescendants       = true
    btn.ZIndex                 = 14
    btn.Parent                 = SbNav

    local bar = Instance.new("Frame")
    bar.Name             = "bar"
    bar.Size             = UDim2.new(0,3,0.6,0)
    bar.Position         = UDim2.new(0,0,0.2,0)
    bar.BackgroundColor3 = C.accent
    bar.BorderSizePixel  = 0
    bar.Visible          = false
    bar.ZIndex           = 15
    bar.Parent           = btn

    local function activate()
        if activeTabBtn and activeTabBtn ~= btn then
            activeTabBtn.TextColor3 = C.muted
            local ob = activeTabBtn:FindFirstChild("bar")
            if ob then ob.Visible = false end
        end
        activeTabBtn   = btn
        btn.TextColor3 = C.white
        bar.Visible    = true

        for _, c in ipairs(ContentScroll:GetChildren()) do
            if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
                c:Destroy()
            end
        end
        fn()
    end

    btn.MouseButton1Click:Connect(activate)
    btn.MouseEnter:Connect(function()
        if btn ~= activeTabBtn then
            TweenService:Create(btn, TweenInfo.new(0.1), { TextColor3 = C.text }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if btn ~= activeTabBtn then
            TweenService:Create(btn, TweenInfo.new(0.1), { TextColor3 = C.muted }):Play()
        end
    end)

    return btn, activate
end

-- ════════════════════════════════════════════════════════════
--  GRID HELPER
-- ════════════════════════════════════════════════════════════
local function makeGrid(order)
    local grid = Instance.new("Frame")
    grid.Size                   = UDim2.new(1,0,0,0)
    grid.AutomaticSize          = Enum.AutomaticSize.Y
    grid.BackgroundTransparency = 1
    grid.LayoutOrder            = order
    grid.ZIndex                 = 12
    grid.Parent                 = ContentScroll

    local gl = Instance.new("UIGridLayout")
    gl.CellSize          = UDim2.new(0.5,-6,0,0)
    gl.AutomaticCellSize = Enum.AutomaticSize.Y
    gl.CellPadding       = UDim2.new(0,10,0,10)
    gl.SortOrder         = Enum.SortOrder.LayoutOrder
    gl.Parent            = grid

    local gp = Instance.new("UIPadding")
    gp.PaddingBottom = UDim.new(0,4)
    gp.Parent        = grid

    return grid
end

-- ════════════════════════════════════════════════════════════
--  FEATURES
-- ════════════════════════════════════════════════════════════
local function unlockFPS()
    local ok = pcall(setfpscap, 0)
    if not ok then
        pcall(function() settings().Rendering.FrameRateManager = 0 end)
    end
end

local _afkBound = false
local function startAntiAFK()
    if _afkBound then return end
    _afkBound = true
    local vu = game:GetService("VirtualUser")
    lp.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(0.1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

local _fbOriginals = {}
local function setFullBright(on)
    local lighting = game:GetService("Lighting")
    if on then
        _fbOriginals = {
            Ambient        = lighting.Ambient,
            OutdoorAmbient = lighting.OutdoorAmbient,
            Brightness     = lighting.Brightness,
            GlobalShadows  = lighting.GlobalShadows,
            FogEnd         = lighting.FogEnd,
            ClockTime      = lighting.ClockTime,
        }
        lighting.Ambient        = Color3.fromRGB(178,178,178)
        lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
        lighting.Brightness     = 2
        lighting.GlobalShadows  = false
        lighting.FogEnd         = 1e6
        lighting.ClockTime      = 14
        for _, v in ipairs(lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then
                v.Enabled = false
            end
        end
    else
        for k, v in pairs(_fbOriginals) do lighting[k] = v end
        for _, v in ipairs(lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then
                v.Enabled = true
            end
        end
    end
end

local _xrayTargets  = {}
local _xrayKeywords = { "wall","floor","brick","part","union","terrain" }
local function setXRay(on)
    if on then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                local low   = v.Name:lower()
                local isEnv = false
                for _, kw in ipairs(_xrayKeywords) do
                    if low:find(kw) then isEnv = true ; break end
                end
                if isEnv then
                    table.insert(_xrayTargets, { part=v, ltm=v.LocalTransparencyModifier })
                    v.LocalTransparencyModifier = 0.75
                end
            end
        end
    else
        for _, entry in ipairs(_xrayTargets) do
            if entry.part and entry.part.Parent then
                entry.part.LocalTransparencyModifier = entry.ltm
            end
        end
        _xrayTargets = {}
    end
end

local _radarFrame
local _radarConn
local RADAR_SIZE  = 180
local RADAR_RANGE = 300
local RADAR_DOT   = 6

local function buildRadarUI()
    if _radarFrame and _radarFrame.Parent then _radarFrame:Destroy() end
    local frame = Instance.new("Frame")
    frame.Name                   = "_sinixRadar"
    frame.Size                   = UDim2.new(0,RADAR_SIZE,0,RADAR_SIZE)
    frame.Position               = UDim2.new(1,-(RADAR_SIZE+16),0,16)
    frame.BackgroundColor3       = Color3.fromRGB(10,10,10)
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel        = 0
    frame.ZIndex                 = 50
    frame.Parent                 = Root
    rnd(frame, RADAR_SIZE/2)
    bdr(frame, C.accent, 1.5)

    for _, r in ipairs({0.33, 0.66, 1.0}) do
        local ring = Instance.new("Frame")
        ring.Size                   = UDim2.new(r,0,r,0)
        ring.AnchorPoint            = Vector2.new(0.5,0.5)
        ring.Position               = UDim2.new(0.5,0,0.5,0)
        ring.BackgroundTransparency = 1
        ring.BorderSizePixel        = 0
        ring.ZIndex                 = 51
        ring.Parent                 = frame
        bdr(ring, Color3.fromRGB(60,60,60), 1)
        rnd(ring, RADAR_SIZE/2)
    end

    for _, axis in ipairs({"H","V"}) do
        local line = Instance.new("Frame")
        line.AnchorPoint      = Vector2.new(0.5,0.5)
        line.Position         = UDim2.new(0.5,0,0.5,0)
        line.BackgroundColor3 = Color3.fromRGB(60,60,60)
        line.BorderSizePixel  = 0
        line.ZIndex           = 51
        line.Size             = axis=="H" and UDim2.new(1,-4,0,1) or UDim2.new(0,1,1,-4)
        line.Parent           = frame
    end

    local selfDot = Instance.new("Frame")
    selfDot.Size             = UDim2.new(0,RADAR_DOT,0,RADAR_DOT)
    selfDot.AnchorPoint      = Vector2.new(0.5,0.5)
    selfDot.Position         = UDim2.new(0.5,0,0.5,0)
    selfDot.BackgroundColor3 = C.success
    selfDot.BorderSizePixel  = 0
    selfDot.ZIndex           = 53
    selfDot.Parent           = frame
    rnd(selfDot, RADAR_DOT/2)

    _radarFrame = frame
    return frame
end

local function startRadar()
    local frame = buildRadarUI()
    local dots  = {}
    _radarConn = RunService.Heartbeat:Connect(function()
        local myChar = lp.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local cam = workspace.CurrentCamera
        local yaw = math.atan2(-cam.CFrame.LookVector.X, -cam.CFrame.LookVector.Z)
        for name, dot in pairs(dots) do
            if not Players:FindFirstChild(name) then dot:Destroy() ; dots[name] = nil end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                local tChar = p.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local delta = tRoot.Position - myRoot.Position
                    local dist  = Vector2.new(delta.X, delta.Z).Magnitude
                    local angle = math.atan2(delta.X, delta.Z) - yaw
                    local norm  = math.min(dist / RADAR_RANGE, 1)
                    local rx    = 0.5 + math.sin(angle) * norm * 0.46
                    local ry    = 0.5 - math.cos(angle) * norm * 0.46
                    if not dots[p.Name] then
                        local dot = Instance.new("Frame")
                        dot.Size             = UDim2.new(0,RADAR_DOT,0,RADAR_DOT)
                        dot.AnchorPoint      = Vector2.new(0.5,0.5)
                        dot.BackgroundColor3 = C.accent
                        dot.BorderSizePixel  = 0
                        dot.ZIndex           = 52
                        dot.Parent           = frame
                        rnd(dot, RADAR_DOT/2)
                        local tip = Instance.new("TextLabel")
                        tip.Size                   = UDim2.new(0,80,0,16)
                        tip.Position               = UDim2.new(0,8,0,0)
                        tip.BackgroundColor3       = Color3.fromRGB(10,10,10)
                        tip.BackgroundTransparency = 0.3
                        tip.Font                   = Enum.Font.GothamBold
                        tip.TextSize               = 10
                        tip.TextColor3             = C.text
                        tip.Text                   = p.Name
                        tip.BorderSizePixel        = 0
                        tip.Visible                = false
                        tip.ZIndex                 = 54
                        tip.Parent                 = dot
                        rnd(tip, 3)
                        dot.MouseEnter:Connect(function() tip.Visible = true  end)
                        dot.MouseLeave:Connect(function() tip.Visible = false end)
                        dots[p.Name] = dot
                    end
                    local dot = dots[p.Name]
                    dot.Position = UDim2.new(rx,0,ry,0)
                    local hum = tChar:FindFirstChildOfClass("Humanoid")
                    local hp  = hum and hum.Health or 100
                    dot.BackgroundColor3 = hp > 60 and C.accent
                        or hp > 25 and Color3.fromRGB(220,180,40)
                        or Color3.fromRGB(210,60,60)
                else
                    if dots[p.Name] then dots[p.Name]:Destroy() ; dots[p.Name] = nil end
                end
            end
        end
    end)
end

local function stopRadar()
    if _radarConn then _radarConn:Disconnect() ; _radarConn = nil end
    if _radarFrame and _radarFrame.Parent then _radarFrame:Destroy() end
    _radarFrame = nil
end

-- ════════════════════════════════════════════════════════════
--  ÉTAT GLOBAL
-- ════════════════════════════════════════════════════════════
local _noclipConn
local _flyConn, _bv, _bg
local _speedConn, _jumpConn

-- ════════════════════════════════════════════════════════════
--  CONTENU : MAIN
-- ════════════════════════════════════════════════════════════
local function buildMain()
    local grid = makeGrid(1)

    local _, miscInner = makeCard("Misc", 1, grid)

    mkToggle(miscInner, "Freeze Position", 1, false, function(s)
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            if s then
                local ba = Instance.new("BodyPosition")
                ba.Name     = "_freeze"
                ba.Position = root.Position
                ba.MaxForce = Vector3.new(1e9,1e9,1e9)
                ba.Parent   = root
            else
                local ba = root:FindFirstChild("_freeze")
                if ba then ba:Destroy() end
            end
        end
        toast(s and "❄ Position gelée" or "❄ Position libérée",
              s and C.accent or C.muted)
    end, "freezePos")

    mkToggle(miscInner, "Auto Open", 2, false, function(s)
        if s then
            task.spawn(function()
                while s do
                    fireRemote("OpenChest")
                    fireRemote("OpenCrate")
                    fireRemote("Open")
                    task.wait(0.8)
                end
            end)
            toast("✓ Auto Open ON", C.success)
        else
            toast("Auto Open OFF", C.muted)
        end
    end, "autoOpen")
end

-- ════════════════════════════════════════════════════════════
--  CONTENU : TELEPORTS
-- ════════════════════════════════════════════════════════════
local function buildTeleports()
    local _, toolInner = makeCard("TP Tool", 1)
    local targetName = ""

    local targetRow = Instance.new("Frame")
    targetRow.Size                   = UDim2.new(1,0,0,28)
    targetRow.BackgroundTransparency = 1
    targetRow.LayoutOrder            = 1
    targetRow.ZIndex                 = 15
    targetRow.Parent                 = toolInner

    lbl(targetRow, {
        Size       = UDim2.new(0,60,1,0),
        Font       = Enum.Font.GothamBold,
        TextSize   = 12,
        TextColor3 = C.accent,
        Text       = "Target",
        ZIndex     = 16,
    })

    local targetBox = Instance.new("TextBox")
    targetBox.Size              = UDim2.new(1,-68,0,24)
    targetBox.Position          = UDim2.new(0,64,0.5,-12)
    targetBox.BackgroundColor3  = C.input
    targetBox.BorderSizePixel   = 0
    targetBox.Font              = Enum.Font.Gotham
    targetBox.TextSize          = 13
    targetBox.TextColor3        = C.text
    targetBox.PlaceholderText   = "Nom du joueur ou objet"
    targetBox.PlaceholderColor3 = C.muted
    targetBox.ClearTextOnFocus  = false
    targetBox.ZIndex            = 16
    targetBox.Parent            = targetRow
    rnd(targetBox, 5)
    bdr(targetBox, C.border)
    targetBox.FocusLost:Connect(function() targetName = targetBox.Text end)
    targetBox:GetPropertyChangedSignal("Text"):Connect(function() targetName = targetBox.Text end)

    mkButton(toolInner, "TP → Joueur", 2, function()
        local target = Players:FindFirstChild(targetName)
        if not target then toast("❌ Joueur introuvable : " .. targetName, C.err) return end
        local char  = lp.Character
        local root  = char and char:FindFirstChild("HumanoidRootPart")
        local tChar = target.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if root and tRoot then
            root.CFrame = tRoot.CFrame * CFrame.new(0,0,-3)
            toast("📍 TP → " .. target.Name, C.accent)
        else
            toast("❌ Personnage indisponible", C.err)
        end
    end)

    mkButton(toolInner, "TP → Objet Workspace", 3, function()
        local obj = workspace:FindFirstChild(targetName, true)
        if not obj then toast("❌ Objet introuvable : " .. targetName, C.err) return end
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local pos
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
            pos = obj.CFrame
        elseif obj:IsA("Model") then
            local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            pos = primary and primary.CFrame
        end
        if root and pos then
            root.CFrame = pos * CFrame.new(0,3,-4)
            toast("📍 TP → " .. obj.Name, C.accent)
        else
            toast("❌ Position indéterminée", C.err)
        end
    end)

    mkButton(toolInner, "Amener Joueur ici", 4, function()
        local target = Players:FindFirstChild(targetName)
        if not target then toast("❌ Joueur introuvable : " .. targetName, C.err) return end
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local tChar  = target.Character
        local tRoot  = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if myRoot and tRoot then
            tRoot.CFrame = myRoot.CFrame * CFrame.new(2,0,0)
            toast("📍 " .. target.Name .. " amené ici", C.accent)
        else
            toast("❌ Impossible", C.err)
        end
    end)

    local _, customInner = makeCard("TP Coordonnées", 2)
    local coords = { x=0, y=5, z=0 }

    local function coordRow(axis, order)
        local row = Instance.new("Frame")
        row.Size                   = UDim2.new(1,0,0,28)
        row.BackgroundTransparency = 1
        row.LayoutOrder            = order
        row.ZIndex                 = 15
        row.Parent                 = customInner

        lbl(row, {
            Size       = UDim2.new(0,20,1,0),
            Font       = Enum.Font.GothamBold,
            TextSize   = 13,
            TextColor3 = C.accent,
            Text       = axis:upper(),
            ZIndex     = 16,
        })

        local box = Instance.new("TextBox")
        box.Size              = UDim2.new(1,-28,0,24)
        box.Position          = UDim2.new(0,24,0.5,-12)
        box.BackgroundColor3  = C.input
        box.BorderSizePixel   = 0
        box.Font              = Enum.Font.Gotham
        box.TextSize          = 13
        box.TextColor3        = C.text
        box.Text              = "0"
        box.ClearTextOnFocus  = false
        box.ZIndex            = 16
        box.Parent            = row
        rnd(box, 5)
        bdr(box, C.border)
        box.FocusLost:Connect(function() coords[axis] = tonumber(box.Text) or 0 end)
    end

    coordRow("x", 1)
    coordRow("y", 2)
    coordRow("z", 3)

    mkButton(customInner, "Téléporter", 4, function()
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(coords.x, coords.y, coords.z)
            toast(string.format("📍 TP → %.0f, %.0f, %.0f", coords.x, coords.y, coords.z), C.accent)
        end
    end)
end

-- ════════════════════════════════════════════════════════════
--  CONTENU : MISC
-- ════════════════════════════════════════════════════════════
local function buildMisc()
    local _, movInner = makeCard("Mouvement", 1)

    mkSlider(movInner, "WalkSpeed", 8, 500, 16, 1, function(v)
        local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = v end
        if _speedConn then _speedConn:Disconnect() end
        _speedConn = lp.CharacterAdded:Connect(function(c)
            local h2 = c:WaitForChild("Humanoid", 5)
            if h2 then h2.WalkSpeed = v end
        end)
    end, "walkSpeed")

    mkSlider(movInner, "JumpPower", 10, 500, 50, 2, function(v)
        local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if h then h.JumpPower = v end
        if _jumpConn then _jumpConn:Disconnect() end
        _jumpConn = lp.CharacterAdded:Connect(function(c)
            local h2 = c:WaitForChild("Humanoid", 5)
            if h2 then h2.JumpPower = v end
        end)
    end, "jumpPower")

    mkSlider(movInner, "Gravité", 10, 400, 196, 3, function(v)
        workspace.Gravity = v
    end, "gravity")

    local _, abInner = makeCard("Capacités", 2)

    local infiActive = SavedConfig.infiniJump
    local infiConn

    local ijFrame = Instance.new("Frame")
    ijFrame.Size                   = UDim2.new(1,0,0,32)
    ijFrame.BackgroundTransparency = 1
    ijFrame.LayoutOrder            = 1
    ijFrame.ZIndex                 = 14
    ijFrame.Parent                 = abInner

    local ijBtn = Instance.new("TextButton")
    ijBtn.Size             = UDim2.new(1,0,1,0)
    ijBtn.BackgroundColor3 = infiActive and C.accent or C.input
    ijBtn.BorderSizePixel  = 0
    ijBtn.Font             = Enum.Font.GothamBold
    ijBtn.TextSize         = 13
    ijBtn.TextColor3       = C.text
    ijBtn.Text             = infiActive and "InfiniJump  ·  ON" or "InfiniJump  ·  OFF"
    ijBtn.AutoButtonColor  = false
    ijBtn.ClipsDescendants = true
    ijBtn.ZIndex           = 15
    ijBtn.Parent           = ijFrame
    rnd(ijBtn, 6)
    ripple(ijBtn)

    if infiActive then
        infiConn = UserInputService.JumpRequest:Connect(function()
            local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end

    ijBtn.MouseEnter:Connect(function()
        if not infiActive then
            TweenService:Create(ijBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.accent }):Play()
        end
    end)
    ijBtn.MouseLeave:Connect(function()
        if not infiActive then
            TweenService:Create(ijBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.input }):Play()
        end
    end)
    ijBtn.MouseButton1Click:Connect(function()
        infiActive = not infiActive
        cfg("infiniJump", infiActive)
        if infiActive then
            ijBtn.Text             = "InfiniJump  ·  ON"
            ijBtn.BackgroundColor3 = C.accent
            infiConn = UserInputService.JumpRequest:Connect(function()
                local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
            toast("🦘 InfiniJump ON", C.success)
        else
            ijBtn.Text             = "InfiniJump  ·  OFF"
            ijBtn.BackgroundColor3 = C.input
            if infiConn then infiConn:Disconnect() ; infiConn = nil end
            toast("🦘 InfiniJump OFF", C.muted)
        end
    end)

    mkToggle(abInner, "Noclip", 2, false, function(s)
        if s then
            _noclipConn = RunService.Stepped:Connect(function()
                local c = lp.Character
                if not c then return end
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        else
            if _noclipConn then _noclipConn:Disconnect() end
            local c = lp.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end
        toast(s and "👻 Noclip ON" or "👻 Noclip OFF", s and C.accent or C.muted)
    end, "noclip")

    mkToggle(abInner, "Fly  (ZQSD + Espace)", 3, false, function(s)
        local c    = lp.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if s then
            _bv = Instance.new("BodyVelocity")
            _bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            _bv.Velocity = Vector3.zero
            _bv.Parent   = root
            _bg = Instance.new("BodyGyro")
            _bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
            _bg.D = 100 ; _bg.Parent = root
            local cam = workspace.CurrentCamera
            _flyConn = RunService.Heartbeat:Connect(function()
                local d = Vector3.zero
                local u = UserInputService
                if u:IsKeyDown(Enum.KeyCode.W) or u:IsKeyDown(Enum.KeyCode.Z) then d=d+cam.CFrame.LookVector  end
                if u:IsKeyDown(Enum.KeyCode.S)                                  then d=d-cam.CFrame.LookVector  end
                if u:IsKeyDown(Enum.KeyCode.D)                                  then d=d+cam.CFrame.RightVector end
                if u:IsKeyDown(Enum.KeyCode.A) or u:IsKeyDown(Enum.KeyCode.Q)  then d=d-cam.CFrame.RightVector end
                if u:IsKeyDown(Enum.KeyCode.Space)                              then d=d+Vector3.yAxis           end
                if u:IsKeyDown(Enum.KeyCode.LeftControl)                        then d=d-Vector3.yAxis           end
                if _bv and _bv.Parent then
                    _bv.Velocity = d.Magnitude>0 and d.Unit*90 or Vector3.zero
                end
                if _bg and _bg.Parent then _bg.CFrame = cam.CFrame end
            end)
        else
            if _flyConn then _flyConn:Disconnect() end
            if _bv and _bv.Parent then _bv:Destroy() end
            if _bg and _bg.Parent then _bg:Destroy() end
        end
        toast(s and "🚀 Fly ON" or "🚀 Fly OFF", s and C.success or C.muted)
    end, "fly")
end

-- ════════════════════════════════════════════════════════════
--  CONTENU : ESP
-- ════════════════════════════════════════════════════════════
local _espSkeletonConns = {}
local _espNameConns     = {}
local _espBoxes         = {}
local _espNames         = {}

local ESP_COLOR  = Color3.fromRGB(120,80,220)
local NAME_COLOR = Color3.fromRGB(230,230,230)

local function espClearSkeleton()
    for _, v in pairs(_espBoxes) do if v and v.Parent then v:Destroy() end end
    _espBoxes = {}
    for _, c in pairs(_espSkeletonConns) do c:Disconnect() end
    _espSkeletonConns = {}
end

local function espClearNames()
    for _, v in pairs(_espNames) do if v and v.Parent then v:Destroy() end end
    _espNames = {}
    for _, c in pairs(_espNameConns) do c:Disconnect() end
    _espNameConns = {}
end

local function drawSkeleton(player)
    if player == lp then return end
    local char = player.Character
    if not char then return end

    local box = Instance.new("SelectionBox")
    box.Color3              = ESP_COLOR
    box.LineThickness       = 0.04
    box.SurfaceTransparency = 0.85
    box.SurfaceColor3       = ESP_COLOR
    box.Adornee             = char
    box.Parent              = workspace
    _espBoxes[player.Name]  = box

    local BONES = {
        {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
        {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
        {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
        {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
        {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    }

    local lines = {}
    for _, pair in ipairs(BONES) do
        local p0 = char:FindFirstChild(pair[1])
        local p1 = char:FindFirstChild(pair[2])
        if p0 and p1 then
            local beam = Instance.new("LineHandleAdornment")
            beam.Color3    = ESP_COLOR
            beam.Thickness = 2
            beam.ZIndex    = 5
            beam.Length    = 0
            beam.Adornee   = workspace.Terrain
            beam.Parent    = workspace.Terrain
            table.insert(lines, { beam=beam, p0=p0, p1=p1 })
        end
    end

    local conn = RunService.Heartbeat:Connect(function()
        for _, l in ipairs(lines) do
            if l.beam and l.beam.Parent and l.p0.Parent and l.p1.Parent then
                local a = l.p0.Position ; local b = l.p1.Position
                local mid = (a+b)/2 ; local dist = (b-a).Magnitude
                l.beam.CFrame = CFrame.new(mid, b)
                l.beam.Length = dist
            end
        end
    end)

    table.insert(_espSkeletonConns, conn)
    table.insert(_espSkeletonConns, player.CharacterRemoving:Connect(function()
        conn:Disconnect()
        for _, l in ipairs(lines) do if l.beam and l.beam.Parent then l.beam:Destroy() end end
        if box and box.Parent then box:Destroy() end
        _espBoxes[player.Name] = nil
    end))
    table.insert(_espSkeletonConns, player.CharacterAdded:Connect(function()
        task.wait(1) drawSkeleton(player)
    end))
end

local function drawName(player)
    if player == lp then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local bg = Instance.new("BillboardGui")
    bg.Name        = "_espName_" .. player.Name
    bg.Adornee     = head
    bg.AlwaysOnTop = true
    bg.Size        = UDim2.new(0,120,0,30)
    bg.StudsOffset = Vector3.new(0,2.5,0)
    bg.Parent      = workspace

    local nameL = Instance.new("TextLabel")
    nameL.Size                   = UDim2.new(1,0,1,0)
    nameL.BackgroundTransparency = 1
    nameL.Font                   = Enum.Font.GothamBold
    nameL.TextSize               = 14
    nameL.TextColor3             = NAME_COLOR
    nameL.TextStrokeTransparency = 0
    nameL.TextStrokeColor3       = Color3.fromRGB(0,0,0)
    nameL.Text                   = player.Name
    nameL.Parent                 = bg

    _espNames[player.Name] = bg

    table.insert(_espNameConns, player.CharacterRemoving:Connect(function()
        if bg and bg.Parent then bg:Destroy() end
        _espNames[player.Name] = nil
    end))
    table.insert(_espNameConns, player.CharacterAdded:Connect(function()
        task.wait(1) drawName(player)
    end))
end

local _skeletonOn = SavedConfig.espSkeleton
local _nameOn     = SavedConfig.espNames

local function refreshESP()
    if _skeletonOn then
        espClearSkeleton()
        for _, p in ipairs(Players:GetPlayers()) do drawSkeleton(p) end
    end
    if _nameOn then
        espClearNames()
        for _, p in ipairs(Players:GetPlayers()) do drawName(p) end
    end
end

local ESP_PALETTES = {
    { name="Violet", col=Color3.fromRGB(120,80,220)  },
    { name="Rouge",  col=Color3.fromRGB(220,60,60)   },
    { name="Vert",   col=Color3.fromRGB(60,200,100)  },
    { name="Cyan",   col=Color3.fromRGB(60,200,220)  },
    { name="Blanc",  col=Color3.fromRGB(230,230,230) },
}
local _espPaletteIdx = SavedConfig.espColor or 1
ESP_COLOR = ESP_PALETTES[_espPaletteIdx] and ESP_PALETTES[_espPaletteIdx].col or ESP_COLOR

local _distLoop
local function startDistLoop()
    if _distLoop then return end
    _distLoop = RunService.Heartbeat:Connect(function()
        if not _nameOn then return end
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                local bg    = _espNames[p.Name]
                local tRoot = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if bg and tRoot then
                    local dist  = math.floor((myRoot.Position - tRoot.Position).Magnitude)
                    local hum   = p.Character:FindFirstChildOfClass("Humanoid")
                    local hp    = hum and math.floor(hum.Health) or "?"
                    local maxhp = hum and math.floor(hum.MaxHealth) or "?"
                    local nameL = bg:FindFirstChildOfClass("TextLabel")
                    if nameL then
                        nameL.Text = p.Name .. "\n" .. dist .. "m  ❤ " .. hp .. "/" .. maxhp
                    end
                end
            end
        end
    end)
end

local function buildESP()
    local _, espInner = makeCard("ESP", 1)

    local colorRow = Instance.new("Frame")
    colorRow.Size                   = UDim2.new(1,0,0,32)
    colorRow.BackgroundTransparency = 1
    colorRow.LayoutOrder            = 0
    colorRow.ZIndex                 = 14
    colorRow.Parent                 = espInner

    lbl(colorRow, {
        Size           = UDim2.new(0,80,1,0),
        Font           = Enum.Font.Gotham,
        TextSize       = 12,
        TextColor3     = C.muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text           = "Couleur ESP",
        ZIndex         = 15,
    })

    local colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Size                   = UDim2.new(0, #ESP_PALETTES*26, 0, 22)
    colorPickerFrame.Position               = UDim2.new(1, -(#ESP_PALETTES*26), 0.5, -11)
    colorPickerFrame.BackgroundTransparency = 1
    colorPickerFrame.ZIndex                 = 15
    colorPickerFrame.Parent                 = colorRow

    for i, pal in ipairs(ESP_PALETTES) do
        local dot = Instance.new("TextButton")
        dot.Size             = UDim2.new(0,18,0,18)
        dot.Position         = UDim2.new(0,(i-1)*24,0.5,-9)
        dot.BackgroundColor3 = pal.col
        dot.BorderSizePixel  = i == _espPaletteIdx and 2 or 0
        dot.Text             = ""
        dot.AutoButtonColor  = false
        dot.ZIndex           = 16
        dot.Parent           = colorPickerFrame
        rnd(dot, 9)
        dot.MouseButton1Click:Connect(function()
            _espPaletteIdx = i
            ESP_COLOR = pal.col
            cfg("espColor", i)
            for _, box in pairs(_espBoxes) do
                if box and box.Parent then
                    box.Color3 = ESP_COLOR ; box.SurfaceColor3 = ESP_COLOR
                end
            end
            for _, child in ipairs(colorPickerFrame:GetChildren()) do
                child.BorderSizePixel = 0
            end
            dot.BorderSizePixel = 2
            toast("ESP → " .. pal.name, pal.col)
            if _skeletonOn or _nameOn then refreshESP() end
        end)
    end

    local skelRow = Instance.new("Frame")
    skelRow.Size                   = UDim2.new(1,0,0,32)
    skelRow.BackgroundTransparency = 1
    skelRow.LayoutOrder            = 1
    skelRow.ZIndex                 = 14
    skelRow.Parent                 = espInner

    lbl(skelRow, {
        Size           = UDim2.new(1,-120,1,0),
        Font           = Enum.Font.Gotham,
        TextSize       = 13,
        TextColor3     = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text           = "Squelette",
        ZIndex         = 15,
    })

    local skelTrack = Instance.new("Frame")
    skelTrack.Size             = UDim2.new(0,44,0,22)
    skelTrack.Position         = UDim2.new(1,-92,0.5,-11)
    skelTrack.BackgroundColor3 = _skeletonOn and C.accent or C.input
    skelTrack.BorderSizePixel  = 0
    skelTrack.ZIndex           = 15
    skelTrack.Parent           = skelRow
    rnd(skelTrack, 11)

    local skelKnob = Instance.new("Frame")
    skelKnob.Size             = UDim2.new(0,16,0,16)
    skelKnob.Position         = _skeletonOn and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8)
    skelKnob.BackgroundColor3 = C.white
    skelKnob.BorderSizePixel  = 0
    skelKnob.ZIndex           = 16
    skelKnob.Parent           = skelTrack
    rnd(skelKnob, 8)

    local skelHit = Instance.new("TextButton")
    skelHit.Size                   = UDim2.new(0,44,0,22)
    skelHit.Position               = UDim2.new(1,-92,0.5,-11)
    skelHit.BackgroundTransparency = 1
    skelHit.Text                   = ""
    skelHit.ZIndex                 = 17
    skelHit.Parent                 = skelRow

    skelHit.MouseButton1Click:Connect(function()
        _skeletonOn = not _skeletonOn
        cfg("espSkeleton", _skeletonOn)
        TweenService:Create(skelTrack, TweenInfo.new(0.15),
            { BackgroundColor3 = _skeletonOn and C.accent or C.input }):Play()
        TweenService:Create(skelKnob,
            TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = _skeletonOn and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8) }):Play()
        if _skeletonOn then
            for _, p in ipairs(Players:GetPlayers()) do drawSkeleton(p) end
            toast("💀 Squelette ESP ON", C.success)
        else
            espClearSkeleton()
            toast("💀 Squelette ESP OFF", C.muted)
        end
    end)

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size             = UDim2.new(0,40,0,22)
    refreshBtn.Position         = UDim2.new(1,-44,0.5,-11)
    refreshBtn.BackgroundColor3 = C.input
    refreshBtn.BorderSizePixel  = 0
    refreshBtn.Font             = Enum.Font.GothamBold
    refreshBtn.TextSize         = 12
    refreshBtn.TextColor3       = C.muted
    refreshBtn.Text             = "↺"
    refreshBtn.AutoButtonColor  = false
    refreshBtn.ZIndex           = 15
    refreshBtn.Parent           = skelRow
    rnd(refreshBtn, 5)
    refreshBtn.MouseEnter:Connect(function()
        TweenService:Create(refreshBtn, TweenInfo.new(0.1), { TextColor3 = C.accent }):Play()
    end)
    refreshBtn.MouseLeave:Connect(function()
        TweenService:Create(refreshBtn, TweenInfo.new(0.1), { TextColor3 = C.muted }):Play()
    end)
    refreshBtn.MouseButton1Click:Connect(function()
        refreshESP()
        toast("↺ ESP rafraîchi", C.accent)
    end)

    local nameRow = Instance.new("Frame")
    nameRow.Size                   = UDim2.new(1,0,0,32)
    nameRow.BackgroundTransparency = 1
    nameRow.LayoutOrder            = 2
    nameRow.ZIndex                 = 14
    nameRow.Parent                 = espInner

    lbl(nameRow, {
        Size           = UDim2.new(1,-60,1,0),
        Font           = Enum.Font.Gotham,
        TextSize       = 13,
        TextColor3     = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text           = "Pseudo + Distance + HP",
        ZIndex         = 15,
    })

    local nameTrack = Instance.new("Frame")
    nameTrack.Size             = UDim2.new(0,44,0,22)
    nameTrack.Position         = UDim2.new(1,-46,0.5,-11)
    nameTrack.BackgroundColor3 = _nameOn and C.accent or C.input
    nameTrack.BorderSizePixel  = 0
    nameTrack.ZIndex           = 15
    nameTrack.Parent           = nameRow
    rnd(nameTrack, 11)

    local nameKnob = Instance.new("Frame")
    nameKnob.Size             = UDim2.new(0,16,0,16)
    nameKnob.Position         = _nameOn and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8)
    nameKnob.BackgroundColor3 = C.white
    nameKnob.BorderSizePixel  = 0
    nameKnob.ZIndex           = 16
    nameKnob.Parent           = nameTrack
    rnd(nameKnob, 8)

    local nameHit = Instance.new("TextButton")
    nameHit.Size                   = UDim2.new(1,0,1,0)
    nameHit.BackgroundTransparency = 1
    nameHit.Text                   = ""
    nameHit.ZIndex                 = 17
    nameHit.Parent                 = nameRow

    nameHit.MouseButton1Click:Connect(function()
        _nameOn = not _nameOn
        cfg("espNames", _nameOn)
        TweenService:Create(nameTrack, TweenInfo.new(0.15),
            { BackgroundColor3 = _nameOn and C.accent or C.input }):Play()
        TweenService:Create(nameKnob,
            TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = _nameOn and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8) }):Play()
        if _nameOn then
            for _, p in ipairs(Players:GetPlayers()) do drawName(p) end
            startDistLoop()
            toast("🏷 Pseudo ESP ON", C.success)
        else
            espClearNames()
            toast("🏷 Pseudo ESP OFF", C.muted)
        end
    end)

    mkToggle(espInner, "Barre de vie", 3, false, function(s)
        for _, bg in pairs(_espNames) do
            local existing = bg:FindFirstChild("_hpBar")
            if s and not existing then
                local track = Instance.new("Frame")
                track.Name             = "_hpBar"
                track.Size             = UDim2.new(1,0,0,4)
                track.Position         = UDim2.new(0,0,1,2)
                track.BackgroundColor3 = C.input
                track.BorderSizePixel  = 0
                track.ZIndex           = 5
                track.Parent           = bg
                rnd(track, 2)
                local fill = Instance.new("Frame")
                fill.Name             = "_hpFill"
                fill.Size             = UDim2.new(1,0,1,0)
                fill.BackgroundColor3 = C.success
                fill.BorderSizePixel  = 0
                fill.ZIndex           = 6
                fill.Parent           = track
                rnd(fill, 2)
            elseif not s and existing then
                existing:Destroy()
            end
        end
        if s then
            task.spawn(function()
                while s do
                    for _, p in ipairs(Players:GetPlayers()) do
                        local bg = _espNames[p.Name]
                        if bg then
                            local track = bg:FindFirstChild("_hpBar")
                            local fill  = track and track:FindFirstChild("_hpFill")
                            local hum   = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                            if fill and hum and hum.MaxHealth > 0 then
                                local ratio = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                                fill.Size = UDim2.new(ratio,0,1,0)
                                fill.BackgroundColor3 = ratio > 0.5
                                    and Color3.fromRGB(60,200,100)
                                    or  ratio > 0.25
                                    and Color3.fromRGB(220,180,40)
                                    or  Color3.fromRGB(210,60,60)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
        toast(s and "❤ Barre de vie ON" or "❤ Barre de vie OFF",
              s and C.success or C.muted)
    end, "espHPBar")

    -- Restaure les états sauvegardés au chargement
    if _skeletonOn then
        for _, p in ipairs(Players:GetPlayers()) do drawSkeleton(p) end
    end
    if _nameOn then
        for _, p in ipairs(Players:GetPlayers()) do drawName(p) end
        startDistLoop()
    end
end

-- ════════════════════════════════════════════════════════════
--  CONTENU : VISUAL
-- ════════════════════════════════════════════════════════════
local function buildVisual()
    local _, featInner = makeCard("Features Visuelles", 1)

    mkToggle(featInner, "Full Bright", 1, false, function(s)
        setFullBright(s)
        toast(s and "☀ Full Bright ON" or "☀ Full Bright OFF",
              s and C.success or C.muted)
    end, "fullBright")

    mkToggle(featInner, "X-Ray (murs)", 2, false, function(s)
        setXRay(s)
        toast(s and "👁 X-Ray ON" or "👁 X-Ray OFF",
              s and C.success or C.muted)
    end, "xray")

    mkToggle(featInner, "Radar", 3, false, function(s)
        if s then startRadar() else stopRadar() end
        toast(s and "📡 Radar ON" or "📡 Radar OFF",
              s and C.success or C.muted)
    end, "radar")

    local _, sysInner = makeCard("Système", 2)

    mkToggle(sysInner, "Unlock FPS", 1, false, function(s)
        if s then
            unlockFPS()
            toast("⚡ FPS débloqué", C.success)
        else
            pcall(setfpscap, 60)
            toast("⚡ FPS → 60", C.muted)
        end
    end, "unlockFPS")

    mkToggle(sysInner, "Anti-AFK", 2, false, function(s)
        if s then
            startAntiAFK()
            toast("✓ Anti-AFK ON", C.success)
        else
            toast("Anti-AFK OFF", C.muted)
        end
    end, "antiAFK")
end

-- ════════════════════════════════════════════════════════════
--  THEMES
-- ════════════════════════════════════════════════════════════
local THEMES = {
    { name="Sinix",           accent=Color3.fromRGB(120,80,220),  bg=Color3.fromRGB(18,18,18),  card=Color3.fromRGB(30,30,30),  sidebar=Color3.fromRGB(24,24,24),  text=Color3.fromRGB(230,230,230) },
    { name="Forêt",           accent=Color3.fromRGB(34,85,34),    bg=Color3.fromRGB(15,25,15),  card=Color3.fromRGB(22,38,22),  sidebar=Color3.fromRGB(18,30,18),  text=Color3.fromRGB(200,220,190) },
    { name="Océan",           accent=Color3.fromRGB(0,180,200),   bg=Color3.fromRGB(8,18,32),   card=Color3.fromRGB(12,28,48),  sidebar=Color3.fromRGB(10,22,40),  text=Color3.fromRGB(200,240,250) },
    { name="Désert",          accent=Color3.fromRGB(200,130,60),  bg=Color3.fromRGB(28,20,14),  card=Color3.fromRGB(42,30,20),  sidebar=Color3.fromRGB(35,25,16),  text=Color3.fromRGB(240,220,190) },
    { name="Jungle",          accent=Color3.fromRGB(50,160,60),   bg=Color3.fromRGB(10,22,12),  card=Color3.fromRGB(16,34,18),  sidebar=Color3.fromRGB(12,28,14),  text=Color3.fromRGB(190,230,180) },
    { name="Montagne",        accent=Color3.fromRGB(130,170,200), bg=Color3.fromRGB(18,20,24),  card=Color3.fromRGB(28,32,38),  sidebar=Color3.fromRGB(22,26,30),  text=Color3.fromRGB(220,230,240) },
    { name="Prairie",         accent=Color3.fromRGB(100,200,80),  bg=Color3.fromRGB(14,22,10),  card=Color3.fromRGB(22,34,16),  sidebar=Color3.fromRGB(18,28,12),  text=Color3.fromRGB(210,240,200) },
    { name="Automne",         accent=Color3.fromRGB(210,100,30),  bg=Color3.fromRGB(22,14,8),   card=Color3.fromRGB(36,22,12),  sidebar=Color3.fromRGB(28,18,10),  text=Color3.fromRGB(240,210,170) },
    { name="Printemps",       accent=Color3.fromRGB(220,140,180), bg=Color3.fromRGB(20,22,18),  card=Color3.fromRGB(32,34,28),  sidebar=Color3.fromRGB(26,28,22),  text=Color3.fromRGB(240,230,240) },
    { name="Hiver",           accent=Color3.fromRGB(160,210,240), bg=Color3.fromRGB(18,20,26),  card=Color3.fromRGB(28,32,42),  sidebar=Color3.fromRGB(22,26,34),  text=Color3.fromRGB(230,240,255) },
    { name="Été",             accent=Color3.fromRGB(255,180,0),   bg=Color3.fromRGB(20,18,10),  card=Color3.fromRGB(32,28,14),  sidebar=Color3.fromRGB(26,22,10),  text=Color3.fromRGB(255,240,200) },
    { name="Crépuscule",      accent=Color3.fromRGB(240,100,60),  bg=Color3.fromRGB(22,10,18),  card=Color3.fromRGB(36,16,28),  sidebar=Color3.fromRGB(28,12,22),  text=Color3.fromRGB(255,220,200) },
    { name="Aurore",          accent=Color3.fromRGB(220,80,160),  bg=Color3.fromRGB(18,8,24),   card=Color3.fromRGB(30,12,40),  sidebar=Color3.fromRGB(24,10,32),  text=Color3.fromRGB(255,200,230) },
    { name="Soleil Couchant", accent=Color3.fromRGB(255,140,0),   bg=Color3.fromRGB(20,10,6),   card=Color3.fromRGB(34,16,8),   sidebar=Color3.fromRGB(26,12,6),   text=Color3.fromRGB(255,225,180) },
    { name="Galaxie",         accent=Color3.fromRGB(100,60,220),  bg=Color3.fromRGB(6,6,18),    card=Color3.fromRGB(10,10,30),  sidebar=Color3.fromRGB(8,8,24),    text=Color3.fromRGB(200,190,255) },
    { name="Nébuleuse",       accent=Color3.fromRGB(200,60,180),  bg=Color3.fromRGB(8,4,16),    card=Color3.fromRGB(14,6,26),   sidebar=Color3.fromRGB(10,5,20),   text=Color3.fromRGB(240,200,255) },
    { name="Cosmos",          accent=Color3.fromRGB(60,160,240),  bg=Color3.fromRGB(4,6,18),    card=Color3.fromRGB(6,10,28),   sidebar=Color3.fromRGB(5,8,22),    text=Color3.fromRGB(180,220,255) },
    { name="Feu",             accent=Color3.fromRGB(255,80,0),    bg=Color3.fromRGB(18,6,4),    card=Color3.fromRGB(30,10,6),   sidebar=Color3.fromRGB(24,8,4),    text=Color3.fromRGB(255,210,180) },
    { name="Braise",          accent=Color3.fromRGB(200,60,20),   bg=Color3.fromRGB(14,6,4),    card=Color3.fromRGB(24,10,6),   sidebar=Color3.fromRGB(18,8,4),    text=Color3.fromRGB(240,200,170) },
    { name="Glace",           accent=Color3.fromRGB(140,220,255), bg=Color3.fromRGB(16,20,28),  card=Color3.fromRGB(22,30,42),  sidebar=Color3.fromRGB(18,24,34),  text=Color3.fromRGB(220,240,255) },
    { name="Blizzard",        accent=Color3.fromRGB(180,230,255), bg=Color3.fromRGB(20,22,30),  card=Color3.fromRGB(30,34,46),  sidebar=Color3.fromRGB(24,28,38),  text=Color3.fromRGB(230,245,255) },
    { name="Bonbons",         accent=Color3.fromRGB(255,120,180), bg=Color3.fromRGB(22,16,24),  card=Color3.fromRGB(34,24,36),  sidebar=Color3.fromRGB(28,20,30),  text=Color3.fromRGB(255,230,245) },
    { name="Sucré",           accent=Color3.fromRGB(160,200,255), bg=Color3.fromRGB(18,18,28),  card=Color3.fromRGB(28,28,42),  sidebar=Color3.fromRGB(22,22,34),  text=Color3.fromRGB(230,240,255) },
    { name="Tropical",        accent=Color3.fromRGB(0,210,180),   bg=Color3.fromRGB(8,20,16),   card=Color3.fromRGB(12,32,24),  sidebar=Color3.fromRGB(10,26,20),  text=Color3.fromRGB(200,255,240) },
    { name="Lagon",           accent=Color3.fromRGB(0,190,220),   bg=Color3.fromRGB(6,18,22),   card=Color3.fromRGB(10,28,34),  sidebar=Color3.fromRGB(8,22,28),   text=Color3.fromRGB(180,245,255) },
    { name="Futuriste",       accent=Color3.fromRGB(0,220,220),   bg=Color3.fromRGB(6,8,14),    card=Color3.fromRGB(10,12,22),  sidebar=Color3.fromRGB(8,10,18),   text=Color3.fromRGB(180,255,255) },
    { name="Synthwave",       accent=Color3.fromRGB(200,0,220),   bg=Color3.fromRGB(8,4,14),    card=Color3.fromRGB(14,6,22),   sidebar=Color3.fromRGB(10,5,18),   text=Color3.fromRGB(240,180,255) },
    { name="Cyberpunk",       accent=Color3.fromRGB(255,0,180),   bg=Color3.fromRGB(6,6,10),    card=Color3.fromRGB(10,10,16),  sidebar=Color3.fromRGB(8,8,12),    text=Color3.fromRGB(255,200,255) },
    { name="Neon Noir",       accent=Color3.fromRGB(0,240,180),   bg=Color3.fromRGB(4,4,8),     card=Color3.fromRGB(8,8,14),    sidebar=Color3.fromRGB(6,6,10),    text=Color3.fromRGB(180,255,220) },
    { name="Vintage",         accent=Color3.fromRGB(180,120,60),  bg=Color3.fromRGB(22,18,14),  card=Color3.fromRGB(34,28,20),  sidebar=Color3.fromRGB(28,22,16),  text=Color3.fromRGB(235,220,195) },
    { name="Sépia",           accent=Color3.fromRGB(160,100,50),  bg=Color3.fromRGB(20,16,10),  card=Color3.fromRGB(30,24,14),  sidebar=Color3.fromRGB(24,18,10),  text=Color3.fromRGB(230,210,180) },
    { name="Luxe Noir",       accent=Color3.fromRGB(200,160,60),  bg=Color3.fromRGB(10,10,10),  card=Color3.fromRGB(18,18,18),  sidebar=Color3.fromRGB(14,14,14),  text=Color3.fromRGB(240,220,160) },
    { name="Émeraude Or",     accent=Color3.fromRGB(200,160,40),  bg=Color3.fromRGB(6,16,10),   card=Color3.fromRGB(10,26,16),  sidebar=Color3.fromRGB(8,20,12),   text=Color3.fromRGB(230,220,170) },
    { name="Bordeaux Or",     accent=Color3.fromRGB(200,160,40),  bg=Color3.fromRGB(18,6,8),    card=Color3.fromRGB(28,10,12),  sidebar=Color3.fromRGB(22,8,10),   text=Color3.fromRGB(240,210,170) },
    { name="Royal Bleu",      accent=Color3.fromRGB(60,100,220),  bg=Color3.fromRGB(8,10,22),   card=Color3.fromRGB(12,16,34),  sidebar=Color3.fromRGB(10,12,28),  text=Color3.fromRGB(200,220,255) },
    { name="Royal Violet",    accent=Color3.fromRGB(140,60,220),  bg=Color3.fromRGB(12,6,20),   card=Color3.fromRGB(20,10,32),  sidebar=Color3.fromRGB(16,8,26),   text=Color3.fromRGB(220,190,255) },
    { name="Halloween",       accent=Color3.fromRGB(220,90,0),    bg=Color3.fromRGB(10,6,14),   card=Color3.fromRGB(16,8,22),   sidebar=Color3.fromRGB(12,6,18),   text=Color3.fromRGB(255,200,150) },
    { name="Noël",            accent=Color3.fromRGB(200,40,40),   bg=Color3.fromRGB(6,14,6),    card=Color3.fromRGB(10,22,10),  sidebar=Color3.fromRGB(8,18,8),    text=Color3.fromRGB(255,230,200) },
    { name="Saint-Valentin",  accent=Color3.fromRGB(220,40,80),   bg=Color3.fromRGB(20,6,10),   card=Color3.fromRGB(32,10,16),  sidebar=Color3.fromRGB(26,8,12),   text=Color3.fromRGB(255,200,210) },
    { name="Halloween Pastel",accent=Color3.fromRGB(180,100,220), bg=Color3.fromRGB(16,10,20),  card=Color3.fromRGB(26,16,32),  sidebar=Color3.fromRGB(20,12,26),  text=Color3.fromRGB(230,210,255) },
    { name="Pirate",          accent=Color3.fromRGB(180,140,40),  bg=Color3.fromRGB(10,8,6),    card=Color3.fromRGB(18,14,10),  sidebar=Color3.fromRGB(14,10,8),   text=Color3.fromRGB(230,210,170) },
    { name="Arc-en-ciel",     accent=Color3.fromRGB(120,80,220),  bg=Color3.fromRGB(12,10,18),  card=Color3.fromRGB(20,16,28),  sidebar=Color3.fromRGB(16,12,22),  text=Color3.fromRGB(230,220,255) },
    { name="Pastel",          accent=Color3.fromRGB(200,160,220), bg=Color3.fromRGB(20,18,24),  card=Color3.fromRGB(30,28,36),  sidebar=Color3.fromRGB(24,22,30),  text=Color3.fromRGB(245,235,255) },
    { name="Néon Rose",       accent=Color3.fromRGB(255,40,160),  bg=Color3.fromRGB(10,4,12),   card=Color3.fromRGB(16,6,20),   sidebar=Color3.fromRGB(12,5,16),   text=Color3.fromRGB(255,200,240) },
    { name="Néon Vert",       accent=Color3.fromRGB(40,255,120),  bg=Color3.fromRGB(4,12,6),    card=Color3.fromRGB(6,20,10),   sidebar=Color3.fromRGB(5,16,8),    text=Color3.fromRGB(180,255,210) },
    { name="Néon Bleu",       accent=Color3.fromRGB(40,160,255),  bg=Color3.fromRGB(4,8,16),    card=Color3.fromRGB(6,12,24),   sidebar=Color3.fromRGB(5,10,20),   text=Color3.fromRGB(180,220,255) },
    { name="Terre",           accent=Color3.fromRGB(180,100,50),  bg=Color3.fromRGB(20,14,10),  card=Color3.fromRGB(30,20,14),  sidebar=Color3.fromRGB(24,16,10),  text=Color3.fromRGB(230,210,185) },
    { name="Café",            accent=Color3.fromRGB(160,100,60),  bg=Color3.fromRGB(16,10,6),   card=Color3.fromRGB(26,16,10),  sidebar=Color3.fromRGB(20,12,8),   text=Color3.fromRGB(225,200,170) },
    { name="Océan Profond",   accent=Color3.fromRGB(0,140,180),   bg=Color3.fromRGB(4,10,18),   card=Color3.fromRGB(6,16,28),   sidebar=Color3.fromRGB(5,12,22),   text=Color3.fromRGB(170,220,240) },
    { name="Sakura",          accent=Color3.fromRGB(240,160,190), bg=Color3.fromRGB(22,18,20),  card=Color3.fromRGB(34,26,30),  sidebar=Color3.fromRGB(28,22,24),  text=Color3.fromRGB(255,230,240) },
    { name="Volcan",          accent=Color3.fromRGB(220,50,0),    bg=Color3.fromRGB(8,4,4),     card=Color3.fromRGB(14,6,6),    sidebar=Color3.fromRGB(10,5,5),    text=Color3.fromRGB(255,200,170) },
    { name="Amazonie",        accent=Color3.fromRGB(40,180,80),   bg=Color3.fromRGB(6,16,8),    card=Color3.fromRGB(10,26,12),  sidebar=Color3.fromRGB(8,20,10),   text=Color3.fromRGB(190,240,200) },
    { name="Minéral",         accent=Color3.fromRGB(100,180,160), bg=Color3.fromRGB(14,16,18),  card=Color3.fromRGB(22,24,28),  sidebar=Color3.fromRGB(18,20,22),  text=Color3.fromRGB(200,220,215) },
    { name="Mono Gris",       accent=Color3.fromRGB(160,160,160), bg=Color3.fromRGB(10,10,10),  card=Color3.fromRGB(18,18,18),  sidebar=Color3.fromRGB(14,14,14),  text=Color3.fromRGB(220,220,220) },
    { name="Mono Bleu",       accent=Color3.fromRGB(100,160,240), bg=Color3.fromRGB(6,10,20),   card=Color3.fromRGB(10,16,30),  sidebar=Color3.fromRGB(8,12,24),   text=Color3.fromRGB(200,220,255) },
    { name="Mono Vert",       accent=Color3.fromRGB(80,180,100),  bg=Color3.fromRGB(6,14,8),    card=Color3.fromRGB(10,22,12),  sidebar=Color3.fromRGB(8,18,10),   text=Color3.fromRGB(190,235,200) },
    { name="Minecraft",       accent=Color3.fromRGB(100,160,60),  bg=Color3.fromRGB(14,10,6),   card=Color3.fromRGB(22,16,10),  sidebar=Color3.fromRGB(18,12,8),   text=Color3.fromRGB(220,235,200) },
    { name="Mario",           accent=Color3.fromRGB(220,40,40),   bg=Color3.fromRGB(10,14,30),  card=Color3.fromRGB(14,20,44),  sidebar=Color3.fromRGB(12,18,36),  text=Color3.fromRGB(255,240,160) },
    { name="Sonic",           accent=Color3.fromRGB(40,100,220),  bg=Color3.fromRGB(6,8,20),    card=Color3.fromRGB(8,12,30),   sidebar=Color3.fromRGB(7,10,24),   text=Color3.fromRGB(180,210,255) },
    { name="Pokémon",         accent=Color3.fromRGB(240,60,60),   bg=Color3.fromRGB(14,10,18),  card=Color3.fromRGB(22,16,28),  sidebar=Color3.fromRGB(18,12,22),  text=Color3.fromRGB(255,240,180) },
    { name="Fraise",          accent=Color3.fromRGB(220,40,80),   bg=Color3.fromRGB(20,8,12),   card=Color3.fromRGB(30,12,18),  sidebar=Color3.fromRGB(24,10,14),  text=Color3.fromRGB(255,210,220) },
    { name="Citron",          accent=Color3.fromRGB(220,210,40),  bg=Color3.fromRGB(16,16,6),   card=Color3.fromRGB(24,24,10),  sidebar=Color3.fromRGB(20,20,8),   text=Color3.fromRGB(255,250,200) },
    { name="Myrtille",        accent=Color3.fromRGB(100,80,200),  bg=Color3.fromRGB(10,8,20),   card=Color3.fromRGB(16,12,30),  sidebar=Color3.fromRGB(12,10,24),  text=Color3.fromRGB(210,200,255) },
    { name="Pastèque",        accent=Color3.fromRGB(220,50,70),   bg=Color3.fromRGB(8,18,8),    card=Color3.fromRGB(12,28,12),  sidebar=Color3.fromRGB(10,22,10),  text=Color3.fromRGB(255,210,210) },
    { name="Kiwi",            accent=Color3.fromRGB(120,180,40),  bg=Color3.fromRGB(10,16,6),   card=Color3.fromRGB(16,24,10),  sidebar=Color3.fromRGB(12,20,8),   text=Color3.fromRGB(210,240,180) },
    { name="Caramel",         accent=Color3.fromRGB(200,140,60),  bg=Color3.fromRGB(18,12,6),   card=Color3.fromRGB(28,18,10),  sidebar=Color3.fromRGB(22,14,8),   text=Color3.fromRGB(245,220,180) },
}

local function applyTheme(theme)
    C.accent  = theme.accent
    C.accentD = Color3.fromRGB(
        math.max(0, math.floor(theme.accent.R*255) - 30),
        math.max(0, math.floor(theme.accent.G*255) - 30),
        math.max(0, math.floor(theme.accent.B*255) - 30)
    )
    C.bg      = theme.bg
    C.card    = theme.card
    C.sidebar = theme.sidebar
    C.text    = theme.text

    Win.BackgroundColor3               = C.bg
    Sidebar.BackgroundColor3           = C.sidebar
    sbCover.BackgroundColor3           = C.sidebar
    TopBar.BackgroundColor3            = C.bg
    footer.TextColor3                  = C.muted
    ContentScroll.ScrollBarImageColor3 = C.accent

    for _, v in ipairs(Win:GetDescendants()) do
        if v:IsA("Frame") then
            local r,g,b = math.floor(v.BackgroundColor3.R*255),
                          math.floor(v.BackgroundColor3.G*255),
                          math.floor(v.BackgroundColor3.B*255)
            if r==30 and g==30 and b==30       then v.BackgroundColor3 = C.card
            elseif r==24 and g==24 and b==24   then v.BackgroundColor3 = C.sidebar
            elseif r==18 and g==18 and b==18   then v.BackgroundColor3 = C.bg
            elseif r==120 and g==80 and b==220 then v.BackgroundColor3 = C.accent end
        end
        if v:IsA("TextLabel") then
            local r,g,b = math.floor(v.TextColor3.R*255),
                          math.floor(v.TextColor3.G*255),
                          math.floor(v.TextColor3.B*255)
            if r==230 and g==230 and b==230    then v.TextColor3 = C.text
            elseif r==120 and g==80 and b==220 then v.TextColor3 = C.accent end
        end
        if v:IsA("TextButton") then
            local r,g,b = math.floor(v.BackgroundColor3.R*255),
                          math.floor(v.BackgroundColor3.G*255),
                          math.floor(v.BackgroundColor3.B*255)
            if r==120 and g==80 and b==220 then v.BackgroundColor3 = C.accent end
        end
        if v:IsA("UIStroke") then
            local r,g,b = math.floor(v.Color.R*255),
                          math.floor(v.Color.G*255),
                          math.floor(v.Color.B*255)
            if r==120 and g==80 and b==220 then v.Color = C.accent end
        end
    end

    if activeTabBtn then
        local bar = activeTabBtn:FindFirstChild("bar")
        if bar then bar.BackgroundColor3 = C.accent end
        activeTabBtn.TextColor3 = C.text
    end

    if _skeletonOn or _nameOn then
        ESP_COLOR = C.accent
        refreshESP()
    end
end

-- Applique le thème sauvegardé au démarrage
if SavedConfig.themeIndex and THEMES[SavedConfig.themeIndex] then
    task.defer(function() applyTheme(THEMES[SavedConfig.themeIndex]) end)
end

-- ════════════════════════════════════════════════════════════
--  CONTENU : SETTINGS
-- ════════════════════════════════════════════════════════════
local function buildSettings()
    local _, uiInner = makeCard("Interface", 1)

    mkSlider(uiInner, "FOV", 50, 120, 70, 1, function(v)
        workspace.CurrentCamera.FieldOfView = v
    end, "fov")

    mkToggle(uiInner, "Afficher le footer", 2, true, function(s)
        footer.Visible = s
    end, "showFooter")

    mkButton(uiInner, "Fermer l'interface", 3, function()
        Root:Destroy()
    end)

    local _, saveInner = makeCard("Sauvegarde", 2)

    local statusLbl = lbl(saveInner, {
        Size           = UDim2.new(1,0,0,20),
        Font           = Enum.Font.Gotham,
        TextSize       = 12,
        TextColor3     = C.muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text           = "📂 Fichier : " .. SAVE_FILE,
        LayoutOrder    = 1,
        ZIndex         = 15,
    })

    mkButton(saveInner, "💾 Sauvegarder maintenant", 2, function()
        local ok = saveConfig()
        toast(ok and "✓ Config sauvegardée" or "❌ Échec de la sauvegarde",
              ok and C.success or C.err)
    end)

    mkButton(saveInner, "🗑 Réinitialiser la config", 3, function()
        pcall(delfile, SAVE_FILE)
        SavedConfig = {
            walkSpeed=16, jumpPower=50, gravity=196, fov=70,
            fullBright=false, xray=false, radar=false,
            unlockFPS=false, antiAFK=false, noclip=false,
            fly=false, infiniJump=false, freezePos=false,
            autoOpen=false, espSkeleton=false, espNames=false,
            espHPBar=false, espColor=1, showFooter=true, themeIndex=1,
        }
        toast("🗑 Config réinitialisée — relance le hub", C.err)
    end)

    local _, infoInner = makeCard("Session", 3)
    local rows = {
        "Joueur : "  .. lp.Name,
        "UserId : "  .. lp.UserId,
        "PlaceId : " .. game.PlaceId,
        "Joueurs : " .. #Players:GetPlayers(),
    }
    for i, r in ipairs(rows) do
        lbl(infoInner, {
            Size           = UDim2.new(1,0,0,20),
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextColor3     = C.muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text           = r,
            LayoutOrder    = i,
            ZIndex         = 15,
        })
    end

    local _, themeInner = makeCard("Thèmes", 4)

    local searchTheme = Instance.new("TextBox")
    searchTheme.Size              = UDim2.new(1,0,0,28)
    searchTheme.BackgroundColor3  = C.input
    searchTheme.BorderSizePixel   = 0
    searchTheme.Font              = Enum.Font.Gotham
    searchTheme.TextSize          = 13
    searchTheme.TextColor3        = C.text
    searchTheme.PlaceholderText   = "Filtrer les thèmes..."
    searchTheme.PlaceholderColor3 = C.muted
    searchTheme.ClearTextOnFocus  = false
    searchTheme.LayoutOrder       = 0
    searchTheme.ZIndex            = 15
    searchTheme.Parent            = themeInner
    rnd(searchTheme, 5)
    bdr(searchTheme, C.border)

    local themeScroll = Instance.new("ScrollingFrame")
    themeScroll.Size                   = UDim2.new(1,0,0,300)
    themeScroll.BackgroundTransparency = 1
    themeScroll.BorderSizePixel        = 0
    themeScroll.ScrollBarThickness     = 3
    themeScroll.ScrollBarImageColor3   = C.accent
    themeScroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    themeScroll.CanvasSize             = UDim2.new(0,0,0,0)
    themeScroll.LayoutOrder            = 1
    themeScroll.ZIndex                 = 15
    themeScroll.Parent                 = themeInner

    local themeGrid = Instance.new("UIGridLayout")
    themeGrid.CellSize    = UDim2.new(0.5,-6,0,52)
    themeGrid.CellPadding = UDim2.new(0,8,0,8)
    themeGrid.SortOrder   = Enum.SortOrder.LayoutOrder
    themeGrid.Parent      = themeScroll

    local themePad = Instance.new("UIPadding")
    themePad.PaddingTop    = UDim.new(0,4)
    themePad.PaddingBottom = UDim.new(0,4)
    themePad.Parent        = themeScroll

    local themeButtons      = {}
    local activeThemeStroke = nil

    local function buildThemeButtons(filter)
        for _, b in ipairs(themeButtons) do b:Destroy() end
        themeButtons      = {}
        activeThemeStroke = nil

        local lf  = filter:lower()
        local idx = 0
        for ti, theme in ipairs(THEMES) do
            if lf=="" or theme.name:lower():find(lf, 1, true) then
                idx = idx + 1
                local btn = Instance.new("TextButton")
                btn.Size             = UDim2.new(1,0,1,0)
                btn.BackgroundColor3 = theme.bg
                btn.BorderSizePixel  = 0
                btn.AutoButtonColor  = false
                btn.LayoutOrder      = idx
                btn.ClipsDescendants = true
                btn.ZIndex           = 16
                btn.Parent           = themeScroll
                rnd(btn, 7)

                local accentBar = Instance.new("Frame")
                accentBar.Size             = UDim2.new(1,0,0,4)
                accentBar.Position         = UDim2.new(0,0,0,0)
                accentBar.BackgroundColor3 = theme.accent
                accentBar.BorderSizePixel  = 0
                accentBar.ZIndex           = 17
                accentBar.Parent           = btn
                rnd(accentBar, 3)

                lbl(btn, {
                    Size           = UDim2.new(1,-8,0,18),
                    Position       = UDim2.new(0,6,0,8),
                    Font           = Enum.Font.GothamBold,
                    TextSize       = 11,
                    TextColor3     = theme.text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text           = theme.name,
                    ZIndex         = 18,
                })

                local dotRow = Instance.new("Frame")
                dotRow.Size                   = UDim2.new(0,72,0,10)
                dotRow.Position               = UDim2.new(0,6,1,-16)
                dotRow.BackgroundTransparency = 1
                dotRow.ZIndex                 = 17
                dotRow.Parent                 = btn

                local dotColors = { theme.accent, theme.card, theme.sidebar, theme.text }
                for j, col in ipairs(dotColors) do
                    local d = Instance.new("Frame")
                    d.Size             = UDim2.new(0,10,0,10)
                    d.Position         = UDim2.new(0,(j-1)*14,0,0)
                    d.BackgroundColor3 = col
                    d.BorderSizePixel  = 0
                    d.ZIndex           = 18
                    d.Parent           = dotRow
                    rnd(d, 5)
                end

                local stroke = bdr(btn, C.border, 1)

                btn.MouseEnter:Connect(function()
                    TweenService:Create(stroke, TweenInfo.new(0.1),
                        { Color=theme.accent, Thickness=1.5 }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    if activeThemeStroke ~= stroke then
                        TweenService:Create(stroke, TweenInfo.new(0.1),
                            { Color=C.border, Thickness=1 }):Play()
                    end
                end)
                btn.MouseButton1Click:Connect(function()
                    if activeThemeStroke then
                        activeThemeStroke.Color     = C.border
                        activeThemeStroke.Thickness = 1
                    end
                    activeThemeStroke       = stroke
                    stroke.Color            = theme.accent
                    stroke.Thickness        = 2
                    cfg("themeIndex", ti)
                    applyTheme(theme)
                    toast("🎨 Thème : " .. theme.name, theme.accent)
                end)

                table.insert(themeButtons, btn)
            end
        end
    end

    buildThemeButtons("")
    searchTheme:GetPropertyChangedSignal("Text"):Connect(function()
        buildThemeButtons(searchTheme.Text)
    end)
end

-- ════════════════════════════════════════════════════════════
--  SIDEBAR TABS
-- ════════════════════════════════════════════════════════════
local tMain,      activateMain      = mkSidebarTab("Main",      1, buildMain)
local tTeleports, activateTeleports = mkSidebarTab("Teleports", 2, buildTeleports)
local tMisc,      activateMisc      = mkSidebarTab("Misc",      3, buildMisc)
local tESP,       activateESP       = mkSidebarTab("ESP",       4, buildESP)
local tVisual,    activateVisual    = mkSidebarTab("Visual",    5, buildVisual)
local tSettings,  activateSettings  = mkSidebarTab("Settings",  6, buildSettings)

-- ════════════════════════════════════════════════════════════
--  TOGGLE MENU  (RightShift)
-- ════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        menuOpen = not menuOpen
        if menuOpen then
            Win.Visible = true
            Win.Size    = UDim2.new(0, MW-60, 0, MH-40)
            TweenService:Create(Win,
                TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Size = UDim2.new(0,MW,0,MH) }):Play()
        else
            TweenService:Create(Win,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { Size = UDim2.new(0,MW-60,0,MH-40), BackgroundTransparency=1 }):Play()
            task.wait(0.27)
            Win.Visible                = false
            Win.BackgroundTransparency = 0
            Win.Size                   = UDim2.new(0,MW,0,MH)
        end
    end
end)

-- ════════════════════════════════════════════════════════════
--  SPLASH SCREEN
-- ════════════════════════════════════════════════════════════
local function buildSplash()
    local splash = Instance.new("Frame")
    splash.Size             = UDim2.new(1,0,1,0)
    splash.BackgroundColor3 = C.bg
    splash.BorderSizePixel  = 0
    splash.ZIndex           = 100
    splash.Parent           = Win
    rnd(splash, 10)

    local grad = Instance.new("UIGradient")
    grad.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(24,16,48)),
        ColorSequenceKeypoint.new(1, C.bg),
    })
    grad.Rotation = 135
    grad.Parent   = splash

    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size             = UDim2.new(0,110,0,110)
    avatarFrame.AnchorPoint      = Vector2.new(0.5,0)
    avatarFrame.Position         = UDim2.new(0.5,0,0,90)
    avatarFrame.BackgroundColor3 = C.accent
    avatarFrame.BorderSizePixel  = 0
    avatarFrame.ZIndex           = 102
    avatarFrame.Parent           = splash
    rnd(avatarFrame, 55)
    bdr(avatarFrame, C.accent, 2)

    local avatar = Instance.new("ImageLabel")
    avatar.Size                   = UDim2.new(1,-4,1,-4)
    avatar.Position               = UDim2.new(0,2,0,2)
    avatar.BackgroundTransparency = 1
    avatar.BorderSizePixel        = 0
    avatar.Image                  = string.format(
        "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png",
        lp.UserId
    )
    avatar.ZIndex = 103
    avatar.Parent = avatarFrame
    rnd(avatar, 53)

    local halo = Instance.new("Frame")
    halo.Size                   = UDim2.new(0,126,0,126)
    halo.AnchorPoint            = Vector2.new(0.5,0.5)
    halo.Position               = UDim2.new(0.5,0,0,145)
    halo.BackgroundTransparency = 1
    halo.BorderSizePixel        = 0
    halo.ZIndex                 = 101
    halo.Parent                 = splash

    local haloStroke = Instance.new("UIStroke")
    haloStroke.Color        = C.accent
    haloStroke.Thickness    = 2
    haloStroke.Transparency = 0.4
    haloStroke.Parent       = halo
    rnd(halo, 63)

    task.spawn(function()
        while halo and halo.Parent do
            TweenService:Create(haloStroke, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Transparency=0.85 }):Play()
            task.wait(1.1)
            TweenService:Create(haloStroke, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Transparency=0.2 }):Play()
            task.wait(1.1)
        end
    end)

    lbl(splash, {
        Size       = UDim2.new(1,-40,0,32),
        Position   = UDim2.new(0,20,0,218),
        Font       = Enum.Font.GothamBold,
        TextSize   = 22,
        TextColor3 = C.white,
        Text       = lp.DisplayName,
        ZIndex     = 102,
    })

    lbl(splash, {
        Size       = UDim2.new(1,-40,0,20),
        Position   = UDim2.new(0,20,0,255),
        Font       = Enum.Font.Gotham,
        TextSize   = 13,
        TextColor3 = C.muted,
        Text       = lp.DisplayName ~= lp.Name
            and ("@" .. lp.Name)
            or  ("UserId · " .. lp.UserId),
        ZIndex     = 102,
    })

    local sep = Instance.new("Frame")
    sep.Size             = UDim2.new(0,0,0,1)
    sep.Position         = UDim2.new(0.5,0,0,288)
    sep.AnchorPoint      = Vector2.new(0.5,0)
    sep.BackgroundColor3 = C.accent
    sep.BorderSizePixel  = 0
    sep.ZIndex           = 102
    sep.Parent           = splash
    TweenService:Create(sep,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(0,200,0,1) }):Play()

    lbl(splash, {
        Size       = UDim2.new(1,0,0,24),
        Position   = UDim2.new(0,0,0,305),
        Font       = Enum.Font.GothamBold,
        TextSize   = 14,
        TextColor3 = C.accent,
        Text       = "SINIX HUB",
        ZIndex     = 102,
    })

    local loadTrack = Instance.new("Frame")
    loadTrack.Size             = UDim2.new(0,260,0,4)
    loadTrack.Position         = UDim2.new(0.5,-130,0,348)
    loadTrack.BackgroundColor3 = C.input
    loadTrack.BorderSizePixel  = 0
    loadTrack.ZIndex           = 102
    loadTrack.Parent           = splash
    rnd(loadTrack, 2)

    local loadFill = Instance.new("Frame")
    loadFill.Size             = UDim2.new(0,0,1,0)
    loadFill.BackgroundColor3 = C.accent
    loadFill.BorderSizePixel  = 0
    loadFill.ZIndex           = 103
    loadFill.Parent           = loadTrack
    rnd(loadFill, 2)

    local loadLabel = lbl(splash, {
        Size       = UDim2.new(1,0,0,16),
        Position   = UDim2.new(0,0,0,360),
        Font       = Enum.Font.Gotham,
        TextSize   = 11,
        TextColor3 = C.muted,
        Text       = "Chargement...",
        ZIndex     = 102,
    })

    local steps = {
        { pct=0.25, txt="Lecture de la config..."        },
        { pct=0.55, txt="Connexion à l'environnement..." },
        { pct=0.80, txt="Chargement des scripts..."      },
        { pct=1.00, txt="Prêt."                          },
    }

    task.spawn(function()
        for _, step in ipairs(steps) do
            TweenService:Create(loadFill,
                TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.new(step.pct,0,1,0) }):Play()
            loadLabel.Text = step.txt
            task.wait(0.5)
        end
        task.wait(0.3)
        TweenService:Create(splash,
            TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { BackgroundTransparency=1 }):Play()
        for _, d in ipairs(splash:GetDescendants()) do
            if d:IsA("TextLabel") then
                TweenService:Create(d, TweenInfo.new(0.3), { TextTransparency=1 }):Play()
            end
            if d:IsA("ImageLabel") then
                TweenService:Create(d, TweenInfo.new(0.3), { ImageTransparency=1 }):Play()
            end
            if d:IsA("Frame") then
                TweenService:Create(d, TweenInfo.new(0.3), { BackgroundTransparency=1 }):Play()
            end
        end
        task.wait(0.45)
        splash:Destroy()
        activateMain()
    end)
end

-- ── DÉMARRAGE ───────────────────────────────────────────────
buildSplash()
