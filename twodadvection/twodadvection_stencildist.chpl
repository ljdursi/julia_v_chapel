use IO;
use StencilDist;

config var ntimesteps = 100,  // number of timesteps
           ngrid = 101,       // will be ngrid x ngrid mesh
           output = false,
           initialposx = 0.3,
           initialposy = 0.3,
           sigma = 0.15,
           cfl = 0.125,
           velx = 1.0,
           vely = 1.0;

proc output_csv(field, field_domain, filename) {
  var outfile  = open(filename, iomode.cw);
  var channel  = outfile.writer();
  channel.writef("#i, j, dens\n");
  for ij in field_domain {
    channel.writef("%i, %i, %r\n", ij(1), ij(2), field(ij));
  }
  channel.close();
  outfile.close();
}

proc main() {
  const nguard = 2;
  const ProblemSpace = {1..ngrid, 1..ngrid},
        ProblemDomain : domain(2) dmapped Stencil(boundingBox=ProblemSpace, fluff=(nguard,nguard), periodic=true) = ProblemSpace;

  const dx = 1.0/ngrid,
        dy = 1.0/ngrid,
        speed = sqrt(velx*velx+vely*vely),
        dt = cfl*min(dx, dy)/speed;

  var dens: [ProblemDomain] real = 0.0;  

  // density a gaussian of width sigma centred on (initialposx, initialposy)
  forall ij in ProblemSpace {
    var x = (ij(1)-1.0)/ngrid;
    var y = (ij(2)-1.0)/ngrid;
    dens(ij) = exp(-((x-initialposx)**2 + (y-initialposy)**2)/(sigma**2));
  } 

  if output {
    output_csv(dens, ProblemSpace, "init.csv");
  }

  var gradx, grady : [ProblemDomain] real = 0.0;
  for iteration in 1..ntimesteps  {
    // update the boundary conditions - periodic
    dens.updateFluff();

    // calculate the upwinded gradient
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

    // update the density with the gradient
    dens = dens - dt*(velx*gradx + vely*grady);

  }
  if output {
    output_csv(dens, ProblemSpace, "final.csv");
  }
}
