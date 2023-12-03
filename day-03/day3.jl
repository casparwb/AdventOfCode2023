# add up all the part numbers

function get_line_numbers(line, num_ids)
    line_numbers = Int[]
    line_indices = Tuple[]
    if isempty(num_ids) 
        return line_numbers, line_indices
    end
    prev_idx = first(num_ids)

    tmp_num = Char[line[prev_idx]]
    tmp_ids = Int[prev_idx]
    push!(num_ids, num_ids[end]+1)
    for num in num_ids[2:end]
        if num != prev_idx + 1 || num == last(num_ids)
            push!(line_numbers, parse(Int, join(tmp_num)))
            push!(line_indices, tuple(tmp_ids...))

            tmp_ids = Int[]
            tmp_num = Char[]
        end

        if num == last(num_ids)
            break
        end

        push!(tmp_num, line[num])
        push!(tmp_ids, num)
        prev_idx = num
    end

    return line_numbers, line_indices
end

function get_part_numbers(filepath)

    lines = readlines(filepath)

    pushfirst!(lines, join(fill(".", length(lines))))
    push!(lines,  join(fill(".", length(lines))))

    part_numbers = Int[]
    for i in eachindex(lines)[2:end-1]
        prev_line = lines[i-1]
        line = lines[i]
        next_line = lines[i+1]

        num_ids = findall(isdigit, line)
        isempty(num_ids) && continue
        symbols_in_line = findall(x -> !isdigit(x) && x != '.', line)
        symbols_in_prev_line = findall(x -> !isdigit(x) && x != '.', prev_line)
        symbols_in_next_line = findall(x -> !isdigit(x) && x != '.', next_line)

        line_numbers, line_indices = get_line_numbers(line, num_ids)

        for (num, pos) in zip(line_numbers, line_indices)
            i1, iend = (pos[1], pos[end])
            pos_with_diag = (pos[1] - 1, pos..., pos[end] + 1)
            part_number = false
            if any(symbols_in_line .== i1 - 1) || any(symbols_in_line .== iend + 1)
                part_number = true
            elseif any(x -> x in symbols_in_prev_line, pos_with_diag) || any(x -> x in symbols_in_next_line, pos_with_diag)
                part_number = true
            end

            if part_number
                push!(part_numbers, num)
            end
        end

    end

    return part_numbers
end

function get_gears(filepath)

    lines = readlines(filepath)

    pushfirst!(lines, join(fill(".", length(lines))))
    push!(lines,  join(fill(".", length(lines))))

    gear_numbers = Int[]
    for i in eachindex(lines)[2:end-1]
        prev_line = lines[i-1]
        line = lines[i]
        next_line = lines[i+1]

        num_ids = findall(isdigit, line)

        star_ids = findall(x -> x == '*', line)
        isempty(star_ids) && continue

        prev_line_stuff = get_line_numbers(prev_line, findall(isdigit, prev_line))
        line_stuff = get_line_numbers(line, num_ids)
        next_line_stuff = get_line_numbers(next_line, findall(isdigit, next_line))
        lines_stuff = [prev_line_stuff, line_stuff, next_line_stuff]

        for star_pos in star_ids
            gear_num = Int[]

            for line_stuff in lines_stuff
                line_numbers, line_indices = line_stuff
                for (num, pos) in zip(line_numbers, line_indices)
                    pos_with_diag = (pos[1] - 1, pos..., pos[end] + 1)
                    if any(x -> x in star_pos, pos_with_diag)
                        push!(gear_num, num)
                    end
                end
            end

            if length(gear_num) == 2
                push!(gear_numbers, prod(gear_num))
            end
        end

    end

    return gear_numbers
end

function main()

    answer_part_1 = 4361
    answer_part_2 = 467835

    @assert answer_part_1 == sum(get_part_numbers("testcase.txt"))
    @assert answer_part_2 == sum(get_gears("testcase.txt"))

    println("Part 1: ", sum(get_part_numbers("input.txt")))
    println("Part 2: ", sum(get_gears("input.txt")))
end