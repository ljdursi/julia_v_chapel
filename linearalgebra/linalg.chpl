use LinearAlgebra;
use LAPACK;
use Random;

config const n=500;

var A = Matrix(n, n),
    B = Matrix(n, n),
    x, y = Vector(n);

fillRandom(B);
fillRandom(x);

y = dot(B, x);
A = outer(x, y);

writeln(A[1,1]);

var X = Matrix(n,1);
var Y = Matrix(n,1);
X({1..n},1) = x({1..n});

A = eye(n);
var ipiv : [1..n] c_int;
Y = X;
var info = gesv(lapack_memory_order.row_major, A, ipiv, Y);

var res = + reduce abs(x-y);


writeln("Total difference:", res);
