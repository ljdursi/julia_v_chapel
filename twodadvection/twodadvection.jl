using DistributedArrays
@everywhere importall DistributedArrays
using PyPlot

@everywhere function get_data_plus_gc(domain, nguard, ngrid)
    if myid() in procs(domain)
        li = localindexes(domain)        
        lp = localpart(domain)        

        s = size(lp)
        data_plus_gc = zeros(s[1]+2*nguard, s[2]+2*nguard)
        for j in 1:s[2]
            for i in 1:s[1]
                data_plus_gc[i+nguard, j+nguard] = lp[i,j]
            end
        end

        xstart = li[1][1]
        xend   = li[1][end]
        ystart = li[2][1]
        yend   = li[2][end]
        for g in 1:nguard
            xsg = (xstart-1-g + ngrid) % ngrid + 1
            xeg = (xend-1+g) % ngrid + 1

            ysg = (ystart-1-g + ngrid) % ngrid + 1
            yeg = (yend-1+g) % ngrid + 1

            for i in 1:s[1]
                data_plus_gc[i, g] = domain[i, yeg]
                data_plus_gc[i, s[2]+g] = domain[i, ysg]
            end
            for j in 1:s[2]
                data_plus_gc[g, j] = domain[xeg, j]
                data_plus_gc[s[1]+g, j] = domain[xsg, j]
            end
        end
    end
    return data_plus_gc
end

@everywhere function advect_data(dens, nguard, ngrid, velx, vely, dx, dy, dt)
    locdens = get_data_plus_gc(dens, nguard, ngrid)

    s = size(locdens)
    nx = s[1] - 2*nguard
    nx = s[2] - 2*nguard

    gradx = zeros(locdens)
    grady = zeros(locdens)

    for j in 1+nguard:ngrid+nguard
        for i in 1+nguard:ngrid+nguard
        
            if velx > 0
                gradx[i,j] = (3locdens[i,j] - 4locdens[i-1,j] + locdens[i-2,j])/(2dx)
            else
                gradx[i-2,j] = (-locdens[i,j] + 4locdens[i-1,j] - 3locdens[i-2,j])/(2dx)
            end

            if vely > 0
                grady[i,j] = (3locdens[i,j] - 4locdens[i,j-1] + locdens[i,j-1])/(2dy)
            else
                grady[i,j-2] = (-locdens[i,j] + 4locdens[i,j-1] - 3locdens[i,j-2])/(2dy)
            end
        end
    end

    for j in 1+nguard:ny+nguard
        for i in 1+nguard:nx+nguard
            locpart(dens)[i-nguard, j-nguard] -= dt*(velx*gradx[i,j] + vely*grady[i,j])
        end
    end
end

function initial_conditions(ngrid, dx, dy, posx, posy, sigma)
    dens = zeros(ngrid, ngrid)
    for j in 1:ngrid
        y = (j-1)*dy
        for i in 1:ngrid
            x = (i-1)*dx
            dens[i,j] = exp(-((x-posx)^2 + (y-posy)^2)/(sigma^2))
        end 
    end 
    distribute(dens)
end

function timestep(dens, nguard, ngrid, velx, vely, dx, dy, dt)
    ps = procs(dens)
    refs = [(@spawnat p advect_data(dens, nguard, ngrid, velx, vely, dx, dy, dt)) for p in ps]
    pmap(fetch, refs)
end

ngrid = 100
ntimesteps = 100
plot = true

nargs = length(ARGS)
if nargs > 0
    ngrid = parse(Int32, ARGS[1])
end
if nargs > 1
    ntimesteps = parse(Int32, ARGS[2])
end
if nargs > 2
    plot = parse(Bool, ARGS[2])
end

posx = 0.3
posy = 0.3
sigma = 0.15
dx = 1./ngrid
dy = 1./ngrid
dens = initial_conditions(ngrid, dx, dy, posx, posy, sigma)

if plot
   get_cmap("Blues")
   imshow(convert(Array, dens), cmap="Blues") 
end

velx = 1.0
vely = 1.0
velmag = sqrt(velx*velx + vely*vely)
cfl = 0.125
dt = cfl*min(dx, dy)/velmag

for t in 1:ntimesteps
    timestep(dens, 2, ngrid, velx, vely, dx, dy, dt)
end

if plot
   get_cmap("Blues")
   imshow(convert(Array, dens), cmap="Blues") 
end
