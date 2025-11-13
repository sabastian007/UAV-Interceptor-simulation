classdef Interceptor
    properties 
        position;
        velocity;
        nav;
        dt;
        min_speed=20;
    end

    methods

        function obj= Interceptor(starting_pos, starting_vel, nav, dt)
            obj.position=starting_pos(:);
            obj.velocity=starting_vel(:);
            obj.nav=nav;
            obj.dt=dt;

            if norm(obj.velocity) < obj.min_speed
                if norm(obj.velocity) == 0
                   obj.velocity = obj.min_speed * [1; 0; 0];
            else
                obj.velocity = obj.min_speed * (obj.velocity / norm(obj.velocity));
            end
       end
        end

        function obj= update(obj, target_pos, target_vel)

            relative_pos= target_pos(:) -obj.position;
            relative_vel= target_vel(:) -obj.velocity;

            horizontal_distance=norm(relative_pos(1:2))+ 1e-6;
            los_azimuth= atan2(relative_pos(2), relative_pos(1));
            los_elevation=atan2(relative_pos(3),horizontal_distance);

            los_unit = relative_pos / norm(relative_pos);
            los_rate_vector = cross(los_unit, relative_vel) / norm(relative_pos);
            los_rate = norm(los_rate_vector);

            turn_rate=obj.nav*los_rate;
            new_heading= los_azimuth+turn_rate*obj.dt;

            speed=norm(obj.velocity);
            desired_speed = max(obj.min_speed, min(40, norm(relative_vel) + 5));

            obj.velocity= desired_speed*[cos(new_heading)*cos(los_elevation); sin(new_heading)*cos(los_elevation); sin(los_elevation)];

            obj.position= obj.position+ obj.velocity*obj.dt;
        end

        function [pos, vel] = getState(obj)
    
            pos = obj.position;
            vel = obj.velocity;
        end

    end
end
