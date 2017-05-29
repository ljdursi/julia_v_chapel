// 1d explicit heat equation
use Time;

config var ntimesteps = 10000,        // number of timesteps
           ngrid = 1001,              // number of gridpoints
           kappa : real(64) = 1.0,    // thermal diffusivity
           xleft : real(64) = 0.0, 
           xright: real(64) = 1.0,    // boundary conditions
           tleft : real(64) =-1.0, 
           tright: real(64) = 1.0;    // boundary conditions

proc calculation(dx, dt, kappa, ngrid, tleft, tright) {
  const ProblemSpace = {1..ngrid},         // domain for grid points
        BigDomain = {0..ngrid+1};          // domain including boundary points
  var T, TNew: [BigDomain] real(64) = 0.0; // declare arrays:

  var iteration = 0;                     // iteration counter
  T[0] = tleft;
  TNew[0] = tleft;
  T[ngrid+1] = tright;
  TNew[ngrid+1] = tright;

  const left = -1, right = 1;

  for iteration in 1..ntimesteps {
    for i in 1..ngrid {
      TNew(i) = T(i) + kappa*dt/(dx*dx) * 
            (T(i+left) - 2*T(i) + T(i+right));
    }
    TNew <=> T;
  } 

  return T[ngrid/2];
}

proc main() {
  const dx = (xright-xleft)/(ngrid-1),   // spacing
        dt = 0.25 * dx * dx / kappa;     

  var t:Timer;
  t.start();
  var temp = calculation(dx, dt, kappa, ngrid, tleft, tright);
  t.stop();
  writeln(t.elapsed());
  writeln(temp);
}
