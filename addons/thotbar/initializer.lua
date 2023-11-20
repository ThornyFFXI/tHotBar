--Initialize Globals..
require('helpers');
gTextureCache    = require('texturecache');
gBindings        = require('bindings');
gBindingGUI      = require('bindinggui');
gConfigGUI       = require('configgui');
gDisplay         = require('display');
settings         = require('settings');

local d3d8       = require('d3d8');
local ffi        = require('ffi');
local scaling    = require('scaling');

--Create directories..
local layoutConfigFolder = string.format('%sconfig/addons/%s/resources/layouts', AshitaCore:GetInstallPath(), addon.name);
if not ashita.fs.exists(layoutConfigFolder) then
    ashita.fs.create_directory(layoutConfigFolder);
end

--Initialize settings..
local defaultSettings = T{
    Layout = '10x3',
    Scale = 1.0,
    TriggerDuration = 0.25,
    ShowEmpty = true,
    ShowFrame = true,
    ShowCost = true,
    ShowCross = true,
    ShowFade = true,
    ShowName = true,
    ShowRecast = true,
    ShowHotkey = false,
    ShowSkillchainIcon = true,
    ShowSkillchainAnimation = true,
    ShowTrigger = true,
    ShowPalette = true,

    --Behavior tab..
    ClickToActivate = true,
    HideWhileZoning = true,
    HideWhileCutscene = true,
    HideWhileMap = true,
    DefaultSelectTarget = false,
};

gSettings = settings.load(defaultSettings);

local function UpdateSettings()
    if (gSettings.Version ~= addon.version) then
        if (type(gSettings.Version) ~= 'number') or (gSettings.Version < 2.0) then
            for key,val in pairs(gSettings) do
                local newVal = defaultSettings[key];
                if newVal then
                    gSettings[key] = newVal;
                else
                    gSettings[key] = nil;
                end
            end
            Message('Settings from a prior incompatible version detected.  Updating settings.')
        end
        gSettings.Version = tonumber(addon.version);
        settings.save();
    end
end
UpdateSettings();

local function PrepareLayout(layout, scale)
    local tx = layout.Textures[layout.DragHandle.Texture]
    layout.DragHandle.Width = tx.Width;
    layout.DragHandle.Height = tx.Height;

    for _,singleTable in ipairs(T{layout, layout.FixedObjects, layout.Elements, layout.Textures}) do
        for _,tableEntry in pairs(singleTable) do
            if (type(tableEntry) == 'table') then
                if (tableEntry.OffsetX ~= nil) then
                    tableEntry.OffsetX = tableEntry.OffsetX * scale;
                    tableEntry.OffsetY = tableEntry.OffsetY * scale;
                end
                if (tableEntry.Width ~= nil) then
                    tableEntry.Width = tableEntry.Width * scale;
                    tableEntry.Height = tableEntry.Height * scale;
                end
                if (tableEntry.font_height ~= nil) then
                    tableEntry.font_height = math.max(5, math.floor(tableEntry.font_height * scale));
                end
                if (tableEntry.outline_width ~= nil) then
                    tableEntry.outline_width = math.min(3, math.max(1, math.floor(tableEntry.outline_width * scale)));
                end
            end
        end
    end
    
    --Prepare textures for efficient rendering..
    for _,singleTable in ipairs(T{layout.SkillchainFrames, layout.Textures}) do
        for key,entry in pairs(singleTable) do
            local tx,dimensions;
            if type(entry) == 'table' then
                tx = gTextureCache:GetTexture(entry.Path)
                dimensions = { Width=entry.Width, Height=entry.Height };
            else
                tx = gTextureCache:GetTexture(entry)
                dimensions = { Width=layout.Icon.Width, Height=layout.Icon.Height };
            end

            if tx and dimensions then
                local preparedTexture = {};
                preparedTexture.Texture = tx.Texture;
                preparedTexture.Rect = ffi.new('RECT', { 0, 0, tx.Width, tx.Height });
                preparedTexture.Scale = ffi.new('D3DXVECTOR2', { dimensions.Width / tx.Width, dimensions.Height / tx.Height });
                singleTable[key] = preparedTexture;
            else
                singleTable[key] = nil;
            end
        end
    end

    layout.FadeOpacity = d3d8.D3DCOLOR_ARGB(layout.FadeOpacity, 255, 255, 255);
    layout.TriggerOpacity = d3d8.D3DCOLOR_ARGB(layout.TriggerOpacity, 255, 255, 255);
end

local function GetDefaultPosition(layout)
    if ((scaling.window.w == -1) or (scaling.window.h == -1) or (scaling.menu.w == -1) or (scaling.menu.h == -1)) then
        return { 0, 0 };
    else
        --Centered horizontally, vertically just above chat log.
        return {
            (scaling.window.w - layout.Panel.Width) / 2,
            scaling.window.h - (scaling.scale_height(136) + layout.Panel.Height)
        };
    end
end

--Create exports..
local Initializer = {};

function Initializer:ApplyLayout()
    gDisplay:Destroy();

    local layout = LoadFile_s(GetResourcePath('layouts/' .. gSettings.Layout));
    if layout then
        PrepareLayout(layout, gSettings.Scale);
        local position = gSettings.Position;
        if position == nil then
            gSettings.Position = GetDefaultPosition(layout);
            settings.save();
        end
        gDisplay:Initialize(layout);
    else
        Error('Failed to load layout.  Please enter "/tb" to open the menu and select a valid layout.');
    end
    
    gTextureCache:Clear();
end

settings.register('settings', 'settings_update', function(newSettings)
    gSettings = newSettings;
    UpdateSettings();
    Initializer:ApplyLayout();
end);

Initializer:ApplyLayout();

return Initializer;