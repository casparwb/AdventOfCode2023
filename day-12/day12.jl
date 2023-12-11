

function get_condition_records(filepath)

    conditions = Vector{Int}[]
    groups = Vector{Int}[]
    open(filepath) do infile
        for ln in eachline(infile)
            cond_numeric = Int[]
            condition, group = split(ln)
            push!(groups, parse.(Int, split(group, ",")))

            for c in condition
                if c == '.'
                    push!(cond_numeric, 0)
                elseif c == '?'
                    push!(cond_numeric, 1)
                else
                    push!(cond_numeric, 2)
                end
            end
            push!(conditions, cond_numeric)
        end
    end
    return conditions, groups
end

function count_contigous_groups(record)

    groups = length.(split(record, "."))
    filter(!iszero, groups)

end