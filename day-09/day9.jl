
function create_sequences(filepath)

    sequences = Dict{Int, Vector{Vector{Int}}}()
    open(filepath) do infile
        for (i, ln) in enumerate(eachline(infile))
            history = parse.(Int, split(ln))
            current_sequence = history
            diffs = diff(current_sequence)
            sequences[i] = [current_sequence]
            while !(all(iszero, diffs))
                diffs = diff(current_sequence)
                current_sequence = diffs
                push!(sequences[i], current_sequence)
            end


        end
    end
    return sequences
end

function extrapolate_forwards!(sequences)

    n_lines = length(sequences)

    for i = 1:n_lines
        push!(sequences[i][end], 0)
        for k in reverse(eachindex(sequences[i]))[2:end]
            push!(sequences[i][k], sequences[i][k][end]+sequences[i][k+1][end])
        end
    end
    return sequences
end

function extrapolate_backwards!(sequences)

    n_lines = length(sequences)

    for i = 1:n_lines
        pushfirst!(sequences[i][end], 0)
        for k in reverse(eachindex(sequences[i]))[2:end]
            pushfirst!(sequences[i][k], sequences[i][k][1]-sequences[i][k+1][1])
        end
    end
    return sequences
end

function part1()

    sequences = create_sequences("input.txt")
    extrapolate_forwards!(sequences)

    val = sum(v[1][end] for (k, v) in sequences)

end

function part2()

    sequences = create_sequences("input.txt")
    extrapolate_backwards!(sequences)

    val = sum(v[1][1] for (k, v) in sequences)

end