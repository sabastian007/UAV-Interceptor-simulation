classdef PathPlanner
    properties
        coeff_x;
        coeff_y;
        coeff_z;
        coeff_vx;
        coeff_vy;
        coeff_vz;
        t;
    end

    methods
        function obj= PathPlanner(x,y,z, vx,vy,vz, time)
            x=x(:);
            y=y(:);
            z=z(:);
            vx=vx(:);
            vy=vy(:);
            vz=vz(:);
            time= time(:);

            
            dx= diff (x);
            dy= diff (y);
            dz= diff(z);
            obj.t= time;

            obj.coeff_x=obj.dospline(x);
            obj.coeff_y=obj.dospline(y);
            obj.coeff_z=obj.dospline(z);
            obj.coeff_vx=obj.dospline(vx);
            obj.coeff_vy=obj.dospline(vy);
            obj.coeff_vz=obj.dospline(vz);

        end
        
        function coeffs= dospline(obj, values)

            n= length(values);
            h= diff(obj.t);
            if any(h<=0)
               error('Time must me motionally increasing!');
           end

            daigonal_matrix= 2*(h(1:end-1) + h(2:end));
            upper=h(2:end-1); %eikahane bhul korte pari previously it was 1:end-2
            lower=h(1:end-2);
            rhs=6*((values(3:end)-values(2:end-1))./h(2:end)-(values(2:end-1)-values(1:end-2))./h(1:end-1));

            derivatives= obj.solvee(lower, daigonal_matrix, upper, rhs);
            derivatives= [0; derivatives; 0];

            coeffs=zeros(n-1,4);
                for i=1:n-1
                a=derivatives(i+1)/(6*h(i));
                b=derivatives(i)/(2);
                c=(values(i+1)-values(i))/h(i)-h(i)*(2*derivatives(i)+derivatives(i+1))/6;
                d=values(i);
                coeffs(i,:) = [a, b, c, d];
                end
        end

      function [x_interp, y_interp, z_interp, vx_interp, vy_interp, vz_interp]= interpolate(obj, t_query)

            funn= arrayfun(@(t) obj.findd(t), t_query);

            x_interp=obj.evaluate_spline(obj.coeff_x, funn, t_query);
            y_interp=obj.evaluate_spline(obj.coeff_y, funn, t_query);
            z_interp=obj.evaluate_spline(obj.coeff_z, funn, t_query);
            vx_interp=obj.evaluate_spline(obj.coeff_vx, funn, t_query);
            vy_interp=obj.evaluate_spline(obj.coeff_vy, funn, t_query);
            vz_interp=obj.evaluate_spline(obj.coeff_vz, funn, t_query);
        end

        function val= evaluate_spline(obj,coeffs,funn,t_query)

          dt= t_query-obj.t(funn);
          a=coeffs(funn,1);
          b=coeffs(funn,2);
          c=coeffs(funn,3);
          d=coeffs(funn,4);

          val= a.*dt.^3+ b.*dt.^2 +c.*dt +d;
        end

        function funn= findd(obj, t)
          
          funn= find(obj.t <= t, 1, 'last');
          funn= max(1, min(numel(obj.t)-1, funn));

        end
    end

    methods(Access=private)

    function x= solvee (obj, a,b,c,d)

    assert(length(b) == length(d), "Main diagonal and RHS size mismatch");
    assert(length(a) == length(c), "Lower/upper diagonal size mismatch");

    n=length(d);
    for i= 2:n

       w= a(i-1)/b(i-1);
       b(i)= b(i)-w*c(i-1);
       d(i)= d(i)-w*d(i-1);
    end

    x=zeros(n,1);
    x(n)=d(n)/b(n);

    for i=n-1:-1:1
        x(i)=(d(i)-c(i)*x(i+1))/b(i);
    end
    end
    end
end



    

    







 