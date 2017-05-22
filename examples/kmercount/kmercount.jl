import Base.isless

function update_counts(data::AbstractString, n::Int, counts::Dict{AbstractString, Int})
    top = length(data) - n + 1
    for i = 1:top
        s = data[i : i+n-1]
        if haskey(counts, s)
            counts[s] += 1
        else
            counts[s] = 1
        end
    end
    counts
end

function kmer_count(infile::String, k::Int)
	sequences = read_sequences(infile)

	counts = Dict{AbstractString, Int}()
	for seq in sequences
		counts = update_counts(seq, k, counts)
	end 

	for kmer in eachindex(counts)
		println(kmer, ' ', counts[kmer])
	end
end

function read_sequences(input_filename::String)
	sequences = String[]
	inseq = false
	currentseq = ""
    input = open(input_filename, "r")
    for line in eachline(input)
        if line[1] == '>'
			if inseq
				push!(sequences, currentseq)
				currentseq = ""
			end
			inseq = false
        else
        	inseq = true
        	currentseq = string(currentseq, line)
        end
    end
    if inseq
		push!(sequences, currentseq)
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
	k = atoi(ARGS[2])
end

kmer_count(input_filename, k)
