use IO;

config var ntimesteps = 100,  // number of timesteps
           ngrid = 101,       // will be ngrid x ngrid mesh
           output = false,
           initialposx = 0.3,
           initialposy = 0.3,
           sigma = 0.15,
           cfl = 0.125,
           velx = 1.0,
           vely = 1.0;

proc periodic_bc(field, nguard, ngridx, ngridy) {
  for i in 1..ngridx {
    for g in 1..nguard {
      field(i, 1-g)      = field(i, ngridy+1-g);
      field(i, ngridy+g) = field(i, 1+g-1);
    } 
  }
  for j in 1..ngridy {
    for g in 1..nguard {
      field(1-g, j)      = field(ngridx+1-g, j);
      field(ngridx+g, j) = field(1+g-1, j);
    } 
  }
}

proc output_csv(field, field_domain, filename) {
  var outfile  = open(filename, iomode.cw);
  for ij in field_domain {
    outfile.writef("%i, %i, %g", ij(1), ij(2), field(ij));
  }
  outfile.close();
}

proc main() {
  const nguard = 2, start = 1-nguard, end = nguard+ngrid;
  const ProblemSpace = {1..ngrid, 1..ngrid}, BigSpace = {start..end, start..end},
        ProblemDomain : domain(2) dmapped Block(ProblemSpace) = ProblemSpace,
        BigDomain : domain(2) dmapped Block(BigSpace) = BigSpace;

  const dx = 1.0/ngrid,
        dy = 1.0/ngrid,
        speed = sqrt(velx*velx+vely*vely),
        dt = cfl*min(dx, dy)/speed;

  var dens: [BigDomain] real = 0.0;  

  // density a gaussian of width sigma centred on (initialposx, initialposy)
  forall ij in ProblemSpace {
    var x = (ij(1)-1.0)/ngrid;
    var y = (ij(2)-1.0)/ngrid;
    dens(ij) = exp(-((x-initialposx)**2 + (y-initialposy)**2)/(sigma**2));
  } 

  if output {
    output_csv(dens, ProblemSpace, "init.csv");
  }

  for iteration in 1..ntimesteps  {
    // update the boundary conditions - periodic
    periodic_bc(dens, nguard, ngrid, ngrid);

    // calculate the upwinded gradient
    var gradx, grady : [ProblemSpace] real = 0.0;

    forall ij in ProblemSpace {
      if velx > 0.0 {
        gradx(ij) = (3.0*dens(ij) - 4.0*dens(ij-(1,0)) + dens(ij-(2,0)))/(2*dx);
      } else {
        gradx(ij) = (-dens(ij+(2,0)) + 4.0*dens(ij+(1,0)) - 3.0*dens(ij))/(2*dx);
      }

      if vely > 0.0 {
        grady(ij) = (3*dens(ij) - 4*dens(ij-(0,1)) + dens(ij-(0,2)))/(2*dx);
      } else {
        grady(ij) = (-dens(ij+(0,2)) + 4*dens(ij+(0,1)) - 3*dens(ij))/(2*dx);
      }
    }
  }

  // update the density with the gradient
  forall ij in ProblemSpace {
      dens(ij) = dens(ij) - dt*(u(0)*gradx(ij) + u(1)*grady(ij));
  }

  if output {
    output_csv(dens, ProblemSpace, "final.csv");
  }
}
