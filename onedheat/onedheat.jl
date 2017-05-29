function main(ngrid, ntimesteps, kappa=1.0, xleft=0.0, xright=1.0, tleft=-1.0, tright=1.0)
  const dx = (xright-xleft)/(ngrid-1)
  const dt = 0.25dx * dx / kappa

  temp = Array{Float64}(ngrid+2) 
  temp_new = Array{Float64}(ngrid+2) 
  
  for i in 2:ngrid+1
    @inbounds temp[i] = 0.
  end

  temp[1] = tleft
  temp[ngrid+2] = tright

  for iteration in 1:ntimesteps
    for i in 2:ngrid+1
        @inbounds temp_new[i] = temp[i] + kappa*dt/(dx*dx)*(temp[i-1] - 2*temp[i] + temp[i+1])
    end
    for i in 2:ngrid+1
        @inbounds temp[i] = temp_new[i]
    end
  end

  println(temp[div(ngrid,2)+2])
end

ngrid = 1001
ntimesteps = 10000
nargs = length(ARGS)
if nargs > 0
    ngrid = parse(Int32, ARGS[1])
end
if nargs > 1
    ntimesteps = parse(Int32, ARGS[2])
end
main(10, 10)
@time main(ngrid, ntimesteps)
