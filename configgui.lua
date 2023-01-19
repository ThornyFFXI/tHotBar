local header = { 1.0, 0.75, 0.55, 1.0 };
local state = {
    IsOpen = { false }
};

local function GetLayouts()
    local layouts = T{};
    local layoutPaths = T{
        string.format('%sconfig/addons/%s/resources/layouts/', AshitaCore:GetInstallPath(), addon.name),
        string.format('%saddons/%s/resources/layouts/', AshitaCore:GetInstallPath(), addon.name),
    };

    for _,path in ipairs(layoutPaths) do
        if not (ashita.fs.exists(path)) then
            ashita.fs.create_directory(path);
        end
        local contents = ashita.fs.get_directory(path, '.*\\.lua');
        for _,file in pairs(contents) do
            file = string.sub(file, 1, -5);
            if not layouts:contains(file) then
                layouts:append(file);
            end
        end
    end

    state.Layouts = layouts;
    state.SelectedLayout = -1;
    for index,layout in ipairs(state.Layouts) do
        if (gSettings.layout == layout) then
            state.SelectedLayout = index;
        end
    end
end

local function CheckBox(text, member)
    if (imgui.Checkbox(string.format('%s##Config_%s', text, text), { gSettings[member] })) then
        gSettings[member] = not gSettings[member];
        settings.save();
    end
end

local exposed = {};

function exposed:Render()
    if (state.IsOpen[1]) then
        imgui.SetNextWindowContentSize({ 253, 200 });
        if (imgui.Begin(string.format('%s v%s Configuration', addon.name, addon.version), state.IsOpen, ImGuiWindowFlags_AlwaysAutoResize)) then
            imgui.TextColored(header, 'Layout');
            if (imgui.BeginCombo('', state.Layouts[state.SelectedLayout], ImGuiComboFlags_None)) then
                for index,layout in ipairs(state.Layouts) do
                    if (imgui.Selectable(layout, index == state.SelectedLayout)) then
                        state.SelectedLayout = index;
                    end
                end
                imgui.EndCombo();
            end
            if (imgui.Button('Refresh')) then
                GetLayouts();
            end
            imgui.ShowHelp('Reloads available layouts from disk.', true);
            imgui.SameLine();
            if (imgui.Button('Apply')) then
                local layout = state.Layouts[state.SelectedLayout];
                if (layout == nil) then
                    if (state.IsOpen[1]) then
                        imgui.SetNextWindowContentSize({ 253, 200 });
                        if (imgui.Begin(string.format('%s v%s Configuration', addon.name, addon.version), state.IsOpen, ImGuiWindowFlags_AlwaysAutoResize)) then
                            imgui.TextColored(header, 'Layout');
                            if (imgui.BeginCombo('', state.Layouts[state.SelectedLayout], ImGuiComboFlags_None)) then
                                for index,layout in ipairs(state.Layouts) do
                                    if (imgui.Selectable(layout, index == state.SelectedLayout)) then
                                        state.SelectedLayout = index;
                                    end
                                end
                                imgui.EndCombo();
                            end
                            if (imgui.Button('Refresh')) then
                                GetLayouts();
                            end
                            imgui.ShowHelp('Reloads available layouts from disk.', true);
                            imgui.SameLine();
                            if (imgui.Button('Apply')) then
                                local layout = state.Layouts[state.SelectedLayout];
                                if (layout == nil) then
                                    print(chat.header(addon.name) .. chat.error('You must select a valid layout to apply it.'));
                                else
                                    gInterface:Initialize(layout);
                                end
                            end
                            imgui.ShowHelp('Applies the selected layout to your display.', true);
                            imgui.Text('');
                            imgui.TextColored(header, 'Components');
                            imgui.BeginGroup();
                            CheckBox('Cost', 'enableCost');
                            imgui.ShowHelp('Display action cost indicators.');
                            CheckBox('Cross', 'enableCross');
                            imgui.ShowHelp('Displays a X over actions you don\'t currently know.');
                            CheckBox('Fade', 'enableFade');
                            imgui.ShowHelp('Fades the icon for actions where cooldown is not 0 or cost is not met.');
                            CheckBox('Recast', 'enableRecast');
                            imgui.ShowHelp('Shows action recast timers.');                
                            imgui.EndGroup();
                            imgui.SameLine();
                            imgui.BeginGroup();
                            CheckBox('Name', 'enableName');
                            imgui.ShowHelp('Shows action names.');
                            CheckBox('Trigger', 'enableTrigger');
                            imgui.ShowHelp('Shows an overlay when you activate an action.');
                            CheckBox('SC Icon', 'enableSkillchainIcon');
                            imgui.ShowHelp('Overrides weaponskill icons when a skillchain would be formed.');
                            CheckBox('SC Animation', 'enableSkillchainAnimation');
                            imgui.ShowHelp('Animates a border around weaponskill icons when a skillchain would be formed.');
                            imgui.EndGroup();
                            imgui.End();
                        end
                    end
                    print(chat.header(addon.name) .. chat.error('You must select a valid layout to apply it.'));
                else
                    gInterface:Initialize(layout);
                end
            end
            imgui.ShowHelp('Applies the selected layout to your display.', true);
            imgui.Text('');
            imgui.TextColored(header, 'Components');
            imgui.BeginGroup();
            CheckBox('Cost', 'enableCost');
            imgui.ShowHelp('Display action cost indicators.');
            CheckBox('Cross', 'enableCross');
            imgui.ShowHelp('Displays a X over actions you don\'t currently know.');
            CheckBox('Fade', 'enableFade');
            imgui.ShowHelp('Fades the icon for actions where cooldown is not 0 or cost is not met.');
            CheckBox('Recast', 'enableRecast');
            imgui.ShowHelp('Shows action recast timers.');                
            imgui.EndGroup();
            imgui.SameLine();
            imgui.BeginGroup();
            CheckBox('Name', 'enableName');
            imgui.ShowHelp('Shows action names.');
            CheckBox('Trigger', 'enableTrigger');
            imgui.ShowHelp('Shows an overlay when you activate an action.');
            CheckBox('SC Icon', 'enableSkillchainIcon');
            imgui.ShowHelp('Overrides weaponskill icons when a skillchain would be formed.');
            CheckBox('SC Animation', 'enableSkillchainAnimation');
            imgui.ShowHelp('Animates a border around weaponskill icons when a skillchain would be formed.');                
            imgui.EndGroup();
            imgui.SameLine();
            imgui.End();
        end
    end
end

function exposed:Show()
    GetLayouts();
    state.IsOpen = { true };
end

return exposed;