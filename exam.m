fprintf('   A        B        C  \n');
fprintf('⎯⎯⎯⎯⎯- + ⎯⎯⎯⎯⎯ + ⎯⎯⎯⎯⎯ = N\n');
fprintf(' B + C    A + C    A + B\n\n');

N = sym(input('? N = '));

if mod(N, 2) == 1 || N <= 0
    warning('Вашему числу быть чётным и положительным надобно.');
    return
end


solver = TaskSolver(N);

solver.curve.show();
[a, b, c] = solver.solve();

fprintf('A = %s\n', a);
fprintf('B = %s\n', b);
fprintf('C = %s\n', c);
