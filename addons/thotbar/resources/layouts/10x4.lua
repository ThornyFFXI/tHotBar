local layout = {
    --Amount is not fixed, you can adjust as desired.
    SkillchainFrames = T{
        'misc/crawl1.png',
        'misc/crawl2.png',
        'misc/crawl3.png',
        'misc/crawl4.png',
        'misc/crawl5.png',
        'misc/crawl6.png',
        'misc/crawl7.png'
    },

    --Time, in seconds, between frame changes for skillchain animation.
    SkillchainFrameLength = 0.08,

    --[[
        Textures to be preloaded and sized.
        Can be a string, or a table with Path, Width, and Height entries.
        If using a string, will be sized to match the Width and Height specified for Icon.
    ]]--
    Textures = T{
        Cross         = 'misc/cross.png',
        Frame         = { Path='misc/frame.png', Width=44, Height=44 },
        Trigger       = 'misc/trigger.png',
        Liquefaction  = 'skillchains/Liquefaction.png',
        Scission      = 'skillchains/Scission.png',
        Reverberation = 'skillchains/Reverberation.png',
        Detonation    = 'skillchains/Detonation.png',
        Induration    = 'skillchains/Induration.png',
        Impaction     = 'skillchains/Impaction.png',
        Transfixion   = 'skillchains/Transfixion.png',
        Compression   = 'skillchains/Compression.png',
        Fusion        = 'skillchains/Fusion.png',
        Gravitation   = 'skillchains/Gravitation.png',
        Distortion    = 'skillchains/Distortion.png',
        Fragmentation = 'skillchains/Fragmentation.png',
        Light         = 'skillchains/Light.png',
        Darkness      = 'skillchains/Darkness.png',
        Buttons       = { Path='misc/buttons.png', Width=40, Height=40 },
        Dpad          = { Path='misc/dpad.png', Width=40, Height=40 },
        DragHandle    = { Path='misc/drag.png', Width=26, Height=26 },
    },

    --Transparency to be used when bound macro's action is not known.  [0-255]
    FadeOpacity = 128,
    
    --Opacity of the overlay shown when a macro is activated.  [0-255]
    TriggerOpacity = 128,    
    
    --Icon to be displayed when draggability is enabled.
    DragHandle = {
        OffsetX = 0,
        OffsetY = 0,
        Texture = 'DragHandle',
    },

    --The border of each macro element.  Offsets are relative to the macro element's placement.
    Frame = {
        OffsetX = 0,
        OffsetY = 0,
        Width = 44,
        Height = 44,
    },

    --The inner icon for each macro element.  Offsets are relative to the macro element's placement.
    Icon = {
        OffsetX = 2,
        OffsetY = 2,
        Width = 40,
        Height = 40,
    },

    --The text object to display macro or hotkey activation.
    Hotkey = {
        --If box height/width are specified, text object will not go past those bounds.
        --Otherwise, text object will be as large as necessary.
        box_height = 0,
        box_width = 0,

        --See gdifonts/include for flags and usage..
        font_alignment = 0,
        font_color = 0xFFFFFFFF,
        font_family = 'Arial',
        font_flags = 0,
        font_height = 12,
        gradient_color = 0x00000000,
        gradient_style = 0,
        outline_color = 0xFF000000,
        outline_width = 1,

        OffsetX = 2,
        OffsetY = 2,
    },
    Cost = {
        box_height = 0,
        box_width = 0,
        font_alignment = 2,
        font_color = 0xFF389609,
        font_family = 'Arial',
        font_flags = 0,
        font_height = 9,
        gradient_color = 0x00000000,
        gradient_style = 0,
        outline_color = 0xFF000000,
        outline_width = 2,
        OffsetX = 42,
        OffsetY = 31,
    },
    Recast = {
        box_height = 0,
        box_width = 0,
        font_alignment = 0,
        font_color = 0xFFBFCC04,
        font_family = 'Arial',
        font_flags = 0,
        font_height = 9,
        gradient_color = 0x00000000,
        gradient_style = 0,
        outline_color = 0xFF000000,
        outline_width = 2,
        OffsetX = 2,
        OffsetY = 31,
    },
    Name = {
        box_height = 0,
        box_width = 0,
        font_alignment = 1,
        font_color = 0xFFFFFFFF,
        font_family = 'Arial',
        font_flags = 0,
        font_height = 9,
        gradient_color = 0x00000000,
        gradient_style = 0,
        outline_color = 0xFF000000,
        outline_width = 2,
        OffsetX = 22,
        OffsetY = 44,
    },
    
    --Text object to display palette name.  Offsets are relative to entire panel.  Only present in double display.
    Palette = {
        box_height = 0,
        box_width = 0,
        font_alignment = 1,
        font_color = 0xFFFF0000,
        font_family = 'Arial',
        font_flags = 0,
        font_height = 15,
        gradient_color = 0xFFFC0384,
        gradient_style = 3,
        outline_color = 0xFF000000,
        outline_width = 2,
        OffsetX = 361,
        OffsetY = 0,
    },

    --Texture must be defined in textures table.  Objects are rendered in order, prior to square elements.
    FixedObjects = T{
    },

    --Size of entire panel.  Used for prescreening element clicks and automatic positioning.  Not enforced for rendering.
    --Filled by iteration.
    Panel = {
        Width = 0,
        Height = 0,
    },
    
    --[[
        Table of elements.  Each entry must have 'DefaultMacro' (ashita binding format), OffsetX, and OffsetY.
        Easier to fill in OffsetX and OffsetY with iteration(see end of file).
    ]]--
    Elements = T{
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
        { DefaultMacro = '+1' },
        { DefaultMacro = '+2' },
        { DefaultMacro = '+3' },
        { DefaultMacro = '+4' },
        { DefaultMacro = '+5' },
        { DefaultMacro = '+6' },
        { DefaultMacro = '+7' },
        { DefaultMacro = '+8' },
        { DefaultMacro = '+9' },
        { DefaultMacro = '+0' },
    },
};

local index = 1;
local offsetX;
local offsetY = 30;
for y = 0,3 do
    offsetX = 7;
    for x = 0,9 do
        layout.Elements[index].OffsetX = offsetX;
        layout.Elements[index].OffsetY = offsetY;
        index = index + 1;
        offsetX = offsetX + 58;
    end
    offsetY = offsetY + 58;
end
layout.Panel.Width = offsetX;
layout.Panel.Height = offsetY;
layout.Palette.OffsetX = layout.Panel.Width / 2;
return layout;