using SparseArrays, Graphs

function get_neighbours(indices)

    y, x = indices#Tuple(Indices)

    up = CartesianIndex(y+1, x)
    down = CartesianIndex(y-1, x)

    left = CartesianIndex(y, x-1)
    right = CartesianIndex(y, x+1)

    diag_up_left = CartesianIndex(x-1, y+1)
    diag_up_right = CartesianIndex(x+1, y+1)

    diag_down_left = CartesianIndex(x-1, y-1)
    diag_down_right = CartesianIndex(x+1, y-1)

    return up, down, left, right, diag_up_left, diag_up_right, diag_down_left, diag_down_right
end

function get_generic_neighbours()

    up = (+1, 0)
    down = (-1, 0)

    left = (0, -1)
    right = (0, +1)

    diag_up_left = (-1, +1)
    diag_up_right = (+1, +1)

    diag_down_left = (-1, -1)
    diag_down_right = (+1, -1)

    return up, down, left, right, diag_up_left, diag_up_right, diag_down_left, diag_down_right
end

const pipes = Dict("|" => [(-1, 0), (+1, 0)], "-" => [(0, -1), (0, +1)],
                    "L" => [(-1, 0), (0, +1)], "J" => [(-1, 0), (0, -1)],
                    "7" => [(+1, 0), (0, -1)], "F" => [(+1, 0), (0, +1)],
                    "." => [(0, 0), (0, 0)], "S" => get_generic_neighbours())

function set_up_grid(filepath)

    grid = []
    open(filepath) do infile
        for ln in eachline(infile)
            syms = split(ln, "")
            pushfirst!(syms, ".")
            push!(syms, ".")
            push!(grid, syms)
        end

    end

    pushfirst!(grid, fill(".", length(grid[1])))
    push!(grid, fill(".", length(grid[1])))
    grid = stack(grid, dims=1)
end

function set_up_adj_matrix(grid, S_position_pipe)

    adj_matrix = spzeros(Int, length(grid), length(grid))
    c_ids = CartesianIndices(grid)
    l_ids = LinearIndices(grid)
    

    for i in eachindex(grid)
        pipe = grid[i]

        if pipe == "S"
            pipe = S_position_pipe
        end

        connections = pipes[pipe]
        # adj_matrix[i,i] = 1
        for conn in connections
            neighbour = Tuple(c_ids[i]) .+ conn |> CartesianIndex
            if neighbour == c_ids[i]
                continue
            end
            
            l_id_neighbour = l_ids[neighbour]
            adj_matrix[i, l_id_neighbour] = 1
            # adj_matrix[l_id_neighbour, i] = 1
        end
    end

    
    return adj_matrix
end

function get_longest_distance(grid)
    possible_S_pipes = collect(keys(pipes))
    filter!(x -> x != "S", possible_S_pipes)
    
    starting_position = findfirst(grid .== "S")
    starting_position = LinearIndices(grid)[starting_position]
    @show starting_position
 
    local S_pipe
    for p in possible_S_pipes
        adj_mat = set_up_adj_matrix(grid, p)
        if adj_mat[starting_position,:] == adj_mat[:,starting_position]
            S_pipe = p
            break
        end
    end

    adj_mat = set_up_adj_matrix(grid, S_pipe)
    graph = SimpleDiGraph(adj_mat)
    pipes_to_S = findall(!iszero, adj_mat[:, starting_position])
    loops = yen_k_shortest_paths(graph, pipes_to_S[1], pipes_to_S[2], weights(graph), 100).paths
    
    longest_loop = loops[argmax([length(l) for l in loops])]
    # y = yen_k_shortest_paths(graph, starting_position)
    distances = [length(a_star(graph, starting_position, e)) for e in longest_loop]

    return maximum(distances)

    

end

function part1()

    grid = set_up_grid("input.txt")
    get_longest_distance(grid)

end