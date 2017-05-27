using DistributedArrays
@everywhere importall DistributedArrays

@everywhere function dostreamcalc(alpha, bval, cval, A, B, C)
    for i in 1:length(localindexes(B)[1])
        localpart(B)[i] = bval
    end
    for i in 1:length(localindexes(C)[1])
        localpart(C)[i] = cval
    end

    for i in 1:length(localindexes(A)[1])
        localpart(A)[i] = localpart(B)[i] + alpha*localpart(C)[i]
    end
end

problem_size = 1000
alpha = 1.5
bval = 2.0
cval = 3.0

nargs = length(ARGS)
if nargs > 0
    problem_size = parse(Float32, ARGS[1])
end
if nargs > 1
    alpha = parse(Float32, ARGS[1])
end
if nargs > 2
    bval  = parse(Float32, ARGS[1])
end
if nargs > 3
    cval = parse(Float32, ARGS[1])
end

A = dzeros(problem_size)
B = copy(A)
C = copy(A)

ps = procs(A)
refs = [(@spawnat p dostreamcalc(alpha, bval, cval, A, B, C)) for p in ps]
pmap(fetch, refs)

result = convert(Array, A)
println("Max = ", maximum(result))
println("Min = ", minimum(result))
println("Should be = ", bval+alpha*cval)
