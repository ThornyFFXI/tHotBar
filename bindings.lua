local retTable = T{
    ['^1'] = {
        Type = 'Ability', --Ability, Command, Item, Spell, Weaponskill
        Id = 202, --Action ID must be valid for ability, item, spell, weaponskill.
        Label = 'Box Step',
        Hotkey = '^2',
        ActionCommand = '/ja "Hasso" <me>', --Actual command to be sent, or table of commands.
        Image = 'abilities/51.png',
        ShowActivation = true,
        ShowCost = true,
        ShowCross = true,
        ShowDimming = true,
        ShowHotkey = true,
        ShowLabel = true,
        ShowRecast = true,
    },
};

for row = 1,3 do
    for column = 1,10 do
        retTable:append(
            {
        });
    end
end
return retTable;
--[[
return {    
    {
        Row = 1,
        Column = 1,
        ActionType = 'Item', --Ability, Custom, Item, Spell, Weaponskill
        ActionId = 28540, --Action ID must be valid for ability, item, spell, weaponskill.
        Label = 'Warp',
        Hotkey = '^1',
        HotkeyLabel = 'c1',
        ActionCommand = '/ja "Box Step" <t>', --Actual command to be sent, or table of commands.
        Image = 'BUFF:4',
        ShowActivation = true,
        ShowCost = true,
        ShowCross = true,
        ShowDimming = true,
        ShowHotkey = true,
        ShowLabel = true,
        ShowRecast = true,
    },
    {
        Row = 1,
        Column = 2,
        ActionType = 'Ability', --Ability, Command, Item, Spell, Weaponskill
        ActionId = 173, --Action ID must be valid for ability, item, spell, weaponskill.
        Label = 'Hasso',
        Hotkey = '^2',
        HotkeyLabel = 'c2',
        ActionCommand = '/ja "Hasso" <me>', --Actual command to be sent, or table of commands.
        Image = 'ITEM:4149',
        ShowActivation = true,
        ShowCost = true,
        ShowCross = true,
        ShowDimming = false,
        ShowHotkey = true,
        ShowLabel = true,
        ShowRecast = true,
    },
    {
        Row = 2,
        Column = 2,
        ActionType = 'Ability', --Ability, Command, Item, Spell, Weaponskill
        ActionId = 173, --Action ID must be valid for ability, item, spell, weaponskill.
        Label = 'Hasso',
        Hotkey = '^2',
        HotkeyLabel = 'c2',
        ActionCommand = '/ja "Hasso" <me>', --Actual command to be sent, or table of commands.
        Image = 'abilities/51.png',
        ShowActivation = true,
        ShowCost = true,
        ShowCross = true,
        ShowDimming = true,
        ShowHotkey = true,
        ShowLabel = true,
        ShowRecast = true,
    },
    {
        Row = 1,
        Column = 3,
        ActionType = 'Ability', --Ability, Command, Item, Spell, Weaponskill
        ActionId = 16, --Action ID must be valid for ability, item, spell, weaponskill.
        Label = 'MS',
        Hotkey = '^3',
        HotkeyLabel = 'c3',
        ActionCommand = '/ja "Mighty Strikes" <me>', --Actual command to be sent, or table of commands.
        Image = 'abilities/32.png',
        ShowActivation = true,
        ShowCost = true,
        ShowCross = true,
        ShowDimming = true,
        ShowHotkey = true,
        ShowLabel = true,
        ShowRecast = true,
    },
    {
        Row = 1,
        Column = 4,
        ActionType = 'Ability', --Ability, Command, Item, Spell, Weaponskill
        ActionId = 202, --Action ID must be valid for ability, item, spell, weaponskill.
        Label = 'BoxStep',
        Hotkey = '^4',
        HotkeyLabel = 'c4',
        ActionCommand = '/ja "Mighty Strikes" <me>', --Actual command to be sent, or table of commands.
        Image = 'abilities/218.png',
        ShowActivation = true,
        ShowCost = true,
        ShowCross = true,
        ShowDimming = true,
        ShowHotkey = true,
        ShowLabel = true,
        ShowRecast = true,
    },
    {
        Row = 1,
        Column = 5,
        ActionType = 'Ability', --Ability, Command, Item, Spell, Weaponskill
        ActionId = 215, --Action ID must be valid for ability, item, spell, weaponskill.
        Label = 'Penury',
        Hotkey = '^5',
        HotkeyLabel = 'c5',
        ActionCommand = '/ja "Mighty Strikes" <me>', --Actual command to be sent, or table of commands.
        Image = 'abilities/230.png',
        ShowActivation = true,
        ShowCost = true,
        ShowCross = true,
        ShowDimming = true,
        ShowHotkey = true,
        ShowLabel = true,
        ShowRecast = true,
    },


}

--[[
    Notes on custom element:
    * Draws icon, hotkey, activation as normal.  Label drawn as normal unless function provided.
    * CostFunction member returns string to show cost, anything else to hide.
    * CrossFunction member returns true to display cross, anything else to hide.
    * DimFunction member returns true to dim icon, anything else to hide.
    * LabelFunction member returns string to show label, anything else to hide.
    * RecastFunction member returns string to show recast, anything else to hide.
    * IconFunction member returns string to change icon, nil to hide icon.  Optional second parameter to update color mask.

    
        -Label can be a function.
    -Draws hotkey as normal.
    -Handles cross if custom function set.
    -Handles dimming if custom function set
        ]]
        