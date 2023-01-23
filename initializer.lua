function Error(text)
    local color = ('\30%c'):format(68);
    local highlighted = color .. string.gsub(text, '$H', '\30\01\30\02');
    highlighted = string.gsub(highlighted, '$R', '\30\01' .. color);
    print(chat.header(addon.name) .. highlighted .. '\30\01');
end

function Message(text)
    local color = ('\30%c'):format(106);
    local highlighted = color .. string.gsub(text, '$H', '\30\01\30\02');
    highlighted = string.gsub(highlighted, '$R', '\30\01' .. color);
    print(chat.header(addon.name) .. highlighted .. '\30\01');
end

function GetImagePath(image, default)
    if (string.sub(image, 1, 5) == 'ITEM:') then
        return image;
    end
    
    local potentialPaths = T{
        image,
        string.format('%sconfig/addons/%s/resources/%s', AshitaCore:GetInstallPath(), addon.name, image),
        string.format('%saddons/%s/resources/%s', AshitaCore:GetInstallPath(), addon.name, image),
        default or '',
        string.format('%sconfig/addons/%s/resources/misc/unknown.png', AshitaCore:GetInstallPath(), addon.name),
        string.format('%saddons/%s/resources/misc/unknown.png', AshitaCore:GetInstallPath(), addon.name),
    };

    for _,path in ipairs(potentialPaths) do
        if (path ~= '') and (ashita.fs.exists(path)) then
            return path;
        end
    end

    return nil;
end

function LoadFile_s(filePath)
    if not ashita.fs.exists(filePath) then
        return nil;
    end

    local success, loadError = loadfile(filePath);
    if not success then
        Error(string.format('Failed to load resource file: $H%s', filePath));
        Error(loadError);
        return nil;
    end

    local result, output = pcall(success);
    if not result then
        Error(string.format('Failed to execute resource file: $H%s', filePath));
        Error(loadError);
        return nil;
    end

    return output;
end

--Set up globals.. order matters here, don't mess with it.
ffi           = require('ffi');
imgui         = require('imgui');
settings      = require('settings');
gInterface    = require('interface');
gBindings     = require('bindings');
gInventory    = require('state.inventory');
gPlayer       = require('state.player');
gSkillchain   = require('state.skillchain');
gMouseHandler = require('mousehandler');
gBindingGUI   = require('bindinggui');
gConfigGUI    = require('configgui');

local defaultSettings = T{
    Layout = '10x3_750p',
    Position = T{},
    ClickToActivate = true,
    ShowCost = true,
    ShowCross = true,
    ShowFade = true,
    ShowName = true,
    ShowRecast = true,
    ShowSkillchainIcon = true,
    ShowSkillchainAnimation = true,
    ShowTrigger = true,
    HideWhileZoning = true,
    HideWhileCutscene = true,
    HideWhileMap = true,
};

local layoutConfigFolder = string.format('%sconfig/addons/%s/resources/layouts', AshitaCore:GetInstallPath(), addon.name);
if not ashita.fs.exists(layoutConfigFolder) then
    ashita.fs.create_directory(layoutConfigFolder);
end


gSettings = settings.load(defaultSettings);
gInterface:Initialize(gSettings.Layout);

settings.register('settings', 'settings_update', function(newSettings)
    gSettings = newSettings;
    gInterface:Initialize(gSettings.Layout);
end);

return true;