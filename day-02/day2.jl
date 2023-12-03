

function read_games(input)

    games = Dict{Int, Dict}()
    open(input) do infile
        for ln in eachline(infile)
            game_number = parse(Int, strip(split(ln)[2], ':'))
            ln = replace(ln, "Game $game_number: " => "")
            rounds = split(ln, ";")
            round_dict = Dict{Int, Dict}()
            round_num = 1
            for round in rounds
                cubes = split(round, ",")
                choices = Dict{String, Int}()
                for cube in cubes
                    num, color = split(cube)
                    num = parse(Int, num)
                    choices[color] = num
                end
                round_dict[round_num] = choices
                round_num += 1
            end

            games[game_number] = round_dict
        end
    end

    return games

end

# only 12 red cubes, 13 green cubes, and 14 blue cubes
function check_possible_games(games, criteria = Dict("red" => 12, "green" => 13, "blue" => 14))

    possible_games = Int[]
    for (game, rounds) in games
        possible = true
        for (round, choices) in rounds
            for (color, num) in criteria
                if get(choices, color, 0) > num
                    possible = false
                    break
                end
            end
        end

        if possible
            push!(possible_games, game)
        end
    end

    return possible_games
end

function find_minimum_number_of_cubes(games)

    minimum_numbers = Dict{Int, Dict}()
    for (game, rounds) in games
        counter = Dict("red" => 0, "green" => 0, "blue" => 0)
        for (round, choices) in rounds
            for (color, num) in choices
                counter[color] = max(counter[color], num)
            end
        end

        # for (color, num) in counter
        #     if isinf(num)
        #         counter[color] = 0
        #     end
        # end

        minimum_numbers[game] = counter
    end

    return minimum_numbers  
end

function get_power(minimum_number_round)
    return prod(values(minimum_number_round))
end

function part1()
    answer = 8
    games = read_games("testcase.txt")
    possible_games = check_possible_games(games)

    mysum = sum(possible_games)
    @assert mysum == answer

    games = read_games("input.txt")
    possible_games = check_possible_games(games)

    println("Part 1: $(sum(possible_games))")

end

function part2()


    answer = 2286
    games = read_games("testcase.txt")
    minimum_numbers = find_minimum_number_of_cubes(games)

    powers = get_power.(values(minimum_numbers))
    mysum = sum(powers)
    @show mysum
    # @assert mysum == answer

    games = read_games("input.txt")
    minimum_numbers = find_minimum_number_of_cubes(games)

    powers = get_power.(values(minimum_numbers))
    mysum = sum(powers)

    println("Part 2: $mysum")
end