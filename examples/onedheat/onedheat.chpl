// 1d explicit heat equation

config var ntimesteps = 5000,            // number of timesteps
           ngrid = 1001,                 // number of gridpoints
           kappa = 1.0,                  // thermal diffusivity
           xleft = 0.0, xright = 1.0,    // boundary conditions
           tleft =-1.0, tright = 1.0;    // boundary conditions

proc main() {
  const dx = (xright-xleft)/(ngrid-1),   // spacing
        dt = 0.25 * dx * dx / kappa;     

  const ProblemSpace = {1..ngrid},       // domain for grid points
        BigDomain = {0..ngrid+1};        // domain including boundary points
  var T, TNew: [BigDomain] real = 0.0;   // declare arrays:

  var iteration = 0;                     // iteration counter
  T[0] = tleft;
  T[ngrid+1] = tright;

  const left = -1, right = 1;

  for iteration in 1..ntimesteps {
    forall i in ProblemSpace {
      TNew(i) = T(i) + kappa*dt/(dx*dx) * 
            (T(i+left) - 2*T(i) + T(i+right));
    }
    T[ProblemSpace] = TNew[ProblemSpace];
  } 

  writeln(T[ngrid/2]);
}
