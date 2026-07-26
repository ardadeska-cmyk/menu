Endware UI

A modern, reusable, cartoony Roblox UI library written in Luau.

Endware UI includes animated windows, tabs, sections, paragraphs, buttons, checkboxes, flags, notifications, theme customization, draggable windows, responsive scaling, and a configurable visibility hotkey.

Current version: 1.3.0

Library URL:

https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/menu2.lua

English Documentation

Features

Modern cartoony visual style

Animated open and close transitions

Draggable window

Responsive interface scaling

Custom visibility toggle key

Tabs with icons and descriptions

Sections

Paragraph cards

Buttons

Checkboxes / toggles

Flag state management

Notifications

Custom themes

Automatic cleanup

Client-side Luau API

Important Runtime Note

Endware UI is a client-side library and requires access to Players.LocalPlayer.

The HTTP loader below requires an environment where both of these are available on the client:

game:HttpGet()
loadstring()

For a standard Roblox Studio project, using Endware as a ModuleScript inside ReplicatedStorage is recommended.

Quick Start — HTTP / Loadstring

local Endware = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/menu2.lua",
    true
))()

Create a window:

local Window = Endware:CreateWindow({
    Title = "MY MENU",
    Subtitle = "Powered by Endware",
    GuiName = "MyEndwareMenu",
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(780, 510),
})

Create a tab and section:

local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "★",
})

HomeTab:SetDescription("Overview and quick actions")

local MainSection = HomeTab:CreateSection("Main")

Add controls:

MainSection:AddParagraph(
    "Welcome",
    "This menu was created with Endware UI."
)

MainSection:AddCheckbox({
    Name = "Enable Feature",
    Description = "Enables or disables the example feature.",
    Flag = "FeatureEnabled",
    Default = true,
    FireOnInit = true,

    Callback = function(enabled)
        print("FeatureEnabled:", enabled)
    end,
})

MainSection:AddButton({
    Name = "Test Notification",
    Description = "Displays a notification.",
    ButtonText = "SHOW",

    Callback = function()
        Window:Notify({
            Title = "Endware",
            Content = "The button callback is working!",
            Duration = 3,
        })
    end,
})

Safer HTTP Loader

This loader provides clearer download, compile, and runtime errors:

local LIBRARY_URL =
    "https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/menu2.lua"

local function loadEndware()
    local requestSuccess, sourceOrError = pcall(function()
        return game:HttpGet(LIBRARY_URL, true)
    end)

    assert(
        requestSuccess,
        "[Endware Loader] Download failed: " .. tostring(sourceOrError)
    )

    local chunk, compileError = loadstring(sourceOrError)

    assert(
        chunk,
        "[Endware Loader] Compile error: " .. tostring(compileError)
    )

    local runSuccess, libraryOrError = pcall(chunk)

    assert(
        runSuccess,
        "[Endware Loader] Runtime error: " .. tostring(libraryOrError)
    )

    assert(
        type(libraryOrError) == "table",
        "[Endware Loader] The remote file must return the Endware library."
    )

    return libraryOrError
end

local Endware = loadEndware()

Complete Example

local Endware = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/menu2.lua",
    true
))()

local Window = Endware:CreateWindow({
    Title = "ENDWARE",
    Subtitle = "Complete Example",
    GuiName = "EndwareCompleteExample",
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(780, 510),
})

-- HOME
local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "★",
})

HomeTab:SetDescription("Overview and quick actions")

local WelcomeSection = HomeTab:CreateSection("Welcome")

WelcomeSection:AddParagraph(
    "Endware UI",
    "A modern cartoony interface. Press Right Shift to hide or show the menu."
)

WelcomeSection:AddCheckbox({
    Name = "Enable Endware",
    Description = "Example master option.",
    Flag = "EndwareEnabled",
    Default = true,
    FireOnInit = true,

    Callback = function(enabled)
        print("EndwareEnabled:", enabled)
    end,
})

WelcomeSection:AddButton({
    Name = "Test Notification",
    Description = "Displays an Endware notification.",
    ButtonText = "SHOW",

    Callback = function()
        Window:Notify({
            Title = "Endware is ready!",
            Content = "The library loaded successfully.",
            Duration = 3,
        })
    end,
})

-- INTERFACE
local InterfaceTab = Window:CreateTab({
    Name = "Interface",
    Icon = "✦",
})

InterfaceTab:SetDescription("Visual and interface preferences")

local VisualSection = InterfaceTab:CreateSection("Visual Settings")

VisualSection:AddCheckbox({
    Name = "Bright Effects",
    Description = "Example visual-effects preference.",
    Flag = "BrightEffects",
    Default = true,

    Callback = function(enabled)
        print("BrightEffects:", enabled)
    end,
})

VisualSection:AddCheckbox({
    Name = "Smooth Animations",
    Description = "Example animation preference.",
    Flag = "SmoothAnimations",
    Default = true,

    Callback = function(enabled)
        print("SmoothAnimations:", enabled)
    end,
})

-- SETTINGS
local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "⚙",
})

SettingsTab:SetDescription("Menu and flag management")

local SettingsSection = SettingsTab:CreateSection("System")

SettingsSection:AddButton({
    Name = "Print Flags",
    Description = "Prints all current flag values.",
    ButtonText = "PRINT",

    Callback = function()
        print("----- ENDWARE FLAGS -----")

        for flag, value in pairs(Window.Flags) do
            print(flag, value)
        end
    end,
})

SettingsSection:AddButton({
    Name = "Disable Bright Effects",
    Description = "Changes a checkbox programmatically.",
    ButtonText = "DISABLE",

    Callback = function()
        Window:SetFlag("BrightEffects", false)
    end,
})

SettingsSection:AddButton({
    Name = "Hide Window",
    Description = "Press Right Shift to show it again.",
    ButtonText = "HIDE",

    Callback = function()
        Window:SetVisible(false)
    end,
})

Window:Notify({
    Title = "ENDWARE",
    Content = "Menu loaded. Press Right Shift to toggle it.",
    Duration = 4,
})

API Reference

Endware.Version

Returns the current library version.

print(Endware.Version)

Endware:CreateWindow(options)

Creates and returns a new Endware window.

local Window = Endware:CreateWindow({
    Title = "ENDWARE",
    Subtitle = "Cartoony Control Center",
    GuiName = "EndwareUI",
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(780, 510),
    DisplayOrder = 100,
    Theme = {},
})

Window Options

Option

Type

Required

Description

Title

string

No

Main window title

Subtitle

string

No

Text displayed under the title

GuiName

string

No

Unique ScreenGui name

ToggleKey

Enum.KeyCode

No

Key used to show or hide the window

Size

UDim2

No

Window size

DisplayOrder

number

No

ScreenGui.DisplayOrder

Theme

table

No

Theme color overrides

The default toggle key is:

Enum.KeyCode.RightShift

Window:CreateTab(options)

Creates and returns a tab.

local Tab = Window:CreateTab({
    Name = "Home",
    Icon = "★",
})

Tab Options

Option

Type

Required

Description

Name

string

Yes

Tab name

Icon

string

No

Short icon, symbol, or character

A string can also be passed directly:

local Tab = Window:CreateTab("Home")

Tab:SetDescription(description)

Sets the subtitle displayed for the active tab.

Tab:SetDescription("Overview and quick actions")

Returns the tab, allowing method chaining.

Tab:CreateSection(title)

Creates and returns a section inside a tab.

local Section = Tab:CreateSection("General")

Section:AddParagraph(title, content)

Adds a non-interactive information card.

Section:AddParagraph(
    "Information",
    "This text explains what the section does."
)

Section:AddButton(options)

Adds a clickable button.

local Button = Section:AddButton({
    Name = "Run Action",
    Description = "Runs the example callback.",
    ButtonText = "RUN",

    Callback = function()
        print("Button clicked")
    end,
})

Button Options

Option

Type

Required

Description

Name

string

Yes

Button title

Description

string

No

Button description

ButtonText

string

No

Text inside the action button

Callback

function

No

Function called when clicked

Destroy a button:

Button:Destroy()

Section:AddCheckbox(options)

Adds a checkbox and stores its value in Window.Flags.

local Checkbox = Section:AddCheckbox({
    Name = "Music",
    Description = "Enables or disables background music.",
    Flag = "MusicEnabled",
    Default = true,
    FireOnInit = false,

    Callback = function(enabled)
        print("MusicEnabled:", enabled)
    end,
})

Checkbox Options

Option

Type

Required

Description

Name

string

Yes

Checkbox title

Description

string

No

Checkbox description

Flag

string

No

Unique key stored in Window.Flags

Default

boolean

No

Initial checkbox value

FireOnInit

boolean

No

Runs the callback immediately after creation

Callback

function(boolean)

No

Runs whenever the value changes

Use a unique Flag for every checkbox.

Checkbox Object

Set the value:

Checkbox:Set(true)

Read the value:

print(Checkbox:Get())

Toggle the value:

Checkbox:Toggle()

Destroy the checkbox:

Checkbox:Destroy()

Toggle Alias

AddToggle is an alias of AddCheckbox:

Section:AddToggle({
    Name = "Example Toggle",
    Flag = "ExampleToggle",
    Default = false,
})

Window.Flags

A table containing all current flag values.

print(Window.Flags.MusicEnabled)

for flag, value in pairs(Window.Flags) do
    print(flag, value)
end

Window:GetFlag(flag)

Returns a stored flag value.

local enabled = Window:GetFlag("MusicEnabled")
print(enabled)

Window:SetFlag(flag, value, silent?)

Changes a flag programmatically.

Window:SetFlag("MusicEnabled", false)

Prevent the checkbox callback from firing:

Window:SetFlag("MusicEnabled", false, true)

Window:Notify(options)

Displays a notification.

Window:Notify({
    Title = "Success",
    Content = "The operation was completed.",
    Duration = 3,
})

Notification Options

Option

Type

Required

Description

Title

string

No

Notification title

Content

string

No

Notification message

Duration

number

No

Display duration in seconds

Window:SetVisible(visible)

Shows or hides the window.

Window:SetVisible(false)
Window:SetVisible(true)

Window:Toggle()

Toggles the current visibility state.

Window:Toggle()

Window:IsVisible()

Returns whether the window is currently visible.

print(Window:IsVisible())

Window:Destroy()

Destroys the entire interface and disconnects its events.

Window:Destroy()

Tab:Destroy()

Destroys a tab and its contents.

Tab:Destroy()

Theme Customization

You can override any default theme color.

local Window = Endware:CreateWindow({
    Title = "CUSTOM THEME",
    Subtitle = "Powered by Endware",

    Theme = {
        Background = Color3.fromRGB(255, 247, 238),
        Surface = Color3.fromRGB(255, 255, 255),
        SurfaceAlt = Color3.fromRGB(255, 243, 231),
        Sidebar = Color3.fromRGB(255, 230, 205),

        Text = Color3.fromRGB(47, 35, 48),
        MutedText = Color3.fromRGB(104, 84, 100),

        Accent = Color3.fromRGB(255, 105, 133),
        AccentDark = Color3.fromRGB(205, 55, 91),
        AccentSoft = Color3.fromRGB(255, 216, 226),

        Secondary = Color3.fromRGB(255, 190, 78),
        Positive = Color3.fromRGB(69, 190, 137),

        Stroke = Color3.fromRGB(226, 196, 180),
        Shadow = Color3.fromRGB(108, 82, 94),
        White = Color3.fromRGB(255, 255, 255),
    },
})

Available Theme Keys

Background
Surface
SurfaceAlt
Sidebar
Text
MutedText
Accent
AccentDark
AccentSoft
Secondary
Positive
Stroke
Shadow
White

You only need to include the colors you want to override.

Standard Roblox ModuleScript Installation

For a standard Roblox Studio project:

Create a ModuleScript named Endware inside ReplicatedStorage.

Paste the contents of menu2.lua into it.

Require it from a LocalScript.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Endware = require(
    ReplicatedStorage:WaitForChild("Endware")
)

local Window = Endware:CreateWindow({
    Title = "MY MENU",
    Subtitle = "Powered by Endware",
})

Endware must be loaded from a client LocalScript.

Prompt Template for AI Tools

Use this prompt when asking an AI to create a menu with Endware:

Act as a senior Roblox Luau developer.

Read the Endware UI documentation:
https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/README.md

Use this Endware UI library:
https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/menu2.lua

Load it with:

local Endware = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/menu2.lua",
    true
))()

Do not rewrite the library.
Do not create a separate GUI framework.
Do not invent methods that are not documented in the README.
Use only the documented Endware API.
Give every checkbox a unique Flag.
Return one complete copy-and-run Luau code block.

Menu requirements:
[WRITE YOUR MENU REQUIREMENTS HERE]

Troubleshooting

The loader returns nil

Make sure the final line of menu2.lua returns the library:

return setmetatable({}, Endware)

The menu is duplicated

Use a unique GuiName, or destroy the old window before creating another one.

Window:Destroy()

A checkbox does not update correctly

Make sure every checkbox has a unique flag:

Flag = "UniqueFlagName"

Right Shift does not toggle the menu

Make sure another script is not consuming or replacing the selected input key. You can choose another key:

ToggleKey = Enum.KeyCode.Insert

The AI invents unsupported components

Tell the AI:

Do not invent APIs. Only use methods documented in README.md.

<br>

Endware UI — Türkçe Dokümantasyon

Luau ile yazılmış, modern, tekrar kullanılabilir ve cartoony temalı bir Roblox arayüz kütüphanesidir.

Endware UI; animasyonlu pencere, sekmeler, bölümler, açıklama kartları, butonlar, checkbox’lar, flag sistemi, bildirimler, tema özelleştirme, sürüklenebilir pencere, ekran ölçekleme ve değiştirilebilir görünürlük tuşu sunar.

Güncel sürüm: 1.3.0

Kütüphane bağlantısı:

https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/menu2.lua

Özellikler

Modern cartoony tasarım

Animasyonlu açılma ve kapanma

Sürüklenebilir pencere

Ekrana göre ölçeklenen arayüz

Özelleştirilebilir görünürlük tuşu

İkonlu ve açıklamalı sekmeler

Section sistemi

Açıklama kartları

Butonlar

Checkbox / toggle sistemi

Flag yönetimi

Bildirimler

Özel tema desteği

Otomatik bağlantı temizliği

İstemci taraflı Luau API’si

Önemli Çalışma Ortamı Notu

Endware UI bir istemci kütüphanesidir ve Players.LocalPlayer erişimi gerektirir.

Aşağıdaki HTTP yükleyicisinin çalışması için istemci ortamında şu iki özellik bulunmalıdır:

game:HttpGet()
loadstring()

Standart bir Roblox Studio projesinde Endware’i ReplicatedStorage içindeki bir ModuleScript olarak kullanmak önerilir.

Hızlı Başlangıç — HTTP / Loadstring

local Endware = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/menu2.lua",
    true
))()

Pencere oluştur:

local Window = Endware:CreateWindow({
    Title = "BENİM MENÜM",
    Subtitle = "Endware ile oluşturuldu",
    GuiName = "BenimEndwareMenum",
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(780, 510),
})

Sekme ve section oluştur:

local HomeTab = Window:CreateTab({
    Name = "Ana Sayfa",
    Icon = "★",
})

HomeTab:SetDescription("Genel bilgiler ve hızlı işlemler")

local MainSection = HomeTab:CreateSection("Ana Menü")

Kontroller ekle:

MainSection:AddParagraph(
    "Hoş Geldin",
    "Bu menü Endware UI ile oluşturuldu."
)

MainSection:AddCheckbox({
    Name = "Özelliği Etkinleştir",
    Description = "Örnek özelliği açar veya kapatır.",
    Flag = "FeatureEnabled",
    Default = true,
    FireOnInit = true,

    Callback = function(enabled)
        print("FeatureEnabled:", enabled)
    end,
})

MainSection:AddButton({
    Name = "Bildirimi Test Et",
    Description = "Örnek bir bildirim gösterir.",
    ButtonText = "GÖSTER",

    Callback = function()
        Window:Notify({
            Title = "Endware",
            Content = "Buton callback sistemi çalışıyor!",
            Duration = 3,
        })
    end,
})

Daha Güvenli HTTP Yükleyicisi

Bu yükleyici indirme, derleme ve çalışma hatalarını daha anlaşılır gösterir:

local LIBRARY_URL =
    "https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/menu2.lua"

local function loadEndware()
    local requestSuccess, sourceOrError = pcall(function()
        return game:HttpGet(LIBRARY_URL, true)
    end)

    assert(
        requestSuccess,
        "[Endware Loader] İndirme başarısız: " .. tostring(sourceOrError)
    )

    local chunk, compileError = loadstring(sourceOrError)

    assert(
        chunk,
        "[Endware Loader] Derleme hatası: " .. tostring(compileError)
    )

    local runSuccess, libraryOrError = pcall(chunk)

    assert(
        runSuccess,
        "[Endware Loader] Çalışma hatası: " .. tostring(libraryOrError)
    )

    assert(
        type(libraryOrError) == "table",
        "[Endware Loader] Uzak dosya Endware kütüphanesini döndürmelidir."
    )

    return libraryOrError
end

local Endware = loadEndware()

API Referansı

Endware.Version

Kütüphanenin güncel sürümünü döndürür.

print(Endware.Version)

Endware:CreateWindow(options)

Yeni bir Endware penceresi oluşturur ve döndürür.

local Window = Endware:CreateWindow({
    Title = "ENDWARE",
    Subtitle = "Cartoony Kontrol Merkezi",
    GuiName = "EndwareUI",
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(780, 510),
    DisplayOrder = 100,
    Theme = {},
})

Pencere Seçenekleri

Seçenek

Tür

Zorunlu

Açıklama

Title

string

Hayır

Ana pencere başlığı

Subtitle

string

Hayır

Başlığın altındaki metin

GuiName

string

Hayır

Benzersiz ScreenGui adı

ToggleKey

Enum.KeyCode

Hayır

Menüyü gösterip gizleyen tuş

Size

UDim2

Hayır

Pencere boyutu

DisplayOrder

number

Hayır

ScreenGui.DisplayOrder değeri

Theme

table

Hayır

Tema renk değişiklikleri

Varsayılan görünürlük tuşu:

Enum.KeyCode.RightShift

Window:CreateTab(options)

Yeni bir sekme oluşturur ve döndürür.

local Tab = Window:CreateTab({
    Name = "Ana Sayfa",
    Icon = "★",
})

Sekme Seçenekleri

Seçenek

Tür

Zorunlu

Açıklama

Name

string

Evet

Sekme adı

Icon

string

Hayır

Kısa ikon, sembol veya karakter

Doğrudan string de kullanılabilir:

local Tab = Window:CreateTab("Ana Sayfa")

Tab:SetDescription(description)

Aktif sekmenin altında gösterilen açıklamayı ayarlar.

Tab:SetDescription("Genel bilgiler ve hızlı işlemler")

Sekmeyi geri döndürdüğü için zincirleme kullanım yapılabilir.

Tab:CreateSection(title)

Sekme içinde yeni bir bölüm oluşturur ve döndürür.

local Section = Tab:CreateSection("Genel")

Section:AddParagraph(title, content)

Etkileşimsiz bir bilgi kartı ekler.

Section:AddParagraph(
    "Bilgilendirme",
    "Bu metin bölümün ne yaptığını açıklar."
)

Section:AddButton(options)

Tıklanabilir bir buton ekler.

local Button = Section:AddButton({
    Name = "İşlemi Çalıştır",
    Description = "Örnek callback fonksiyonunu çalıştırır.",
    ButtonText = "ÇALIŞTIR",

    Callback = function()
        print("Butona basıldı")
    end,
})

Buton Seçenekleri

Seçenek

Tür

Zorunlu

Açıklama

Name

string

Evet

Buton başlığı

Description

string

Hayır

Buton açıklaması

ButtonText

string

Hayır

İşlem butonunun içindeki yazı

Callback

function

Hayır

Butona basılınca çalışacak fonksiyon

Butonu yok et:

Button:Destroy()

Section:AddCheckbox(options)

Bir checkbox ekler ve değerini Window.Flags içinde saklar.

local Checkbox = Section:AddCheckbox({
    Name = "Müzik",
    Description = "Arka plan müziğini açar veya kapatır.",
    Flag = "MusicEnabled",
    Default = true,
    FireOnInit = false,

    Callback = function(enabled)
        print("MusicEnabled:", enabled)
    end,
})

Checkbox Seçenekleri

Seçenek

Tür

Zorunlu

Açıklama

Name

string

Evet

Checkbox başlığı

Description

string

Hayır

Checkbox açıklaması

Flag

string

Hayır

Window.Flags içinde saklanacak benzersiz anahtar

Default

boolean

Hayır

Başlangıç değeri

FireOnInit

boolean

Hayır

Oluşturulunca callback’i hemen çalıştırır

Callback

function(boolean)

Hayır

Değer değiştiğinde çalışır

Her checkbox için benzersiz bir Flag kullan.

Checkbox Nesnesi

Değeri değiştir:

Checkbox:Set(true)

Değeri oku:

print(Checkbox:Get())

Değeri tersine çevir:

Checkbox:Toggle()

Checkbox’ı yok et:

Checkbox:Destroy()

Toggle Takma Adı

AddToggle, AddCheckbox metodunun takma adıdır:

Section:AddToggle({
    Name = "Örnek Toggle",
    Flag = "ExampleToggle",
    Default = false,
})

Window.Flags

Bütün güncel flag değerlerini içeren tablodur.

print(Window.Flags.MusicEnabled)

for flag, value in pairs(Window.Flags) do
    print(flag, value)
end

Window:GetFlag(flag)

Kayıtlı bir flag değerini döndürür.

local enabled = Window:GetFlag("MusicEnabled")
print(enabled)

Window:SetFlag(flag, value, silent?)

Bir flag değerini kod üzerinden değiştirir.

Window:SetFlag("MusicEnabled", false)

Checkbox callback’inin çalışmasını engelle:

Window:SetFlag("MusicEnabled", false, true)

Window:Notify(options)

Ekranda bir bildirim gösterir.

Window:Notify({
    Title = "Başarılı",
    Content = "İşlem tamamlandı.",
    Duration = 3,
})

Bildirim Seçenekleri

Seçenek

Tür

Zorunlu

Açıklama

Title

string

Hayır

Bildirim başlığı

Content

string

Hayır

Bildirim mesajı

Duration

number

Hayır

Saniye cinsinden gösterim süresi

Window:SetVisible(visible)

Pencereyi gösterir veya gizler.

Window:SetVisible(false)
Window:SetVisible(true)

Window:Toggle()

Pencerenin görünürlük durumunu tersine çevirir.

Window:Toggle()

Window:IsVisible()

Pencerenin görünür olup olmadığını döndürür.

print(Window:IsVisible())

Window:Destroy()

Arayüzün tamamını yok eder ve event bağlantılarını temizler.

Window:Destroy()

Tab:Destroy()

Sekmeyi ve içeriğini yok eder.

Tab:Destroy()

Tema Özelleştirme

Varsayılan tema renklerinden istediğini değiştirebilirsin.

local Window = Endware:CreateWindow({
    Title = "ÖZEL TEMA",
    Subtitle = "Endware ile oluşturuldu",

    Theme = {
        Background = Color3.fromRGB(255, 247, 238),
        Surface = Color3.fromRGB(255, 255, 255),
        SurfaceAlt = Color3.fromRGB(255, 243, 231),
        Sidebar = Color3.fromRGB(255, 230, 205),

        Text = Color3.fromRGB(47, 35, 48),
        MutedText = Color3.fromRGB(104, 84, 100),

        Accent = Color3.fromRGB(255, 105, 133),
        AccentDark = Color3.fromRGB(205, 55, 91),
        AccentSoft = Color3.fromRGB(255, 216, 226),

        Secondary = Color3.fromRGB(255, 190, 78),
        Positive = Color3.fromRGB(69, 190, 137),

        Stroke = Color3.fromRGB(226, 196, 180),
        Shadow = Color3.fromRGB(108, 82, 94),
        White = Color3.fromRGB(255, 255, 255),
    },
})

Kullanılabilir Tema Anahtarları

Background
Surface
SurfaceAlt
Sidebar
Text
MutedText
Accent
AccentDark
AccentSoft
Secondary
Positive
Stroke
Shadow
White

Yalnızca değiştirmek istediğin renkleri eklemen yeterlidir.

Standart Roblox ModuleScript Kurulumu

Standart bir Roblox Studio projesinde:

ReplicatedStorage içine Endware isimli bir ModuleScript oluştur.

menu2.lua içeriğini ModuleScript’e yapıştır.

Bir istemci LocalScript içinden require et.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Endware = require(
    ReplicatedStorage:WaitForChild("Endware")
)

local Window = Endware:CreateWindow({
    Title = "BENİM MENÜM",
    Subtitle = "Endware ile oluşturuldu",
})

Endware istemci tarafındaki bir LocalScript içinden yüklenmelidir.

AI Araçları İçin Prompt Şablonu

Bir AI’dan Endware kullanarak menü oluşturmasını isterken bu promptu kullan:

Üst düzey bir Roblox Luau geliştiricisi gibi davran.

Endware UI dokümantasyonunu oku:
https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/README.md

Şu Endware UI kütüphanesini kullan:
https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/menu2.lua

Kütüphaneyi şu şekilde yükle:

local Endware = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ardadeska-cmyk/menu/refs/heads/main/menu2.lua",
    true
))()

Kütüphaneyi yeniden yazma.
Ayrı bir GUI framework oluşturma.
README dosyasında belgelenmeyen fonksiyonlar uydurma.
Yalnızca belgelenmiş Endware API’sini kullan.
Her checkbox için benzersiz bir Flag kullan.
Tek parça, kopyalanıp çalıştırılabilir Luau kodu döndür.

Menü gereksinimleri:
[İSTEDİĞİN MENÜ ÖZELLİKLERİNİ BURAYA YAZ]

Sorun Giderme

Loader nil döndürüyor

menu2.lua dosyasının son satırının kütüphaneyi döndürdüğünden emin ol:

return setmetatable({}, Endware)

Menü iki kez oluşuyor

Benzersiz bir GuiName kullan veya yeni pencere oluşturmadan önce eski pencereyi yok et:

Window:Destroy()

Checkbox doğru güncellenmiyor

Her checkbox’ın benzersiz bir flag kullandığından emin ol:

Flag = "UniqueFlagName"

Sağ Shift menüyü açıp kapatmıyor

Başka bir scriptin aynı tuşu işlemediğinden emin ol. Başka bir tuş seçebilirsin:

ToggleKey = Enum.KeyCode.Insert

AI desteklenmeyen bileşenler uyduruyor

AI’ya şu talimatı ver:

API uydurma. Yalnızca README.md içinde belgelenen metotları kullan.

Repository Files

README.md   — Documentation
menu2.lua   — Endware UI library

Made with Endware UI.
