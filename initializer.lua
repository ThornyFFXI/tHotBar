--Set up globals..
ffi           = require('ffi');
imgui         = require('imgui');
settings      = require('settings');
gInterface    = require('interface');
gPlayer       = require('player');
gMouseHandler = require('mousehandler');
gBindingGUI   = require('bindinggui');
gConfigGUI    = require('configgui');

local defaultSettings = T{
    layout = '10x3_750p',
    enableCost = true,
    enableCross = true,
    enableFade = true,
    enableName = true,
    enableRecast = true,
    enableSkillchainIcon = true,
    enableSkillchainAnimation = true,
    enableTrigger = true,
};

gSettings = settings.load(defaultSettings);
gInterface:Initialize(gSettings.layout);