using SparseArrays, LinearAlgebra

function expand_universe(filepath, expansion=1)

    nx = length(readline(open(filepath)))       
    ny = countlines(open(filepath)) 

    rows = SparseVector{Int, Int}[]

    nx_new = nx
    ny_new = ny

    empty_rows = Int[]
    open(filepath) do infile
        row_counter = 1
        for ln in eachline(infile)
            tmp_row = Int[]
            if all(x -> x == '.', ln)
                push!(empty_rows, row_counter)
            end
            for char in eachsplit(ln, "")
                if char == "#"
                    push!(tmp_row, 1)
                else
                    push!(tmp_row, 0)
                end
            end
            push!(rows, tmp_row)
            row_counter += 1
        end
    end
    

    universe_small = sparse_hcat(rows...)'
    empty_cols = findall(x -> all(iszero, x), eachcol(universe_small)) |> sort
    sort!(empty_rows)
    nx_new = nx + expansion*length(empty_cols)
    ny_new = ny + expansion*length(empty_rows)

    galaxies = findall(isone, universe_small) .|> Tuple
    galaxies_new = Dict(g => g for g in galaxies)
    for row in empty_rows
        galaxies_after_row = [g for g in galaxies if g[1] > row]
        for gal in galaxies_after_row
            g = galaxies_new[gal]
            galaxies_new[gal] = (g[1]+expansion, g[2])
        end
    end

    for col in empty_cols
        galaxies_after_col = [g for g in galaxies if g[2] > col]
        for gal in galaxies_after_col
            g = galaxies_new[gal]
            galaxies_new[gal] = (g[1], g[2]+expansion)
        end
    end

    return collect(values(galaxies_new))
end

function get_distances2(galaxies)

    galaxy_ids = Dict(c => i for (i, c) in zip(eachindex(galaxies), galaxies))
    pair_paths = Dict{Tuple{Int, Int}, Int}()
    for galaxy in galaxies
        g_id = galaxy_ids[galaxy]
        for galaxy_pair in galaxies
            galaxy_pair == galaxy && continue

            g2_id = galaxy_ids[galaxy_pair]

            (haskey(pair_paths, (g_id, g2_id)) || haskey(pair_paths, (g2_id, g_id))) && continue

            rel_pos = galaxy_pair .- galaxy
            dist = abs(rel_pos[1]) + abs(rel_pos[2])
            pair_paths[(g_id, g2_id)] = dist
            
        end
    end

    sum(values(pair_paths))
end 

