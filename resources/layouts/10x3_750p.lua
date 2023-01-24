local theme = {
    FontObjects = {
        --[[
            OffsetX: Distance from the top left of individual square object.
            OffsetY: Distance from the top right of individual square object.
            BoxWidth: Width of the box for text to be drawn into.
            BoxHeight: Height of the box for text to be drawn into.
            OutlineWidth: Width of the text outline.
            FontHeight: Height of the font.
            FontFamily: Font Family.
            FontFlags: bitflags for font modifiers
               0x01 - Bold
               0x02 - Italic
               0x04 - Underline
               0x08 - Strikeout
            FontAlignment: Font alignment within the box
               0x00 - Left Aligned
               0x01 - Center Aligned
               0x02 - Right Aligned
            FontColor - Hex ARGB value, highest significance byte is alpha.
            OutlineColor - Hex ARGB value, highest significance byte is alpha.
        ]]--
        Cost = {
            OffsetX = 3,
            OffsetY = 48,
            BoxWidth = 60,
            BoxHeight = 12,
            OutlineWidth = 2,
            FontHeight = 12,
            FontFamily = 'Arial',
            FontFlags = 0,
            FontAlignment = 2,
            FontColor = 0xFFC00080,
            OutlineColor = 0xFF000000,
        },
        Macro = {
            OffsetX = 3,
            OffsetY = 3,
            BoxWidth = 60,
            BoxHeight = 12,
            OutlineWidth = 2,
            FontHeight = 12,
            FontFamily = 'Arial',
            FontFlags = 0,
            FontAlignment = 0,
            FontColor = 0xFFFFFFFF,
            OutlineColor = 0xFF000000,
        },
        Name = {
            OffsetX = 2,
            OffsetY = 66,
            BoxWidth = 60,
            BoxHeight = 15,
            OutlineWidth = 2,
            FontHeight = 12,
            FontFamily = 'Arial',
            FontFlags = 0,
            FontAlignment = 1,
            FontColor = 0xFFFFFFFF,
            OutlineColor = 0xFF000000,
        },
        Recast = {
            OffsetX = 3,
            OffsetY = 48,
            BoxWidth = 60,
            BoxHeight = 15,
            OutlineWidth = 2,
            FontHeight = 12,
            FontFamily = 'Arial',
            FontFlags = 0,
            FontAlignment = 0,
            FontColor = 0xFF00FF00,
            OutlineColor = 0xFF000000,
        },
    },

    ImageObjects = {
        --[[
            OffsetX: Distance from the top left of individual square object.
            OffsetY: Distance from the top right of individual square object.
            Width: Width of image to be drawn.
            Height: Height of image to be drawn.
        ]]--
        Frame = {
            OffsetX = 0,
            OffsetY = 0,
            Width = 66,
            Height = 66
        },
        Icon = {
            OffsetX = 3,
            OffsetY = 3,
            Width = 60,
            Height = 60
        },
        Overlay = {
            OffsetX = 3,
            OffsetY = 3,
            Width = 60,
            Height = 60
        },
    },

    Background = {
        texture         = nil,
        texture_offset_x= 0.0,
        texture_offset_y= 0.0,
        border_visible  = false,
        border_color    = 0x00000000,
        border_flags    = FontBorderFlags.None,
        border_sizes    = '0,0,0,0',
        visible         = true,
        position_x      = 0,
        position_y      = 0,
        can_focus       = false,
        locked          = false,
        lockedz         = false,
        scale_x         = 1.0,
        scale_y         = 1.0,
        width           = 709,
        height          = 263,
        color           = 0x70000000,
    },

    --Level of transparency to be used for icons that are faded(due to recast down, or ability cost not met).
    IconFadeAlpha = 0.5,

    --[[
        Path to images..
        First checks absolute path.
        Next checks: ashita/config/addons/addonname/resources/
        Finally checks: ashita/addons/addonname/resources/
    ]]--
    FramePath = 'misc/frame.png',
    CrossPath = 'misc/cross.png',
    TriggerPath = 'misc/trigger.png',

    --This is checked the same way, and can contain any amount of frames.  Frames cycle back to first after last is completed.
    SkillchainAnimationPaths = T{
        'misc/crawl1.png',
        'misc/crawl2.png',
        'misc/crawl3.png',
        'misc/crawl4.png',
        'misc/crawl5.png',
        'misc/crawl6.png',
        'misc/crawl7.png'
    },

    --Time, in seconds, to wait between advancing frames of skillchain animation.
    SkillchainAnimationTime = 0.08,

    --Height of the full graphics object used to render all squares.  All squares *MUST* fully fit within this panel.
    PanelHeight = 263,

    --Width of the full graphics object used to render all squares.  All squares *MUST* fully fit within this panel.
    PanelWidth = 709,

    --Default position for object.  Set later in this theme using scaling lib.
    DefaultX = 0,
    DefaultY = 0,

    --Height of an individual square object.
    SquareHeight = 83,

    --Width of an individual square object.
    SquareWidth = 66,

    --Amount of square Objects
    SquareCount = 0,

    --Table of square objects, where each entry must be a table with attributes PositionX, PositionY, DefaultMacro.
    --Table is initialized this way so that the array afterwards can fill in position.  Can be initialized using constants.
    Squares = T{
        { DefaultMacro = '1' },
        { DefaultMacro = '2' },
        { DefaultMacro = '3' },
        { DefaultMacro = '4' },
        { DefaultMacro = '5' },
        { DefaultMacro = '6' },
        { DefaultMacro = '7' },
        { DefaultMacro = '8' },
        { DefaultMacro = '9' },
        { DefaultMacro = '0' },
        { DefaultMacro = '^1' },
        { DefaultMacro = '^2' },
        { DefaultMacro = '^3' },
        { DefaultMacro = '^4' },
        { DefaultMacro = '^5' },
        { DefaultMacro = '^6' },
        { DefaultMacro = '^7' },
        { DefaultMacro = '^8' },
        { DefaultMacro = '^9' },
        { DefaultMacro = '^0' },
        { DefaultMacro = '!1' },
        { DefaultMacro = '!2' },
        { DefaultMacro = '!3' },
        { DefaultMacro = '!4' },
        { DefaultMacro = '!5' },
        { DefaultMacro = '!6' },
        { DefaultMacro = '!7' },
        { DefaultMacro = '!8' },
        { DefaultMacro = '!9' },
        { DefaultMacro = '!0' },
    },
};

for i = 0,2 do
    local offsetY = 2 + (i * 88);
    for j = 0,9 do
        theme.SquareCount = theme.SquareCount + 1;
        theme.Squares[theme.SquareCount].OffsetX = 2 + (j * 71);
        theme.Squares[theme.SquareCount].OffsetY = offsetY;
    end
end

local scaling = require('scaling');
if ((scaling.window.w == -1) or (scaling.window.h == -1) or (scaling.menu.w == -1) or (scaling.menu.h == -1)) then
    theme.DefaultX = 0;
    theme.DefaultY = 0;
else
    theme.DefaultX = (scaling.window.w - theme.PanelWidth) / 2;
    theme.DefaultY = scaling.window.h - (scaling.scale_height(136) + theme.PanelHeight);
end

return theme;