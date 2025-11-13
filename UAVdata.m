classdef UAVdata
    properties
        filepath;
        ref_longitude;
        ref_latitude;
        ref_altitude;
        cartesian;
        velocity;
        time;
    end

    methods
        function obj= UAVdata(FilePath)
            obj.filepath= FilePath;
            obj.ref_longitude= [];
            obj.ref_latitude= [];
            obj.ref_altitude= [];
            obj.cartesian= [];
            obj.velocity=[];
            obj.time=[];
        end

        function obj= readData(obj)
            rawData=readmatrix(obj.filepath);
            
            if size(rawData,2) <4
                error('File not formated correctly!!!');
            end

           longitudes= rawData(:,1);
           latitudes= rawData(:,2);
           altitudes= rawData(:,3);
           obj.time=rawData(:,4);


           obj.ref_longitude= longitudes(1);
           obj.ref_latitude= latitudes(1);
           obj.ref_altitude= altitudes(1);

           %formula
           delta_longitude= longitudes-obj.ref_longitude;
           delta_latitude= latitudes-obj.ref_latitude;
           delta_altitude= altitudes-obj.ref_altitude;

           R=6378137; %earth radius

           x= deg2rad(delta_longitude)*R*cosd(obj.ref_latitude);
           y= deg2rad(delta_latitude)*R;
           z= delta_altitude;

           obj.cartesian= [x , y, z];

           dt=diff(obj.time);
           if any(dt<=0)
               error('Time must be monotonically increasing!');
           end
           vx=diff(x)./dt;
           vy=diff(y)./dt;
           vz=diff(z)./dt;

           vx=[vx; vx(end)];
           vy=[vy; vy(end)];
           vz=[vz; vz(end)];

           obj.velocity=[vx,vy,vz];

        end

        function [x,y,z,vx,vy,vz, time]= getData(obj)

            x=obj.cartesian(:,1);
            y=obj.cartesian(:,2);
            z=obj.cartesian(:,3);
            vx=obj.velocity(:,1);
            vy=obj.velocity(:,2);
            vz=obj.velocity(:,3);
            time=obj.time;
        end
    end
end






