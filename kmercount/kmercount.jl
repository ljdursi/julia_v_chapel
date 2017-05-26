function kmer_count(infile::String, k::Int)
    sequences = read_sequences(infile)

    counts = Dict{String, Int8}()
    for seq in sequences
        for i = 1:length(seq)-k+1
            kmer = seq[i : i+k-1]
            if haskey(counts, kmer)
                counts[kmer] += 1
            else
                counts[kmer] = 1
            end
        end
    end 

    for kmer in eachindex(counts)
        println(kmer, ' ', counts[kmer])
    end
end

function read_sequences(input_filename::String)
    sequences = String[]
    inseq = false
    currentseq = [""]
    input = open(input_filename, "r")
    for line in eachline(input)
        if line[1] == '>'
            if inseq
                push!(sequences, join(currentseq))
                currentseq = [""]
            end
            inseq = false
        else
            inseq = true
            push!(currentseq, line)
        end
    end
    if inseq
        push!(sequences, join(currentseq))
    end
    return sequences
end

input_filename = "input.fa"
k = 11
nargs = length(ARGS)
if nargs > 0
    input_filename = ARGS[1]
end
if nargs > 1
    k = parse(Int8, ARGS[2])
end
kmer_count(input_filename, k)
