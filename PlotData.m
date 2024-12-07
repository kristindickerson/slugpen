function [Checkboxes, TempPlots, BadSensors] = PlotData(figure_Main, H, DATA, panel_Thermistors)

%% Initialize Loading Dialog
loading = uiprogressdlg(figure_Main, 'Message', 'Plotting raw data...');
loading.Value = 0.6;

%% Extract Relevant Data
NoTherm = H.Fileinfo.No_Thermistors.Value;

Depth = DATA.Depth;
G = DATA.G;
Tilt = DATA.Tilt;
T = DATA.Traw;
Time = DATA.Time;
TempPlots=[];

%% Round Data
T = round(T, 3);

%% Enable Buttons and Set Text
H.Selections.Select.Enable = 'on';
H.Exe_Controls.Delete.Enable = 'on';

%% Generate Optimized Colormap
colormap(H.Axes.Raw, 'turbo');
CMap = flipud(colormap(H.Axes.Raw, 'turbo'));
CMap = interp1(1:256, CMap, 1:256 / (NoTherm - 1):256); 
colormap(H.Axes.Raw, CMap);
CMap = [CMap; [0 0 0]];

%% Create Handles for Plotting (One-time Plot Creation)
h_axRaw = gobjects(1, NoTherm);

for i = 1:NoTherm
    h_axRaw(i) = plot(H.Axes.Raw, Time, T(i,:), '*', 'markersize', 4, 'color', CMap(i,:));
    hold(H.Axes.Raw, 'on');
end

H.Plot_Controls.RawPlot.UserData = h_axRaw;

%% Use `set` for Updating Data Dynamically
% Dynamically set the data instead of creating new plots during zoom
for i = 1:NoTherm
    % Replace plot data with set, this avoids re-plotting and improves performance
    set(h_axRaw(i), 'YData', T(i,:));
end

%% Zoom Optimization Using `axis` and `set` for Data Limits
%zoomListener = addlistener(H.Axes.Raw, 'XLim', 'PostSet', @(src, evt) updatePlotLimits(src,h_axRaw));

%% Callback Function to Update Plot Limits Dynamically
function updatePlotLimits(src, ~, ~, h_axRaw, ~)
    % Get new axis limits after zoom
    xLimits = src.XLim;

    % Efficiently update data visibility without redrawing entire plot
    for i = 1:length(h_axRaw)
        % Update the data visibility based on the new zoom limits
        set(h_axRaw(i), 'XData', Time(Time >= xLimits(1) & Time <= xLimits(2)));
    end
end

%% Plot Depth and Acceleration Data (No Need for Frequent Updates)
h_axDep = plot(H.Axes.Depth, Time, -Depth, 'b');
h_axAcc = plot(H.Axes.Accel, Time, G, 'k', 'Visible', 'off');
h_axTilt = plot(H.Axes.Tilt, Time, Tilt, 'r');

%% Link Axes and Set Axis Properties
linkaxes([H.Axes.Raw, H.Axes.Depth, H.Axes.Accel, H.Axes.Tilt], 'x');
for ax = [H.Axes.Raw, H.Axes.Depth, H.Axes.Accel, H.Axes.Tilt]
    ax.XLimMode = 'auto';
    ax.XMinorTick = 'on';
    ax.XAxis.TickLabelFormat = 'HH:mm:ss';
    ax.XTickMode = 'auto';
end

%% Finalize Loading Box
loading.Message = 'Finishing...';
loading.Value = 0.9;

%% Create Sensor Checkbox Panels
Checkboxes = createSensorCheckboxes(NoTherm, panel_Thermistors, CMap, [], [], h_axRaw, [], H);

    function Checkboxes = createSensorCheckboxes(NoTherm, panel_Thermistors, CMap, h_axDec, h_axCln, h_axRaw, h_axRawDec, H)
            %% Plot sensor checkboxes
    %% ----------------------

            NumberOfSensors = NoTherm;
            
                % Grid layout for sensor panel
                % -----------------------------
                    
                    for i=NumberOfSensors:-1:1
                        ThermistorGrid = uigridlayout(panel_Thermistors, 'BackgroundColor', ...
                        [0.94 0.94 0.94], 'ColumnWidth', {'100x'}, 'RowHeight', cellstr(repmat('1x', NumberOfSensors, 1))');
                    end
            
            
                % Create panels for each sensor
                % ------------------------------
                    for i=NumberOfSensors:-1:1
                        SensorPanels{i} = uipanel(ThermistorGrid, 'BorderType', ...
                            'none', ...
                            'BackgroundColor', [0.94 0.94 0.94]);
                    end
            
            
                % Grid layout for each sensor
                % -----------------------------
                    for i=NumberOfSensors-1:-1:1
                        SensorGrids{i} = uigridlayout(SensorPanels{i}, 'ColumnWidth', ...
                            {'100x'}, 'RowHeight', {'100x'}, 'Padding',[0 0 0 0], ...
                            'BackgroundColor', CMap(i,:));
                    end
                    i = max(NumberOfSensors);
                    SensorGrids{i} = uigridlayout(SensorPanels{i}, 'ColumnWidth', ...
                            {'100x'}, 'RowHeight', {'100x'}, 'Padding',[0 0 0 0], ...
                            'BackgroundColor', 'k');
            
                % Checkbox for each sensor
                % -----------------------------
            
                  for i=NumberOfSensors:-1:1
                          Checkboxes{i} = uicheckbox(SensorGrids{i}, 'Text', ['T' num2str(i)],'FontSize', 14,'FontWeight', 'bold','FontColor',[1 1 1],...
                              'Value',true, 'Tooltip', ['Check to display data from sensor T' num2str(i) ' on plots'], ...
                              'tag',['c_b_' num2str(i)], 'ValueChangedFcn', {@cbSensValueChange, [], [], h_axRaw(i), [] ...
                              H.PlotCheckboxes.Filtered_check.Value, H.PlotCheckboxes.Filtereddec_check.Value, H.PlotCheckboxes.Raw_check.Value, ...
                              H.PlotCheckboxes.Rawdec_check.Value});
                  end
    end


%% Hide Data for Bad (NaN) Sensors
BadSensors = hideBadData(T, figure_Main, Checkboxes, [], [], h_axRaw, []);

%% Helper Function: Hide Data for Bad (NaN) Sensors
function BadSensors = hideBadData(T, figure_Main, Checkboxes, ~, ~, h_axRaw, ~)
    T(isnan(T)) = -999;
    BadSensors = find(all(T == -999, 2));
    if ~isempty(BadSensors)
        hidedata = uiconfirm(figure_Main, 'One or more sensors recorded no data (T = -999). Would you like to hide this data from the plot?', ...
                             'NaN Data Recorded', 'Options', {'Hide NaN (T = -999) data', 'Plot NaN (T = -999) data'});
        if strcmp(hidedata, 'Hide NaN (T = -999) data')
            for i = 1:length(BadSensors)
                Checkboxes{BadSensors(i)}.Visible = 'off';
                set(h_axRaw(BadSensors(i)), 'Visible', 'off');
            end
        end
    end
end

H.Axes.Accel.Visible='off';
close(loading);

end