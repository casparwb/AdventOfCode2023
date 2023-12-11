

function get_card_winning_numbers(filepath)

    winning_numbers_per_card = Dict{Int, Vector{Int}}()
    open(filepath) do infile
        for ln in eachline(infile)
            words = split(ln) .|> strip
            card_number = parse(Int, strip(words[2], ':'))
            divider_position = findall(words .== "|")[1]
            ticket_numbers = parse.(Int, words[3:divider_position-1])
            my_numbers = parse.(Int, words[divider_position+1:end])

            winners = Int[]
            for my_number in my_numbers
                if my_number in ticket_numbers
                    push!(winners, my_number)
                end
            end

            winning_numbers_per_card[card_number] = winners
        end

    end

    return winning_numbers_per_card
end 

function count_card_scores(winning_numbers)

    scores_per_card = Dict{Int, Int}()
    for (card, winners) in winning_numbers
        score = 0
        if isempty(winners)
            scores_per_card[card] = 0
            continue
        end

        score = 1
        for i in 2:length(winners)
            score *= 2
        end

        scores_per_card[card] = score
    end

    return scores_per_card
end

function get_original_winners(filepath)
    all_cards = Dict{Int, Tuple{Vector{Int}, Vector{Int}}}()
    # winning_cards = Dict{Int, Tuple{Vector{Int}, Vector{Int}}}()
    winning_card_counter = Dict{Int, Int}()
    open(filepath) do infile
        for ln in eachline(infile)
            words = split(ln) .|> strip
            card_number = parse(Int, strip(words[2], ':'))
            divider_position = findall(words .== "|")[1]
            ticket_numbers = parse.(Int, words[3:divider_position-1])
            my_numbers = parse.(Int, words[divider_position+1:end])

            local_winner = false
            for my_number in my_numbers
                if my_number in ticket_numbers
                    # if !haskey(winning_cards, card_number)
                    # winning_cards[card_number] = (ticket_numbers, my_numbers)
                    winning_card_counter[card_number] = 1
                    local_winner = true
                    break
                    # end
                end
            end
            
            if !local_winner
                winning_card_counter[card_number] = 0
            end

            all_cards[card_number] = (ticket_numbers, my_numbers)

        end

    end
    all_cards, winning_card_counter
end

function check_winners(ticket_numbers, my_numbers)
    winners = Int[]
    for my_number in my_numbers
        if my_number in ticket_numbers
            push!(winners, my_number)
        end
    end

    return winners
end

function count_scratchcard_copies(filepath)

    all_cards, winning_card_counter = get_original_winners(filepath)
    card_counter = Dict(card => 1 for (card, _) in all_cards)

    for (card, numbers) in sort(all_cards)
        winners = check_winners(numbers...)
        if isempty(winners)
            continue
        end

        for i = 1:winning_card_counter[card]
            for k = 1:length(winners)
                winning_card_counter[card+k] += 1
                card_counter[card+k] += 1

            end
        end
    end
    
    card_counter
end 