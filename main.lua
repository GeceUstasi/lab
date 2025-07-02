-- UltraGUI Library - Müthiş Roblox GUI Kütüphanesi
-- Bu kütüphane modern, animasyonlu ve kullanıcı dostu bir arayüz sağlar

local UltraGUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Ana değişkenler
local currentWindow = nil
local dragConnection = nil
local dragStart = nil
local startPos = nil

-- Yardımcı fonksiyonlar
local function createTween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
    return TweenService:Create(object, tweenInfo, properties)
end

local function createRippleEffect(parent, position)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, position.X - parent.AbsolutePosition.X, 0, position.Y - parent.AbsolutePosition.Y)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local tween = createTween(ripple, {Size = UDim2.new(0, 100, 0, 100), BackgroundTransparency = 1}, 0.5)
    tween:Play()
    
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Key sistemi için değişkenler
local validKeys = {}
local keyCheckUrl = ""
local isKeyValid = false

-- Key sistemi fonksiyonları
function UltraGUI:SetKey(key)
    if type(key) == "string" then
        validKeys = {key}
    elseif type(key) == "table" then
        validKeys = key
    end
end

function UltraGUI:SetKeyUrl(url)
    keyCheckUrl = url
end

function UltraGUI:CheckKey(inputKey)
    -- Yerel key kontrolü
    for _, validKey in ipairs(validKeys) do
        if inputKey == validKey then
            return true
        end
    end
    
    -- URL ile key kontrolü (opsiyonel)
    if keyCheckUrl ~= "" then
        local success, result = pcall(function()
            return game:HttpGet(keyCheckUrl .. "?key=" .. inputKey)
        end)
        
        if success and result == "valid" then
            return true
        end
    end
    
    return false
end

function UltraGUI:CreateKeySystem(options)
    options = options or {}
    local keyTitle = options.Title or "UltraGUI Key Sistemi"
    local keyDescription = options.Description or "Lütfen geçerli bir key girin"
    local keyPlaceholder = options.KeyPlaceholder or "Key'inizi buraya girin..."
    local keys = options.AcceptedKeys or {"ULTRA-GUI-2024"}
    local keyUrl = options.KeyUrl or ""
    local successCallback = options.Success or function() end
    local failCallback = options.Fail or function() end
    
    -- Key listesini ayarla
    self:SetKey(keys)
    if keyUrl ~= "" then
        self:SetKeyUrl(keyUrl)
    end
    
    -- Ana ScreenGui oluştur
    local keyScreenGui = Instance.new("ScreenGui")
    keyScreenGui.Name = "UltraGUI_KeySystem"
    keyScreenGui.ResetOnSpawn = false
    keyScreenGui.IgnoreGuiInset = true
    keyScreenGui.Parent = playerGui
    
    -- Blur efekti için background
    local blurBg = Instance.new("Frame")
    blurBg.Name = "BlurBackground"
    blurBg.Size = UDim2.new(1, 0, 1, 0)
    blurBg.Position = UDim2.new(0, 0, 0, 0)
    blurBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blurBg.BackgroundTransparency = 0.3
    blurBg.BorderSizePixel = 0
    blurBg.Parent = keyScreenGui
    
    -- Ana key frame
    local keyFrame = Instance.new("Frame")
    keyFrame.Name = "KeyFrame"
    keyFrame.Size = UDim2.new(0, 400, 0, 300)
    keyFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    keyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    keyFrame.BorderSizePixel = 0
    keyFrame.Parent = keyScreenGui
    
    local keyFrameCorner = Instance.new("UICorner")
    keyFrameCorner.CornerRadius = UDim.new(0, 15)
    keyFrameCorner.Parent = keyFrame
    
    -- Glow efekti
    local keyGlow = Instance.new("Frame")
    keyGlow.Name = "KeyGlow"
    keyGlow.Size = UDim2.new(1, 20, 1, 20)
    keyGlow.Position = UDim2.new(0, -10, 0, -10)
    keyGlow.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    keyGlow.BackgroundTransparency = 0.7
    keyGlow.BorderSizePixel = 0
    keyGlow.ZIndex = keyFrame.ZIndex - 1
    keyGlow.Parent = keyFrame
    
    local keyGlowCorner = Instance.new("UICorner")
    keyGlowCorner.CornerRadius = UDim.new(0, 15)
    keyGlowCorner.Parent = keyGlow
    
    -- Başlık
    local keyTitleLabel = Instance.new("TextLabel")
    keyTitleLabel.Name = "KeyTitle"
    keyTitleLabel.Size = UDim2.new(1, -40, 0, 40)
    keyTitleLabel.Position = UDim2.new(0, 20, 0, 20)
    keyTitleLabel.BackgroundTransparency = 1
    keyTitleLabel.Text = keyTitle
    keyTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyTitleLabel.TextScaled = true
    keyTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    keyTitleLabel.Font = Enum.Font.GothamBold
    keyTitleLabel.Parent = keyFrame
    
    -- Açıklama
    local keyDescLabel = Instance.new("TextLabel")
    keyDescLabel.Name = "KeyDescription"
    keyDescLabel.Size = UDim2.new(1, -40, 0, 30)
    keyDescLabel.Position = UDim2.new(0, 20, 0, 70)
    keyDescLabel.BackgroundTransparency = 1
    keyDescLabel.Text = keyDescription
    keyDescLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    keyDescLabel.TextScaled = true
    keyDescLabel.TextXAlignment = Enum.TextXAlignment.Center
    keyDescLabel.Font = Enum.Font.Gotham
    keyDescLabel.Parent = keyFrame
    
    -- Key input
    local keyInput = Instance.new("TextBox")
    keyInput.Name = "KeyInput"
    keyInput.Size = UDim2.new(1, -40, 0, 40)
    keyInput.Position = UDim2.new(0, 20, 0, 120)
    keyInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    keyInput.BorderSizePixel = 0
    keyInput.Text = ""
    keyInput.PlaceholderText = keyPlaceholder
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    keyInput.TextScaled = true
    keyInput.Font = Enum.Font.Gotham
    keyInput.Parent = keyFrame
    
    local keyInputCorner = Instance.new("UICorner")
    keyInputCorner.CornerRadius = UDim.new(0, 8)
    keyInputCorner.Parent = keyInput
    
    -- Giriş animasyonu
    keyInput.FocusLost:Connect(function()
        createTween(keyInput, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}, 0.2):Play()
    end)
    
    keyInput.Focused:Connect(function()
        createTween(keyInput, {BackgroundColor3 = Color3.fromRGB(0, 162, 255)}, 0.2):Play()
    end)
    
    -- Kontrol butonu
    local checkButton = Instance.new("TextButton")
    checkButton.Name = "CheckButton"
    checkButton.Size = UDim2.new(1, -40, 0, 40)
    checkButton.Position = UDim2.new(0, 20, 0, 180)
    checkButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    checkButton.BorderSizePixel = 0
    checkButton.Text = "Key'i Kontrol Et"
    checkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkButton.TextScaled = true
    checkButton.Font = Enum.Font.GothamBold
    checkButton.Parent = keyFrame
    
    local checkButtonCorner = Instance.new("UICorner")
    checkButtonCorner.CornerRadius = UDim.new(0, 8)
    checkButtonCorner.Parent = checkButton
    
    -- Get Key butonu
    local getKeyButton = Instance.new("TextButton")
    getKeyButton.Name = "GetKeyButton"
    getKeyButton.Size = UDim2.new(1, -40, 0, 35)
    getKeyButton.Position = UDim2.new(0, 20, 0, 240)
    getKeyButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    getKeyButton.BorderSizePixel = 0
    getKeyButton.Text = "Key Al"
    getKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyButton.TextScaled = true
    getKeyButton.Font = Enum.Font.Gotham
    getKeyButton.Parent = keyFrame
    
    local getKeyButtonCorner = Instance.new("UICorner")
    getKeyButtonCorner.CornerRadius = UDim.new(0, 8)
    getKeyButtonCorner.Parent = getKeyButton
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -40, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 1, -40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
    statusLabel.TextScaled = true
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = keyFrame
    
    -- Animasyonlar
    keyFrame.Size = UDim2.new(0, 0, 0, 0)
    createTween(keyFrame, {Size = UDim2.new(0, 400, 0, 300)}, 0.5, Enum.EasingStyle.Back):Play()
    
    -- Buton hover efektleri
    checkButton.MouseEnter:Connect(function()
        createTween(checkButton, {BackgroundColor3 = Color3.fromRGB(0, 142, 235)}, 0.2):Play()
    end)
    
    checkButton.MouseLeave:Connect(function()
        createTween(checkButton, {BackgroundColor3 = Color3.fromRGB(0, 162, 255)}, 0.2):Play()
    end)
    
    getKeyButton.MouseEnter:Connect(function()
        createTween(getKeyButton, {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}, 0.2):Play()
    end)
    
    getKeyButton.MouseLeave:Connect(function()
        createTween(getKeyButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}, 0.2):Play()
    end)
    
    -- Key kontrol fonksiyonu
    local function checkKeyInput()
        local inputKey = keyInput.Text
        
        if inputKey == "" then
            statusLabel.Text = "Lütfen bir key girin!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
            return
        end
        
        statusLabel.Text = "Key kontrol ediliyor..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 85)
        
        checkButton.Text = "Kontrol Ediliyor..."
        checkButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        
        wait(1) -- Kontrol süresi simülasyonu
        
        if self:CheckKey(inputKey) then
            statusLabel.Text = "Key doğrulandı! GUI yükleniyor..."
            statusLabel.TextColor3 = Color3.fromRGB(85, 255, 85)
            
            checkButton.Text = "Başarılı!"
            checkButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
            
            isKeyValid = true
            
            wait(1)
            
            -- Kapanış animasyonu
            createTween(keyFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3):Play()
            wait(0.3)
            keyScreenGui:Destroy()
            
            successCallback()
        else
            statusLabel.Text = "Geçersiz key! Lütfen tekrar deneyin."
            statusLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
            
            checkButton.Text = "Geçersiz Key"
            checkButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
            
            wait(2)
            
            checkButton.Text = "Key'i Kontrol Et"
            checkButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
            statusLabel.Text = ""
            
            failCallback()
        end
    end
    
    -- Event bağlantıları
    checkButton.MouseButton1Click:Connect(checkKeyInput)
    
    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            checkKeyInput()
        end
    end)
    
    getKeyButton.MouseButton1Click:Connect(function()
        if options.KeyUrl and options.KeyUrl ~= "" then
            -- Clipboard'a kopyala veya link aç
            setclipboard(options.KeyUrl)
            statusLabel.Text = "Link kopyalandı!"
            statusLabel.TextColor3 = Color3.fromRGB(85, 255, 85)
            
            wait(2)
            statusLabel.Text = ""
        else
            statusLabel.Text = "Key linki bulunamadı!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
        end
    end)
    
    return {
        Frame = keyFrame,
        IsValid = function() return isKeyValid end,
        Destroy = function() keyScreenGui:Destroy() end
    }
end

-- Ana GUI oluşturma fonksiyonu
function UltraGUI:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Name or "UltraGUI"
    local windowSubtitle = options.LoadingTitle or "İnanılmaz GUI Deneyimi"
    local configFolder = options.ConfigurationSaving and options.ConfigurationSaving.FileName or "UltraGUIConfig"
    
    -- Ana ScreenGui oluştur
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltraGUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    
    -- Glow efekti için ana container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = screenGui
    
    -- Glow efekti
    local glowFrame = Instance.new("Frame")
    glowFrame.Name = "GlowFrame"
    glowFrame.Size = UDim2.new(1, 20, 1, 20)
    glowFrame.Position = UDim2.new(0, -10, 0, -10)
    glowFrame.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    glowFrame.BackgroundTransparency = 0.8
    glowFrame.BorderSizePixel = 0
    glowFrame.Parent = mainFrame
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 15)
    glowCorner.Parent = glowFrame
    
    -- Ana pencere
    local windowFrame = Instance.new("Frame")
    windowFrame.Name = "WindowFrame"
    windowFrame.Size = UDim2.new(1, 0, 1, 0)
    windowFrame.Position = UDim2.new(0, 0, 0, 0)
    windowFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    windowFrame.BorderSizePixel = 0
    windowFrame.Parent = mainFrame
    
    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 10)
    windowCorner.Parent = windowFrame
    
    -- Başlık çubuğu
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = windowFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    
    -- Başlık çubuğu alt kısmını düzelt
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 10)
    titleFix.Position = UDim2.new(0, 0, 1, -10)
    titleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Başlık metni
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = titleBar
    
    -- Kapat butonu
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton
    
    -- Sol panel (kategori listesi)
    local sidePanel = Instance.new("Frame")
    sidePanel.Name = "SidePanel"
    sidePanel.Size = UDim2.new(0, 180, 1, -50)
    sidePanel.Position = UDim2.new(0, 10, 0, 45)
    sidePanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    sidePanel.BorderSizePixel = 0
    sidePanel.Parent = windowFrame
    
    local sidePanelCorner = Instance.new("UICorner")
    sidePanelCorner.CornerRadius = UDim.new(0, 8)
    sidePanelCorner.Parent = sidePanel
    
    -- Sol panel scroll
    local sideScroll = Instance.new("ScrollingFrame")
    sideScroll.Name = "SideScroll"
    sideScroll.Size = UDim2.new(1, -10, 1, -10)
    sideScroll.Position = UDim2.new(0, 5, 0, 5)
    sideScroll.BackgroundTransparency = 1
    sideScroll.BorderSizePixel = 0
    sideScroll.ScrollBarThickness = 3
    sideScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
    sideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    sideScroll.Parent = sidePanel
    
    local sideLayout = Instance.new("UIListLayout")
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Padding = UDim.new(0, 5)
    sideLayout.Parent = sideScroll
    
    -- Sağ panel (içerik)
    local contentPanel = Instance.new("Frame")
    contentPanel.Name = "ContentPanel"
    contentPanel.Size = UDim2.new(1, -200, 1, -50)
    contentPanel.Position = UDim2.new(0, 190, 0, 45)
    contentPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    contentPanel.BorderSizePixel = 0
    contentPanel.Parent = windowFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentPanel
    
    -- İçerik scroll
    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Name = "ContentScroll"
    contentScroll.Size = UDim2.new(1, -10, 1, -10)
    contentScroll.Position = UDim2.new(0, 5, 0, 5)
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel = 0
    contentScroll.ScrollBarThickness = 3
    contentScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentScroll.Parent = contentPanel
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = contentScroll
    
    -- Drag özelliği
    local function startDrag(input)
        local dragStart = input.Position
        local startPos = mainFrame.Position
        
        dragConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragConnection then
                dragConnection:Disconnect()
                dragConnection = nil
            end
        end
    end)
    
    -- Kapat butonu işlevi
    closeButton.MouseButton1Click:Connect(function()
        createTween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3):Play()
        wait(0.3)
        screenGui:Destroy()
    end)
    
    -- Giriş animasyonu
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    createTween(mainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.5, Enum.EasingStyle.Back):Play()
    
    -- Tab sistemi
    local tabs = {}
    local currentTab = nil
    
    local WindowAPI = {}
    
    function WindowAPI:CreateTab(options)
        options = options or {}
        local tabName = options.Name or "Tab"
        local tabIcon = options.Image or ""
        
        -- Tab butonu oluştur
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Button"
        tabButton.Size = UDim2.new(1, 0, 0, 35)
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        tabButton.BorderSizePixel = 0
        tabButton.Text = ""
        tabButton.Parent = sideScroll
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        
        -- Tab ikonu (varsa)
        local tabIconLabel = nil
        if tabIcon ~= "" then
            tabIconLabel = Instance.new("ImageLabel")
            tabIconLabel.Size = UDim2.new(0, 20, 0, 20)
            tabIconLabel.Position = UDim2.new(0, 8, 0.5, -10)
            tabIconLabel.BackgroundTransparency = 1
            tabIconLabel.Image = tabIcon
            tabIconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
            tabIconLabel.Parent = tabButton
        end
        
        -- Tab metni
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, tabIconLabel and -35 or -15, 1, 0)
        tabLabel.Position = UDim2.new(0, tabIconLabel and 30 or 8, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabLabel.TextScaled = true
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Font = Enum.Font.Gotham
        tabLabel.Parent = tabButton
        
        -- Tab içeriği
        local tabContent = Instance.new("Frame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = contentScroll
        
        local tabContentLayout = Instance.new("UIListLayout")
        tabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabContentLayout.Padding = UDim.new(0, 5)
        tabContentLayout.Parent = tabContent
        
        -- Tab değiştirme
        local function selectTab()
            -- Tüm tabları deaktif et
            for _, tab in pairs(tabs) do
                createTween(tab.button, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.2):Play()
                tab.label.TextColor3 = Color3.fromRGB(200, 200, 200)
                if tab.icon then
                    tab.icon.ImageColor3 = Color3.fromRGB(200, 200, 200)
                end
                tab.content.Visible = false
            end
            
            -- Bu tabı aktif et
            createTween(tabButton, {BackgroundColor3 = Color3.fromRGB(0, 162, 255)}, 0.2):Play()
            tabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            if tabIconLabel then
                tabIconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            tabContent.Visible = true
            currentTab = tabName
        end
        
        tabButton.MouseButton1Click:Connect(function()
            createRippleEffect(tabButton, UserInputService:GetMouseLocation())
            selectTab()
        end)
        
        -- İlk tab otomatik seçili
        if #tabs == 0 then
            selectTab()
        end
        
        -- Tab'ı listeye ekle
        table.insert(tabs, {
            name = tabName,
            button = tabButton,
            label = tabLabel,
            icon = tabIconLabel,
            content = tabContent,
            layout = tabContentLayout
        })
        
        -- Canvas boyutunu güncelle
        sideScroll.CanvasSize = UDim2.new(0, 0, 0, sideLayout.AbsoluteContentSize.Y)
        
        -- Tab API'sini döndür
        local TabAPI = {}
        
        function TabAPI:CreateButton(options)
            options = options or {}
            local buttonName = options.Name or "Button"
            local buttonCallback = options.Callback or function() end
            
            local button = Instance.new("TextButton")
            button.Name = buttonName
            button.Size = UDim2.new(1, 0, 0, 35)
            button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            button.BorderSizePixel = 0
            button.Text = buttonName
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextScaled = true
            button.Font = Enum.Font.Gotham
            button.Parent = tabContent
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = button
            
            button.MouseEnter:Connect(function()
                createTween(button, {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}, 0.2):Play()
            end)
            
            button.MouseLeave:Connect(function()
                createTween(button, {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}, 0.2):Play()
            end)
            
            button.MouseButton1Click:Connect(function()
                createRippleEffect(button, UserInputService:GetMouseLocation())
                buttonCallback()
            end)
            
            return button
        end
        
        function TabAPI:CreateToggle(options)
            options = options or {}
            local toggleName = options.Name or "Toggle"
            local toggleDefault = options.CurrentValue or false
            local toggleCallback = options.Callback or function() end
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = toggleName .. "Frame"
            toggleFrame.Size = UDim2.new(1, 0, 0, 35)
            toggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = tabContent
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 6)
            toggleCorner.Parent = toggleFrame
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -60, 1, 0)
            toggleLabel.Position = UDim2.new(0, 10, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = toggleName
            toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleLabel.TextScaled = true
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Font = Enum.Font.Gotham
            toggleLabel.Parent = toggleFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 45, 0, 20)
            toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
            toggleButton.BackgroundColor3 = toggleDefault and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(70, 70, 80)
            toggleButton.BorderSizePixel = 0
            toggleButton.Text = ""
            toggleButton.Parent = toggleFrame
            
            local toggleButtonCorner = Instance.new("UICorner")
            toggleButtonCorner.CornerRadius = UDim.new(1, 0)
            toggleButtonCorner.Parent = toggleButton
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 16, 0, 16)
            toggleCircle.Position = toggleDefault and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleButton
            
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = toggleCircle
            
            local isToggled = toggleDefault
            
            toggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                
                local newColor = isToggled and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(70, 70, 80)
                local newPosition = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                
                createTween(toggleButton, {BackgroundColor3 = newColor}, 0.2):Play()
                createTween(toggleCircle, {Position = newPosition}, 0.2):Play()
                
                toggleCallback(isToggled)
            end)
            
            return {Frame = toggleFrame, Value = isToggled}
        end
        
        function TabAPI:CreateSlider(options)
            options = options or {}
            local sliderName = options.Name or "Slider"
            local sliderMin = options.Min or 0
            local sliderMax = options.Max or 100
            local sliderDefault = options.CurrentValue or sliderMin
            local sliderCallback = options.Callback or function() end
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = sliderName .. "Frame"
            sliderFrame.Size = UDim2.new(1, 0, 0, 50)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = tabContent
            
            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 6)
            sliderCorner.Parent = sliderFrame
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(1, 0, 0, 25)
            sliderLabel.Position = UDim2.new(0, 10, 0, 0)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = sliderName .. ": " .. sliderDefault
            sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            sliderLabel.TextScaled = true
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Font = Enum.Font.Gotham
            sliderLabel.Parent = sliderFrame
            
            local sliderBar = Instance.new("Frame")
            sliderBar.Size = UDim2.new(1, -20, 0, 4)
            sliderBar.Position = UDim2.new(0, 10, 1, -15)
            sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
            sliderBar.BorderSizePixel = 0
            sliderBar.Parent = sliderFrame
            
            local sliderBarCorner = Instance.new("UICorner")
            sliderBarCorner.CornerRadius = UDim.new(1, 0)
            sliderBarCorner.Parent = sliderBar
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((sliderDefault - sliderMin) / (sliderMax - sliderMin), 0, 1, 0)
            sliderFill.Position = UDim2.new(0, 0, 0, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBar
            
            local sliderFillCorner = Instance.new("UICorner")
            sliderFillCorner.CornerRadius = UDim.new(1, 0)
            sliderFillCorner.Parent = sliderFill
            
            local sliderButton = Instance.new("TextButton")
            sliderButton.Size = UDim2.new(0, 12, 0, 12)
            sliderButton.Position = UDim2.new((sliderDefault - sliderMin) / (sliderMax - sliderMin), -6, 0.5, -6)
            sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sliderButton.BorderSizePixel = 0
            sliderButton.Text = ""
            sliderButton.Parent = sliderBar
            
            local sliderButtonCorner = Instance.new("UICorner")
            sliderButtonCorner.CornerRadius = UDim.new(1, 0)
            sliderButtonCorner.Parent = sliderButton
            
            local currentValue = sliderDefault
            local dragging = false
            
            local function updateSlider(input)
                local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                currentValue = math.floor(sliderMin + (sliderMax - sliderMin) * relativeX)
                
                sliderLabel.Text = sliderName .. ": " .. currentValue
                
                createTween(sliderFill, {Size = UDim2.new(relativeX, 0, 1, 0)}, 0.1):Play()
                createTween(sliderButton, {Position = UDim2.new(relativeX, -6, 0.5, -6)}, 0.1):Play()
                
                sliderCallback(currentValue)
            end
            
            sliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            return {Frame = sliderFrame, Value = currentValue}
        end
        
        function TabAPI:CreateDropdown(options)
            options = options or {}
            local dropdownName = options.Name or "Dropdown"
            local dropdownOptions = options.Options or {"Option 1", "Option 2"}
            local dropdownDefault = options.CurrentOption or dropdownOptions[1]
            local dropdownCallback = options.Callback or function() end
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = dropdownName .. "Frame"
            dropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            dropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Parent = tabContent
            
            local dropdownCorner = Instance.new("UICorner")
            dropdownCorner.CornerRadius = UDim.new(0, 6)
            dropdownCorner.Parent = dropdownFrame
            
            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Size = UDim2.new(0, 100, 1, 0)
            dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Text = dropdownName
            dropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            dropdownLabel.TextScaled = true
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropdownLabel.Font = Enum.Font.Gotham
            dropdownLabel.Parent = dropdownFrame
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Size = UDim2.new(1, -120, 0, 25)
            dropdownButton.Position = UDim2.new(0, 110, 0.5, -12.5)
            dropdownButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            dropdownButton.BorderSizePixel = 0
            dropdownButton.Text = dropdownDefault .. " ▼"
            dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            dropdownButton.TextScaled = true
            dropdownButton.Font = Enum.Font.Gotham
            dropdownButton.Parent = dropdownFrame
            
            local dropdownButtonCorner = Instance.new("UICorner")
            dropdownButtonCorner.CornerRadius = UDim.new(0, 4)
            dropdownButtonCorner.Parent = dropdownButton
            
            local dropdownList = Instance.new("Frame")
            dropdownList.Name = "DropdownList"
            dropdownList.Size = UDim2.new(1, 0, 0, #dropdownOptions * 25)
            dropdownList.Position = UDim2.new(0, 0, 1, 5)
            dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            dropdownList.BorderSizePixel = 0
            dropdownList.Visible = false
            dropdownList.ZIndex = 10
            dropdownList.Parent = dropdownButton
            
            local dropdownListCorner = Instance.new("UICorner")
            dropdownListCorner.CornerRadius = UDim.new(0, 4)
            dropdownListCorner.Parent = dropdownList
            
            local dropdownListLayout = Instance.new("UIListLayout")
            dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            dropdownListLayout.Parent = dropdownList
            
            local currentSelection = dropdownDefault
            local isOpen = false
            
            for i, option in ipairs(dropdownOptions) do
                local optionButton = Instance.new("TextButton")
                optionButton.Size = UDim2.new(1, 0, 0, 25)
                optionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                optionButton.BorderSizePixel = 0
                optionButton.Text = option
                optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                optionButton.TextScaled = true
                optionButton.Font = Enum.Font.Gotham
                optionButton.Parent = dropdownList
                
                optionButton.MouseEnter:Connect(function()
                    createTween(optionButton, {BackgroundColor3 = Color3.fromRGB(0, 162, 255)}, 0.1):Play()
                end)
                
                optionButton.MouseLeave:Connect(function()
                    createTween(optionButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}, 0.1):Play()
                end)
                
                optionButton.MouseButton1Click:Connect(function()
                    currentSelection = option
                    dropdownButton.Text = option .. " ▼"
                    dropdownList.Visible = false
                    isOpen = false
                    dropdownCallback(option)
                end)
            end
            
            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                dropdownList.Visible = isOpen
                dropdownButton.Text = currentSelection .. (isOpen and " ▲" or " ▼")
            end)
            
            return {Frame = dropdownFrame, Value = currentSelection}
        end
        
        function TabAPI:CreateTextbox(options)
            options = options or {}
            local textboxName = options.Name or "Textbox"
            local textboxPlaceholder = options.PlaceholderText or "Yazınız..."
            local textboxCallback = options.Callback or function() end
            
            local textboxFrame = Instance.new("Frame")
            textboxFrame.Name = textboxName .. "Frame"
            textboxFrame.Size = UDim2.new(1, 0, 0, 35)
            textboxFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            textboxFrame.BorderSizePixel = 0
            textboxFrame.Parent = tabContent
            
            local textboxCorner = Instance.new("UICorner")
            textboxCorner.CornerRadius = UDim.new(0, 6)
            textboxCorner.Parent = textboxFrame
            
            local textboxLabel = Instance.new("TextLabel")
            textboxLabel.Size = UDim2.new(0, 100, 1, 0)
            textboxLabel.Position = UDim2.new(0, 10, 0, 0)
            textboxLabel.BackgroundTransparency = 1
            textboxLabel.Text = textboxName
            textboxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textboxLabel.TextScaled = true
            textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
            textboxLabel.Font = Enum.Font.Gotham
            textboxLabel.Parent = textboxFrame
            
            local textbox = Instance.new("TextBox")
            textbox.Size = UDim2.new(1, -120, 0, 25)
            textbox.Position = UDim2.new(0, 110, 0.5, -12.5)
            textbox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            textbox.BorderSizePixel = 0
            textbox.Text = ""
            textbox.PlaceholderText = textboxPlaceholder
            textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
            textbox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            textbox.TextScaled = true
            textbox.Font = Enum.Font.Gotham
            textbox.Parent = textboxFrame
            
            local textboxTextCorner = Instance.new("UICorner")
            textboxTextCorner.CornerRadius = UDim.new(0, 4)
            textboxTextCorner.Parent = textbox
            
            textbox.FocusLost:Connect(function()
                textboxCallback(textbox.Text)
            end)
            
            return {Frame = textboxFrame, Textbox = textbox}
        end
        
        function TabAPI:CreateLabel(options)
            options = options or {}
            local labelText = options.Text or "Label"
            local labelSize = options.TextSize or 14
            
            local labelFrame = Instance.new("Frame")
            labelFrame.Name = "LabelFrame"
            labelFrame.Size = UDim2.new(1, 0, 0, 25)
            labelFrame.BackgroundTransparency = 1
            labelFrame.Parent = tabContent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = labelText
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextScaled = true
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.Parent = labelFrame
            
            return {Frame = labelFrame, Label = label}
        end
        
        function TabAPI:CreateParagraph(options)
            options = options or {}
            local paragraphTitle = options.Title or "Paragraph"
            local paragraphContent = options.Content or "İçerik buraya gelecek..."
            
            local paragraphFrame = Instance.new("Frame")
            paragraphFrame.Name = paragraphTitle .. "Frame"
            paragraphFrame.Size = UDim2.new(1, 0, 0, 60)
            paragraphFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            paragraphFrame.BorderSizePixel = 0
            paragraphFrame.Parent = tabContent
            
            local paragraphCorner = Instance.new("UICorner")
            paragraphCorner.CornerRadius = UDim.new(0, 6)
            paragraphCorner.Parent = paragraphFrame
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -10, 0, 20)
            titleLabel.Position = UDim2.new(0, 5, 0, 5)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = paragraphTitle
            titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleLabel.TextScaled = true
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Parent = paragraphFrame
            
            local contentLabel = Instance.new("TextLabel")
            contentLabel.Size = UDim2.new(1, -10, 1, -25)
            contentLabel.Position = UDim2.new(0, 5, 0, 25)
            contentLabel.BackgroundTransparency = 1
            contentLabel.Text = paragraphContent
            contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            contentLabel.TextScaled = true
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.TextYAlignment = Enum.TextYAlignment.Top
            contentLabel.TextWrapped = true
            contentLabel.Font = Enum.Font.Gotham
            contentLabel.Parent = paragraphFrame
            
            return {Frame = paragraphFrame, Title = titleLabel, Content = contentLabel}
        end
        
        function TabAPI:CreateInput(options)
            options = options or {}
            local inputName = options.Name or "Input"
            local inputPlaceholder = options.PlaceholderText or "Değer girin..."
            local isNumeric = options.NumericOnly or false
            local inputCallback = options.Callback or function() end
            
            local inputFrame = Instance.new("Frame")
            inputFrame.Name = inputName .. "Frame"
            inputFrame.Size = UDim2.new(1, 0, 0, 35)
            inputFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            inputFrame.BorderSizePixel = 0
            inputFrame.Parent = tabContent
            
            local inputCorner = Instance.new("UICorner")
            inputCorner.CornerRadius = UDim.new(0, 6)
            inputCorner.Parent = inputFrame
            
            local inputLabel = Instance.new("TextLabel")
            inputLabel.Size = UDim2.new(0, 100, 1, 0)
            inputLabel.Position = UDim2.new(0, 10, 0, 0)
            inputLabel.BackgroundTransparency = 1
            inputLabel.Text = inputName
            inputLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            inputLabel.TextScaled = true
            inputLabel.TextXAlignment = Enum.TextXAlignment.Left
            inputLabel.Font = Enum.Font.Gotham
            inputLabel.Parent = inputFrame
            
            local inputBox = Instance.new("TextBox")
            inputBox.Size = UDim2.new(1, -120, 0, 25)
            inputBox.Position = UDim2.new(0, 110, 0.5, -12.5)
            inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            inputBox.BorderSizePixel = 0
            inputBox.Text = ""
            inputBox.PlaceholderText = inputPlaceholder
            inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            inputBox.TextScaled = true
            inputBox.Font = Enum.Font.Gotham
            inputBox.Parent = inputFrame
            
            local inputBoxCorner = Instance.new("UICorner")
            inputBoxCorner.CornerRadius = UDim.new(0, 4)
            inputBoxCorner.Parent = inputBox
            
            if isNumeric then
                inputBox.Changed:Connect(function()
                    inputBox.Text = inputBox.Text:gsub("%D", "")
                end)
            end
            
            inputBox.FocusLost:Connect(function()
                local value = isNumeric and tonumber(inputBox.Text) or inputBox.Text
                inputCallback(value)
            end)
            
            return {Frame = inputFrame, Input = inputBox}
        end
        
        function TabAPI:CreateColorPicker(options)
            options = options or {}
            local colorName = options.Name or "Color Picker"
            local defaultColor = options.Color or Color3.fromRGB(255, 255, 255)
            local colorCallback = options.Callback or function() end
            
            local colorFrame = Instance.new("Frame")
            colorFrame.Name = colorName .. "Frame"
            colorFrame.Size = UDim2.new(1, 0, 0, 35)
            colorFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            colorFrame.BorderSizePixel = 0
            colorFrame.Parent = tabContent
            
            local colorCorner = Instance.new("UICorner")
            colorCorner.CornerRadius = UDim.new(0, 6)
            colorCorner.Parent = colorFrame
            
            local colorLabel = Instance.new("TextLabel")
            colorLabel.Size = UDim2.new(1, -50, 1, 0)
            colorLabel.Position = UDim2.new(0, 10, 0, 0)
            colorLabel.BackgroundTransparency = 1
            colorLabel.Text = colorName
            colorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            colorLabel.TextScaled = true
            colorLabel.TextXAlignment = Enum.TextXAlignment.Left
            colorLabel.Font = Enum.Font.Gotham
            colorLabel.Parent = colorFrame
            
            local colorDisplay = Instance.new("Frame")
            colorDisplay.Size = UDim2.new(0, 30, 0, 25)
            colorDisplay.Position = UDim2.new(1, -40, 0.5, -12.5)
            colorDisplay.BackgroundColor3 = defaultColor
            colorDisplay.BorderSizePixel = 0
            colorDisplay.Parent = colorFrame
            
            local colorDisplayCorner = Instance.new("UICorner")
            colorDisplayCorner.CornerRadius = UDim.new(0, 4)
            colorDisplayCorner.Parent = colorDisplay
            
            local colorButton = Instance.new("TextButton")
            colorButton.Size = UDim2.new(1, 0, 1, 0)
            colorButton.Position = UDim2.new(0, 0, 0, 0)
            colorButton.BackgroundTransparency = 1
            colorButton.Text = ""
            colorButton.Parent = colorDisplay
            
            local currentColor = defaultColor
            
            colorButton.MouseButton1Click:Connect(function()
                -- Basit renk seçici (gerçek uygulamada daha gelişmiş bir picker kullanılabilir)
                local colors = {
                    Color3.fromRGB(255, 0, 0),
                    Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(0, 0, 255),
                    Color3.fromRGB(255, 255, 0),
                    Color3.fromRGB(255, 0, 255),
                    Color3.fromRGB(0, 255, 255),
                    Color3.fromRGB(255, 255, 255),
                    Color3.fromRGB(0, 0, 0)
                }
                
                local randomColor = colors[math.random(1, #colors)]
                currentColor = randomColor
                colorDisplay.BackgroundColor3 = currentColor
                colorCallback(currentColor)
            end)
            
            return {Frame = colorFrame, Color = currentColor}
        end
        
        -- Canvas boyutunu güncelle
        contentScroll.CanvasSize = UDim2.new(0, 0, 0, tabContentLayout.AbsoluteContentSize.Y)
        
        tabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            contentScroll.CanvasSize = UDim2.new(0, 0, 0, tabContentLayout.AbsoluteContentSize.Y)
        end)
        
        return TabAPI
    end
    
    currentWindow = WindowAPI
    return WindowAPI
end

-- Örnekler ve kullanım
function UltraGUI:CreateNotification(options)
    options = options or {}
    local title = options.Title or "Bildirim"
    local content = options.Content or "Bu bir bildirimdir."
    local duration = options.Duration or 3
    local image = options.Image or ""
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 0, 20)
    notification.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    notification.BorderSizePixel = 0
    notification.Parent = playerGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification
    
    local notifShadow = Instance.new("Frame")
    notifShadow.Size = UDim2.new(1, 10, 1, 10)
    notifShadow.Position = UDim2.new(0, -5, 0, -5)
    notifShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notifShadow.BackgroundTransparency = 0.8
    notifShadow.BorderSizePixel = 0
    notifShadow.ZIndex = notification.ZIndex - 1
    notifShadow.Parent = notification
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 8)
    shadowCorner.Parent = notifShadow
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = notification
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -20, 1, -30)
    contentLabel.Position = UDim2.new(0, 10, 0, 25)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    contentLabel.TextScaled = true
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.Parent = notification
    
    -- Animasyon
    notification.Position = UDim2.new(1, 0, 0, 20)
    createTween(notification, {Position = UDim2.new(1, -320, 0, 20)}, 0.3, Enum.EasingStyle.Back):Play()
    
    -- Otomatik kapat
    wait(duration)
    createTween(notification, {Position = UDim2.new(1, 0, 0, 20)}, 0.3):Play()
    wait(0.3)
    notification:Destroy()
end

return UltraGUI
