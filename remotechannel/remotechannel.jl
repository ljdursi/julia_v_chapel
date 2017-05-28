@everywhere function putmsg(pid)
    mypid = myid()
    msg = "Hi from $mypid"
    rr = RemoteChannel(pid)
    put!(rr, msg)
    println(myid(), " sent ", msg, " to ", pid)
    return rr
end

@everywhere function getmsg(rr)
    msg  = fetch(rr)
    println(myid(), " got: ", msg)
end

rr = remotecall_fetch(putmsg, 2, 3)
remotecall_wait(getmsg, 3, rr)
    
