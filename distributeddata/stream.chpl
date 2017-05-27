config const problem_size = 1000,
             alpha = 1.5,
             bval = 2.0,
             cval = 3.0;
  
use BlockDist;

proc main() {
  const ProblemSpace: domain(1) dmapped Block(boundingBox={1..problem_size}) = {1..problem_size};

  var A, B, C: [ProblemSpace] real;
  
  A = 0.0;
  B = bval;
  C = cval;
  
  forall (a, b, c) in zip(A, B, C) do
     a = b + alpha * c;

  var (maxVal, maxLoc) = maxloc reduce zip(A, A.domain);
  var (minVal, minLoc) = minloc reduce zip(A, A.domain);
  
  writeln("The maximum value in A is: A", maxLoc, " = ", maxVal);
  writeln("The minimum value in A is: A", minLoc, " = ", minVal);
  writeln("The difference is: ", maxVal - minVal);
  writeln("Values should be ", bval+alpha*cval);
}
