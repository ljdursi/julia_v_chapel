config var ntimesteps = 100,  // number of timesteps
           ngrid = 101,       // will be ngrid x ngrid mesh
           output = false,
           initialposx = 0.3,
           initialposy = 0.3,
           sigma = 0.15,
           velx = 1.,
           vely = 1.;

proc main() {
  const ProblemSpace = {1..ngrid, 1..ngrid} dmapped Block(),    // domain for grid points
        BigDomain = {0..ngrid+1, 0..ngrid+1} dmapped Block();   // domain including boundary points
        SmallDomain = {2..ngrid-1, 2..ngrid-1} dmapped Block(); // interior of domain

  var dens: [BigDomain] real = 0.0;  

  // density a gaussian of width sigma centred on (initialposx, initialposy)
  forall i,j in ProblemSpace {
      var x = (i-1.)/ngrid;
      var y = (j-1.)/ngrid;
      dens(i,j) = exp(-((x-initialposx)**2 + (y-initialposy)**2)/(sigma**2))
  } 

  var iteration = 0;

  for iter in 1..ntimesteps 
    // update the boundary conditions - periodic
    for i in 1..ngrid {
        dens(i,0)       = dens(i,ngrid)
        dens(i,ngrid+1) = dens(i,1)
    }
    for j in j..ngrid {
        dens(0,j)       = dens(ngrid,j)
        dens(ngrid+1,j) = dens(1,j)
    }

    // calculate the upwinded gradient
    var gradx, grady : [SmallDomain] real = 0.0;

    forall ij in SmallDomain {
        if velx > 0. {
            gradx(ij) = (3.*dens(ij) - 4.*dens(ij-(1,0)) + dens(ij-(2,0)))/(2.*dx)
        } else {
            gradx(ij) = (-dens(ij+(2,0)) + 4.*dens(ij+(1,0)) - 3.*dens(ij))/(2.*dx)
        }

        if vely > 0. {
            grady(ij) = (3.*dens(ij) - 4.*dens(ij-(0,1)) + dens(ij-(0,2)))/(2.*dx)
        } else {
            grady(ij) = (-dens(ij+(0,2)) + 4.*dens(ij+(0,1)) - 3.*dens(ij))/(2.*dx)
        }
    }

    forall ij in ProblemSpace {
        dens(ij) = dens(ij) - dt*(u(0)*gradx(ij) + u(1)*grady(ij))
    }
  } 
}
