classdef EllipticCurve
    properties (SetAccess = private)
        a1
        a2
        a3
        a4
        a6
    end

    methods
        function this = EllipticCurve(a1, a2, a3, a4, a6)
            this.a1 = a1;
            this.a2 = a2;
            this.a3 = a3;
            this.a4 = a4;
            this.a6 = a6;
        end

        function [rx, ry] = neg(this, x, y)
            if (x == 0) && (y == 0)
                rx = 0;
                ry = 0;
                return
            end

            rx = x;
            ry = -this.a1 * x - this.a3 - y;
        end

        function [rx, ry] = double(this, x, y)
            if (x == 0) && (y == 0)
                rx = 0;
                ry = 0;
                return
            end

            num = 3 * x * x + 2 * this.a2 * x - this.a1 * y + this.a4;
            den = 2 * y + this.a1 * x + this.a3;
            s = num / den;
            rx = s * s + s * this.a1 - this.a2 - 2 * x;
            ry = -this.a1 * rx - this.a3 - s * rx + s * x - y;
        end

        function [rx, ry] = add(this, x1, y1, x2, y2)
            if (x1 == 0) && (y1 == 0)
                rx = x2;
                ry = y2;
                return
            end

            if (x2 == 0) && (y2 == 0)
                rx = x1;
                ry = y1;
                return
            end

            if (x1 == x2) && (y1 == y2)
                [rx, ry] = this.double(x1, y1);
                return
            end

            [nx2, ny2] = this.neg(x2, y2);

            if (x1 == nx2) && (y1 == ny2)
                rx = 0;
                ry = 0;
                return
            end

            s = (y2 - y1) / (x2 - x1);
            rx = s * s + s * this.a1 - this.a2 - x1 - x2;
            ry = -this.a1 * rx - this.a3 - s * rx + s * x1 - y1;
        end

        function [rx, ry] = mul(this, x, y, n)
            rx = 0;
            ry = 0;
            tx = x;
            ty = y;

            while (n > 0)
                if mod(n, 2) == 1
                    [rx, ry] = this.add(rx, ry, tx, ty);
                end

                n = fix(n / 2);
                [tx, ty] = this.double(tx, ty);
            end
        end
        
        function [rx, ry] = lift_y(this, y)
            cx3 = 1;
            cx2 = this.a2;
            cx1 = this.a4 - this.a1 * y;
            cx0 = this.a6 - y * y - this.a3 * y;
            x_roots = roots([cx3, cx2, cx1, cx0]);
            rx = x_roots(1);
            ry = y;
        end

        function [gx, gy] = find_gen(this)
            i = sym(1);

            while true
                i = i + 1;
                [gx, gy] = this.lift_y(i);

                if isreal(gx) && mod(gx, 1) == 0 % проверяем что число целое
                    [rx, ry] = this.mul(gx, gy, 3);

                    if rx ~= 0 || ry ~= 0
                        return
                    end
                end
                
                if mod(i, 500) == 0
                    warning('Генератор генерируется дегенеративно...');
                end
            end
        end
        
        function show(this)
            interval = -1000: 1: 1000;
            [X, Y] = meshgrid(interval, interval);

            f = (Y .* Y + double(this.a1) .* X .* Y + double(this.a3) .* Y) - ...
                (X .* X .* X + double(this.a2) .* X .* X + double(this.a4) .* X + double(this.a6));
            
            name = sprintf('Y^2 + %s*X*Y + %s*Y = X^3 + %s*X^2 + %s*X + %s', ...
                           this.a1, this.a3, this.a2, this.a4, this.a6);

            contour(X, Y, f, 'LevelList', 0);
            title(name);
        end
    end
end
