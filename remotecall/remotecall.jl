@everywhere function whoami()
    println(myid(), gethostname())
end

remotecall_fetch(whoami, 2)
remotecall_fetch(whoami, 4)
