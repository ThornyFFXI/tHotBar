
local d3d8 = require('d3d8');
local d3d8_device = d3d8.get_device();
local header = { 1.0, 0.75, 0.55, 1.0 };
local state = { IsOpen={ false } };
local Setup = {};
local Update = {};

local function CheckBox(member)
    if (imgui.Checkbox(string.format('%s##Binding_%s', member, member), { state.Components[member] })) then
        state.Components[member] = not state.Components[member];
    end
end

local function ComboBox(displayName, varName)
    if (state.Combos[varName] == nil) then
        state.Combos[varName] = T{};
    end
    if (state.Indices[varName] == nil) then
        state.Indices[varName] = 1;
    end

    imgui.TextColored(header, displayName);
    local text = state.Combos[varName][state.Indices[varName]];
    if (text == nil) then text = 'N/A'; end
    if (imgui.BeginCombo(string.format('##%s', displayName), text, ImGuiComboFlags_None)) then
        for index,entry in ipairs(state.Combos[varName]) do
            local isSelected = (index == state.Indices[varName]);
            if (imgui.Selectable(entry, isSelected)) then
                if (not isSelected) then
                    state.Indices[varName] = index;
                    local updateFunction = Update[varName];
                    if updateFunction then
                        updateFunction(state.Combos[varName][index]);
                    end
                end
            end
        end
        imgui.EndCombo();
    end
end

local function DrawMacroImage()
    local posY = imgui.GetCursorPosY();
    local layout = gInterface:GetLayout();
    local width = 32;
    local height = 32;
    if layout then
        width = layout.ImageObjects.Icon.Width;
        height = layout.ImageObjects.Icon.Height;
    end
    if (state.Texture ~= nil) then
        local posX = (253 - width) / 2;
        imgui.SetCursorPos({ posX, posY });
        imgui.Image(tonumber(ffi.cast("uint32_t", state.Texture)),
        { width, height },
        { 0, 0 }, { 1, 1 }, { 1, 1, 1, 1 }, { 0, 0, 0, 0 });
    end
    imgui.SetCursorPos({imgui.GetCursorPosX(), posY + height});
end

local function UpdateMacroImage()
    state.Texture = nil;
    if (state.MacroImage == nil) then
        return;
    end

    local paths = T{
        string.format('%sconfig//addons//%s//resources//%s', AshitaCore:GetInstallPath(), addon.name, state.MacroImage[1]),
        string.format('%saddons//%s//resources//%s', AshitaCore:GetInstallPath(), addon.name, state.MacroImage[1])
    };

    for _,path in ipairs(paths) do
        if ashita.fs.exists(path) then
            local dx_texture_ptr = ffi.new('IDirect3DTexture8*[1]');
            if (ffi.C.D3DXCreateTextureFromFileA(d3d8_device, path, dx_texture_ptr) == ffi.C.S_OK) then
                 state.Texture = d3d8.gc_safe_release(ffi.cast('IDirect3DTexture8*', dx_texture_ptr[0]));
                 break;
            end
        end
    end
end

Setup.Ability = function()
    state.ActionResources = T{};
    local resMgr = AshitaCore:GetResourceManager();
    local playMgr = AshitaCore:GetMemoryManager():GetPlayer();
    for i = 0x200,0x600 do
        local res = resMgr:GetAbilityById(i);
        if (res) and (playMgr:HasAbility(res.Id)) then
            state.ActionResources:append(res);
        end
    end

    table.sort(state.ActionResources, function(a,b)
        return a.Name[1] < b.Name[1];
    end);

    state.Combos.Action = T{};
    for _,res in ipairs(state.ActionResources) do
        state.Combos.Action:append(res.Name[1]);
    end

    state.Indices.Action = 1;
    Update.Action(state.Combos.Action[1]);
end

Setup.Command = function()
    state.Combos.Action = T{};
    state.Indices.Action = 0;
    Update.Command();
end

Setup.Empty = function()
    state.Combos.Action = T{};
    state.Indices.Action = 0;
    Update.Empty();
end

Setup.Item = function()
    state.ActionResources = T{};
    
    local resMgr = AshitaCore:GetResourceManager();
    local invMgr = AshitaCore:GetMemoryManager():GetInventory();
    local bags = T{0, 3};
    for _,bag in ipairs(bags) do
        local max = invMgr:GetContainerCountMax(bag);
        for i = 1,max do
            local item = invMgr:GetContainerItem(bag, i);
            if (item.Id ~= 0) and (item.Count ~= 0) then
                local res = resMgr:GetItemById(item.Id);
                if (bit.band(res.Flags, 0x200) == 0x200) then
                    state.ActionResources:append(res);
                end
            end
        end
    end

    for i = 0,15 do
        local equippedItem = invMgr:GetEquippedItem(i);
        if (equippedItem ~= nil) then
            local index = bit.band(equippedItem.Index, 0xFF);
            if (index ~= 0) then
                local container = bit.rshift(bit.band(equippedItem.Index, 0xFF00), 8);
                local item = invMgr:GetContainerItem(container, index);
                if (item.Id ~= 0) and (item.Count ~= 0) then
                    local res = resMgr:GetItemById(item.Id);
                    if (bit.band(res.Flags, 0x400) == 0x400) then
                        state.ActionResources:append(res);
                    end
                end
            end
        end
    end

    table.sort(state.ActionResources, function(a,b)
        return a.Name[1] < b.Name[1];
    end);

    state.Combos.Action = T{};
    for index,res in ipairs(state.ActionResources) do
        local prev = state.ActionResources[index - 1];
        local next = state.ActionResources[index + 1];

        --Show item id if multiple matching items..
        if (prev) and (prev.Name[1] == res.Name[1]) then
            state.Combos.Action:append(string.format('%s[%u]', res.Name[1], res.Id));            
        elseif (next) and (next.Name[1] == res.Name[1]) then
            state.Combos.Action:append(string.format('%s[%u]', res.Name[1], res.Id));
        else
            state.Combos.Action:append(res.Name[1]);
        end
    end

    state.Indices.Action = 1;
    Update.Action(state.Combos.Action[1]);
end

Setup.Spell = function()
    state.ActionResources = T{};
    local resMgr = AshitaCore:GetResourceManager();
    local playMgr = AshitaCore:GetMemoryManager():GetPlayer();
    local mainJob = playMgr:GetMainJob();
    local mainJobLevel = playMgr:GetMainJobLevel();
    local subJob = playMgr:GetSubJob();
    local subJobLevel = playMgr:GetSubJobLevel();

    for i = 1,0x400 do
        local res = resMgr:GetSpellById(i);
        if (res) and (playMgr:HasSpell(res.Index)) then
            local levelRequired = res.LevelRequired;
            --Maybe not best workaround, but trust are all usable at WAR1.
            if (levelRequired[2] ~= 1) then
                local hasSpell = false;
                local jpMask = res.JobPointMask;
                if (bit.band(bit.rshift(jpMask, mainJob), 1) == 1) then
                    if (mainJobLevel == 99) and (gPlayer:GetJobPointTotal(mainJob) >= levelRequired[mainJob + 1]) then
                        hasSpell = true;
                    end
                elseif (levelRequired[mainJob + 1] ~= -1) and (mainJobLevel >= levelRequired[mainJob + 1]) then
                    hasSpell = true;
                end

                if (bit.band(bit.rshift(jpMask, subJob), 1) == 0) then
                    if (levelRequired[subJob + 1] ~= -1) and (subJobLevel >= levelRequired[subJob + 1]) then
                        hasSpell = true;
                    end
                end

                if (hasSpell) then
                    state.ActionResources:append(res);
                end
            end
        end
    end

    table.sort(state.ActionResources, function(a,b)
        return a.Name[1] < b.Name[1];
    end);

    state.Combos.Action = T{};
    for _,res in ipairs(state.ActionResources) do
        state.Combos.Action:append(res.Name[1]);
    end

    state.Indices.Action = 1;
    Update.Action(state.Combos.Action[1]);
end

Setup.Trust = function()
    state.ActionResources = T{};
    local resMgr = AshitaCore:GetResourceManager();
    local playMgr = AshitaCore:GetMemoryManager():GetPlayer();
    local mainJob = playMgr:GetMainJob();
    local mainJobLevel = playMgr:GetMainJobLevel();
    local subJob = playMgr:GetSubJob();
    local subJobLevel = playMgr:GetSubJobLevel();

    for i = 1,0x400 do
        local res = resMgr:GetSpellById(i);
        if (res) and (playMgr:HasSpell(res.Index)) then
            local levelRequired = res.LevelRequired;

            --Maybe not best workaround, but trust are all usable at WAR1.
            if (levelRequired[2] == 1) then
                local hasSpell = false;
                local jpMask = res.JobPointMask;
                if (bit.band(bit.rshift(jpMask, mainJob), 1) == 1) then
                    if (mainJobLevel == 99) and (gPlayer:GetJobPointTotal(mainJob) >= levelRequired[mainJob + 1]) then
                        hasSpell = true;
                    end
                elseif (levelRequired[mainJob + 1] ~= -1) and (mainJobLevel >= levelRequired[mainJob + 1]) then
                    hasSpell = true;
                end

                if (bit.band(bit.rshift(jpMask, subJob), 1) == 0) then
                    if (levelRequired[subJob + 1] ~= -1) and (subJobLevel >= levelRequired[subJob + 1]) then
                        hasSpell = true;
                    end
                end

                if (hasSpell) then
                    state.ActionResources:append(res);
                end
            end
        end
    end

    table.sort(state.ActionResources, function(a,b)
        return a.Name[1] < b.Name[1];
    end);

    state.Combos.Action = T{};
    for _,res in ipairs(state.ActionResources) do
        state.Combos.Action:append(res.Name[1]);
    end

    state.Indices.Action = 1;
    Update.Action(state.Combos.Action[1]);
end

Setup.Weaponskill = function()
    state.ActionResources = T{};
    local resMgr = AshitaCore:GetResourceManager();
    local playMgr = AshitaCore:GetMemoryManager():GetPlayer();
    for i = 1,0x200 do
        local res = resMgr:GetAbilityById(i);
        if (res) and (playMgr:HasAbility(res.Id)) then
            state.ActionResources:append(res);
        end
    end

    table.sort(state.ActionResources, function(a,b)
        return a.Name[1] < b.Name[1];
    end);

    state.Combos.Action = T{};
    for _,res in ipairs(state.ActionResources) do
        state.Combos.Action:append(res.Name[1]);
    end

    state.Indices.Action = 1;
    Update.Action(state.Combos.Action[1]);
end

Update.Type = function(newValue)
    Setup[newValue]();
end

Update.Action = function(newValue)
    local type = state.Combos.Type[state.Indices.Type];
    if (state.Indices.Action > #state.ActionResources) then
        Update.Empty();
    else
        Update[type](state.Indices.Action);
    end
end

Update.Ability = function(index)
    local res = state.ActionResources[index];
    if (res.Targets == 1) then
        state.MacroText = { string.format('/ja \"%s\" <me>', res.Name[1]) };
    else
        state.MacroText = { string.format('/ja \"%s\" <t>', res.Name[1]) };
    end
    state.MacroLabel = { res.Name[1] };
    state.MacroImage = { string.format('abilities/%u.png', res.Id - 0x200) };
    UpdateMacroImage();
end

Update.Command = function(index)
    state.MacroText = { '/attack <t>' };
    state.MacroLabel = { 'Attack' };
    state.MacroImage = { 'misc/command.png' };
    UpdateMacroImage();
end

Update.Empty = function(index)
    state.MacroText = nil;
    state.MacroLabel = nil;
    state.MacroImage = { 'misc/empty.png' };
    UpdateMacroImage();
end

Update.Item = function(index)
    local res = state.ActionResources[index];
    if (res.Targets == 1) then
        state.MacroText = { string.format('/item \"%s\" <me>', res.Name[1]) };
    else
        state.MacroText = { string.format('/item \"%s\" <t>', res.Name[1]) };
    end
    state.MacroLabel = { res.Name[1] };
    state.MacroImage = { string.format('ITEM:%u', res.Id) };
    UpdateMacroImage();
end

Update.Spell = function(index)
    print(index);
    print(#state.ActionResources);
    local res = state.ActionResources[index];
    if (res.Targets == 1) then
        state.MacroText = { string.format('/ma \"%s\" <me>', res.Name[1]) };
    else
        state.MacroText = { string.format('/ma \"%s\" <t>', res.Name[1]) };
    end
    state.MacroLabel = { res.Name[1] };
    state.MacroImage = { string.format('spells/%u.png', res.Index) };
    UpdateMacroImage();
end

Update.Trust = function(index)
    local res = state.ActionResources[index];
    if (res.Targets == 1) then
        state.MacroText = { string.format('/ma \"%s\" <me>', res.Name[1]) };
    else
        state.MacroText = { string.format('/ma \"%s\" <t>', res.Name[1]) };
    end
    state.MacroLabel = { res.Name[1] };
    state.MacroImage = { string.format('spells/%u.png', res.Index) };
    UpdateMacroImage();
end

Update.Weaponskill = function(index)
    local res = state.ActionResources[index];
    if (res.Targets == 1) then
        state.MacroText = { string.format('/ws \"%s\" <me>', res.Name[1]) };
    else
        state.MacroText = { string.format('/ws \"%s\" <t>', res.Name[1]) };
    end
    state.MacroLabel = { res.Name[1] };
    state.MacroImage = { string.format('weaponskills/%u.png', res.Id) };
    UpdateMacroImage();
end

local exposed = {};

function exposed:Render()
    if (state.IsOpen[1]) then
        if (imgui.Begin(string.format('%s v%s Binding', addon.name, addon.version), state.IsOpen, ImGuiWindowFlags_AlwaysAutoResize)) then
            imgui.BeginGroup();
            if imgui.BeginTabBar('##TabBar', ImGuiTabBarFlags_NoCloseWIthMiddleMouseButton) then
                if imgui.BeginTabItem('Binding##BindingTab', nil) then
                    imgui.BeginChild('BindingChild', { 253, 345 }, true);
                    imgui.TextColored(header, 'Hotkey');
                    imgui.Text('^1');
                    ComboBox('Scope', 'Scope');
                    imgui.ShowHelp('Determines how wide the binding will apply.  Job binds are used to fill empty slots in palette binds, then global binds are used to fill any remaining empty slots.');
                    ComboBox('Action Type', 'Type');
                    if (#state.Combos.Action > 0) then
                        ComboBox('Action', 'Action');
                    else
                        imgui.TextColored(header, 'Action');
                        imgui.Text('N/A');
                    end
                    imgui.TextColored(header, 'Macro');
                    if (state.MacroText == nil) then
                        imgui.Text('N/A');
                    else
                        imgui.InputTextMultiline('##MacroText', state.MacroText, 4096, { 237, 116  });
                    end
                    imgui.TextColored(header, 'Label');
                    if (state.MacroLabel ~= nil) then
                        imgui.InputText('##MacroLabel', state.MacroLabel, 32);
                    else
                        imgui.Text('N/A');
                    end
                    imgui.EndChild();
                    imgui.EndTabItem();
                end
                if imgui.BeginTabItem('Appearance##AppearanceTab', nil) then
                    local layout = gInterface:GetLayout();
                    local width = 32;
                    local height = 32;
                    if layout then
                        width = layout.ImageObjects.Icon.Width;
                        height = layout.ImageObjects.Icon.Height;
                    end
                    imgui.BeginChild('AppearanceChild', { 253, 165 + height }, true);
                    imgui.TextColored(header, 'Image');
                    imgui.ShowHelp('While the image file and size are correct, rendering here is done with ImGui instead of GdiPlus and may vary slightly in appearance.');
                    local posY = imgui.GetCursorPosY();
                    if (state.Texture ~= nil) then
                        imgui.Image(tonumber(ffi.cast("uint32_t", state.Texture)),
                        { width, height },
                        { 0, 0 }, { 1, 1 }, { 1, 1, 1, 1 }, { 0, 0, 0, 0 });
                    end
                    imgui.SetCursorPos({imgui.GetCursorPosX(), posY + height});
                    imgui.InputText('##MacroImage', state.MacroImage, 256);
                    imgui.SameLine();
                    if (imgui.Button('Update', { 60, 0 })) then
                        UpdateMacroImage();
                    end
                    imgui.TextColored(header, 'Components');
                    imgui.BeginGroup();
                    CheckBox('Cost');
                    imgui.ShowHelp('Display action cost indicators.');
                    CheckBox('Cross');
                    imgui.ShowHelp('Displays a X over actions you don\'t currently know.');
                    CheckBox('Fade');
                    imgui.ShowHelp('Fades the icon for actions where cooldown is not 0 or cost is not met.');
                    CheckBox('Recast');
                    imgui.ShowHelp('Shows action recast timers.');                
                    imgui.EndGroup();
                    imgui.SameLine();
                    imgui.BeginGroup();
                    CheckBox('Name');
                    imgui.ShowHelp('Shows action names.');
                    CheckBox('Trigger');
                    imgui.ShowHelp('Shows an overlay when you activate an action.');
                    CheckBox('SC Icon');
                    imgui.ShowHelp('Overrides weaponskill icons when a skillchain would be formed.');
                    CheckBox('SC Animation');
                    imgui.ShowHelp('Animates a border around weaponskill icons when a skillchain would be formed.');
                    imgui.EndGroup();
                    imgui.EndChild();
                    imgui.EndTabItem();
                end
                imgui.EndTabBar();
            end
            imgui.EndGroup();

            if imgui.Button('Cancel', { 60, 0 }) then
                state.IsOpen[1] = false;
            end
            imgui.SameLine();
            imgui.SetCursorPos( { 202, imgui.GetCursorPosY() });
            if imgui.Button('Bind', { 60, 0 }) then
                
            end
            imgui.End();
        end
    end
end

function exposed:Show()
    state = {
        IsOpen = { true },
        ActionResources = T{},
        Combos = {
            ['Scope'] = T{ 'Global', 'Job', 'Palette' },
            ['Type'] = T{ 'Ability', 'Command', 'Empty', 'Item', 'Spell', 'Trust', 'Weaponskill' },
            ['Action'] = T{ },
        },
        Components = {
            Cost = true,
            Cross = true,
            Fade = true,
            Recast = true,
            Name = true,
            Trigger = true,
            ['SC Icon'] = true,
            ['SC Animation'] = true,
        },
        Indices = {
            ['Scope'] = 3,
            ['Type'] = 1,
        },
        MacroText = { '' },
        MacroLabel = { '' },
    };
    Setup.Ability();
end

return exposed;