classdef InterceptionApp < matlab.apps.AppBase
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        UAVAxes             matlab.ui.control.UIAxes
        LoadButton          matlab.ui.control.Button
        StartButton         matlab.ui.control.Button
        SpeedLabel          matlab.ui.control.Label
        TimeLabel           matlab.ui.control.Label
        DistanceLabel       matlab.ui.control.Label
        StatusLabel         matlab.ui.control.Label
    end

    properties (Access = private)
        UAVData            UAVdata
        Planner            PathPlanner
        InterceptorObj     Interceptor
        IsSimRunning = false
        TimerObj           timer
        SimulationTime = 0
        SimulationDT = 0.1; % Explicit dt definition
    end

    methods (Access = private)
        function setupComponents(app)
            app.UIFigure = uifigure('Name', 'UAV Interception Simulation', 'Position', [100 100 1200 800]);
            
            app.UAVAxes = uiaxes(app.UIFigure, 'Position', [50 150 900 600], ...
                'Box', 'on', 'GridLineStyle', '--', 'Projection', 'perspective');
            xlabel(app.UAVAxes, 'X (m)'); ylabel(app.UAVAxes, 'Y (m)'); zlabel(app.UAVAxes, 'Altitude (m)');
            title(app.UAVAxes, '3D Interception Simulation'); grid(app.UAVAxes, 'on');
            
            app.LoadButton = uibutton(app.UIFigure, 'push', 'Position', [1000 700 150 30], ...
                'Text', 'Load UAV Data', 'ButtonPushedFcn', @(src,event) app.loadButtonPushed());
            
            app.StartButton = uibutton(app.UIFigure, 'push', 'Position', [1000 650 150 30], ...
                'Text', 'Start Simulation', 'Enable', 'off', 'ButtonPushedFcn', @(src,event) app.startButtonPushed());
            
            app.SpeedLabel = uilabel(app.UIFigure, 'Position', [1000 600 200 30], 'Text', 'Speed: 0 m/s');
            app.TimeLabel = uilabel(app.UIFigure, 'Position', [1000 550 200 30], 'Text', 'Time: 0 s');
            app.DistanceLabel = uilabel(app.UIFigure, 'Position', [1000 500 200 30], 'Text', 'Distance: 0 m');
            app.StatusLabel = uilabel(app.UIFigure, 'Position', [1000 450 200 30], 'Text', 'Status: Ready', 'FontColor', [1 0 0]);
        end

        function updatePlot(app)
    cla(app.UAVAxes);
    [x, y, z] = app.UAVData.getData();
    
    % Plot UAV Path
    pathPlot = plot3(app.UAVAxes, x, y, z, 'b-', 'LineWidth', 1.5, 'DisplayName', 'UAV Path');
    hold(app.UAVAxes, 'on');
    
    try
        [uav_x, uav_y, uav_z] = app.Planner.interpolate(app.SimulationTime);
        currentUAVPlot = plot3(app.UAVAxes, uav_x, uav_y, uav_z, 'go', 'MarkerSize', 8, 'DisplayName', 'Current UAV');
    catch
        currentUAVPlot = [];
    end
    
    if ~isempty(app.InterceptorObj)
        interceptor_pos = app.InterceptorObj.position;
        interceptorPlot = plot3(app.UAVAxes, interceptor_pos(1), interceptor_pos(2), interceptor_pos(3), 'r*', 'MarkerSize', 12, 'DisplayName', 'Interceptor');
    else
        interceptorPlot = [];
    end
    
    % Only update the legend if all plots are available
    if ~isempty(pathPlot) && ~isempty(currentUAVPlot) && ~isempty(interceptorPlot)
        legend(app.UAVAxes, [pathPlot, currentUAVPlot, interceptorPlot], 'Location', 'northeast');
    elseif ~isempty(pathPlot) && ~isempty(currentUAVPlot)
        legend(app.UAVAxes, [pathPlot, currentUAVPlot], 'Location', 'northeast');
    elseif ~isempty(pathPlot)
        legend(app.UAVAxes, pathPlot, 'Location', 'northeast');
    end
    
    view(app.UAVAxes, 3); axis(app.UAVAxes, 'equal');
    drawnow;
end

        function updateSimulation(app)
            if app.IsSimRunning && isvalid(app.UIFigure)
                try
                    % Get current simulation time
                    current_time = app.SimulationTime;
                    
                    % Check if within valid time range
                    if current_time > max(app.Planner.t)
                        app.stopSimulation();
                        return;
                    end
                    
                    % Get UAV state
                    [uav_x, uav_y, uav_z, uav_vx, uav_vy, uav_vz] = ...
                        app.Planner.interpolate(current_time);
                    
                    % Update interceptor
                    app.InterceptorObj = app.InterceptorObj.update(... 
                        [uav_x, uav_y, uav_z], [uav_vx, uav_vy, uav_vz]);
                    
                    % Update display
                    app.SimulationTime = current_time + 0.1;
                    app.updatePlot();
                    
                    % Calculate metrics
                    interceptor_pos = app.InterceptorObj.position;
                    target_pos = [uav_x, uav_y, uav_z];
                    distance = norm(target_pos - interceptor_pos');
                    speed = norm(app.InterceptorObj.velocity);
                    
                    % Update UI
                    app.SpeedLabel.Text = sprintf('Speed: %.1f m/s', speed);
                    app.TimeLabel.Text = sprintf('Time: %.1f s', current_time);
                    app.DistanceLabel.Text = sprintf('Distance: %.1f m', distance);
                    
                    % Auto-zoom to targets
                    all_x = [app.UAVData.cartesian(:,1); interceptor_pos(1)];
                    all_y = [app.UAVData.cartesian(:,2); interceptor_pos(2)];
                    all_z = [app.UAVData.cartesian(:,3); interceptor_pos(3)];
                    
                    xlim(app.UAVAxes, [min(all_x)-100, max(all_x)+100]);
                    ylim(app.UAVAxes, [min(all_y)-100, max(all_y)+100]);
                    zlim(app.UAVAxes, [min(all_z)-50, max(all_z)+50]);
                    
                catch ME
                    disp(['Simulation error: ' ME.message]);
                    app.stopSimulation();
                end
            end
        end

        function stopSimulation(app)
            app.IsSimRunning = false;
            app.StartButton.Text = 'Start';
            if ~isempty(app.TimerObj)
                stop(app.TimerObj);
                delete(app.TimerObj);
            end
        end
    end

    methods (Access = private)
        function loadButtonPushed(app)
            [file, path] = uigetfile('*.csv');
            if file
                try
                    app.UAVData = UAVdata(fullfile(path, file));
                    app.UAVData = app.UAVData.readData();
                    
                    % Get ALL 7 outputs including time
                    [x, y, z, vx, vy, vz, time] = app.UAVData.getData();
                    
                    % Pass all 7 arguments
                    app.Planner = PathPlanner(x, y, z, vx, vy, vz, time);
                    
                    % Initialize interceptor with explicit dt=0.1
                    start_pos = [x(1)-1000; y(1)-1000; z(1)+500];
                    initial_vel = [15; 15; 0];
                    app.InterceptorObj = Interceptor(start_pos, initial_vel, 5, 0.1);
                    
                    app.SimulationTime = 0;
                    app.StartButton.Enable = 'on';
                    app.StatusLabel.Text = 'Ready';
                    app.updatePlot();
                catch ME
                    errordlg(ME.message, 'Error');
                end
            end
        end

        function startButtonPushed(app)
            if ~app.IsSimRunning
                app.IsSimRunning = true;
                app.StartButton.Text = 'Stop';
                app.StatusLabel.Text = 'Running...';
                
                % Delete existing timer if any
                if ~isempty(app.TimerObj)
                    delete(app.TimerObj);
                end
                
                % Create new timer with proper configuration
                app.TimerObj = timer('ExecutionMode', 'fixedRate', 'Period', 0.05, 'TimerFcn', @(~,~) app.updateSimulation(), 'ErrorFcn', @(~,~) app.stopSimulation());
                
                start(app.TimerObj);
                drawnow;  % Force UI update
            else
                app.stopSimulation();
            end
        end
    end

    methods (Access = public)
        function app = InterceptionApp
            setupComponents(app);
        end
    end
        
        methods (Access = public)
     function delete(app)
        % Ensure the timer object exists and is valid before stopping it
        if ~isempty(app.TimerObj) && isvalid(app.TimerObj)
            stop(app.TimerObj);
            delete(app.TimerObj);
        end
     end
   end
end

