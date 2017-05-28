use LinearAlgebra;
use Random;

var A = Matrix(500, 500),
    B = Matrix(500, 500),
	x, y = Vector(500);

fillRandom(B);
fillRandom(x);

y = dot(B, x);
A = outer(x, y);

writeln(A[1,1]);
