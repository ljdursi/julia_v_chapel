n = 500
B = rand(n, n)
x = rand(n)

A = x*x'
y = B*x

println(A[1,1])

A = eye(n)
y = A\x

println(sum(abs.(x-y)))
