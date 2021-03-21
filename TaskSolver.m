classdef TaskSolver
    properties (SetAccess = private)
        value
    end
    
    properties
        curve
    end

    methods (Access = private)
        function [a, b, c] = find_abc(this, px, py)
            a_num = 8 * (this.value + 3) - px + py;
            b_num = 8 * (this.value + 3) - px - py;
            c_num = -4 * (this.value + 3) - (this.value + 2) * px;
            
            [a, b, c] = deal(a_num, b_num, 2 * c_num);
            
            [~, a_den] = numden(a);
            [~, b_den] = numden(b);
            [~, c_den] = numden(c);
            
            s = lcm(lcm(a_den, b_den), c_den);
            [a, b, c] = deal(a * s, b * s, c * s);
            
            g = gcd(gcd(a, b), c);
            [a, b, c] = deal(a / g, b / g, c / g);
        end

        function result = check_abc(this, a, b, c)
            if a <= 0 || b <= 0 || c <= 0
                result = false;
                return
            end
            
            left = a / (b + c) + b / (a + c) + c / (a + b);
            result = (left == this.value);
        end
        
        function curve = create_curve(this)
            a1 = sym(0);
            a2 = 4 * this.value * this.value + 12 * this.value - 3;
            a3 = sym(0);
            a4 = 32 * (this.value + 3);
            a6 = sym(0);

            curve = EllipticCurve(a1, a2, a3, a4, a6);
        end
    end

    methods
        function this = TaskSolver(value)
            this.value = value;
            this.curve = this.create_curve();
        end
        
        function [a, b, c] = solve(this)
            [gx, gy] = this.curve.find_gen();
            [px, py] = deal(0, 0);

            while true
                [px, py] = this.curve.add(px, py, gx, gy);
                [a, b, c] = this.find_abc(px, py);
                
                if this.check_abc(a, b, c)
                    return
                end
            end
        end
    end
end
