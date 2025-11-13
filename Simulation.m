classdef Simulation
    properties
        UAV; 
        interceptor;
        planner;
        dt;
        t;
        fig;
        ax;
    end

    methods
        function obj = Simulation(UAV, planner, interceptor, dt, ax)
            obj.UAV = UAV;
            obj.planner = planner;
            obj.interceptor = interceptor;
            obj.dt = dt;
            obj.t = 0;
            obj.ax = ax;
        end
        
        function run(obj)
            
            time_end = max(obj.planner.t);  
            
            while obj.t < time_end
               
                [uav_x, uav_y, uav_z, uav_vx, uav_vy, uav_vz] = obj.planner.interpolate(obj.t);
                
               
                obj.interceptor = obj.interceptor.update([uav_x, uav_y, uav_z], [uav_vx, uav_vy, uav_vz]);

               
                obj.updatePlot();

               
                obj.t = obj.t + obj.dt;

              
                pause(obj.dt);
            end
        end

        function updatePlot(obj)
            
            cla(obj.ax);  
            plot3(obj.ax, obj.UAV.cartesian(:,1), obj.UAV.cartesian(:,2), obj.UAV.cartesian(:,3), 'b-', 'LineWidth', 2);  % Plot UAV's path
            hold(obj.ax, 'on');  

           
            scatter3(obj.ax, obj.interceptor.position(1), obj.interceptor.position(2), obj.interceptor.position(3), 100, 'r', 'filled');

           
            xlabel(obj.ax, 'X (m)');
            ylabel(obj.ax, 'Y (m)');
            zlabel(obj.ax, 'Altitude (m)');
            grid(obj.ax, 'on');
            drawnow; 
        end
    end
end
