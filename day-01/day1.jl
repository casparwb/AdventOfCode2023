function get_digits(filepath="input.txt")

    first_and_last = Int[]
    open(filepath) do io
        for ln in eachline(io)
            digits = filter(isdigit, ln) 
            digits = parse.(Int, split(digits, ""))
            push!(first_and_last, parse(Int, "$(digits[begin])$(digits[end])"))
        end
    end

    return sum(first_and_last)
end


function get_digits_with_letters(filepath="input.txt")

    digit_letters = ["one", "two", "three", "four", "five",
                     "six", "seven", "eight", "nine"]
    digit_dict = Dict(letter => "$i" for (letter, i) in zip(digit_letters, eachindex(digit_letters)))

    first_and_last = Int[]
    open(filepath) do io
        for ln in eachline(io)
            digit_indices = findall(isdigit, ln)
            letter_indices = []
            letter_digits = []
            
            for (word, digit) in digit_dict
                mtch = match(Regex(word), ln)
                while !isnothing(mtch)
                    push!(letter_indices, mtch.offset)
                    push!(letter_digits, digit)
                    mtch = match(Regex(word), ln, mtch.offset+length(word))
                end
            end

            if isempty(digit_indices)
                first_digit = letter_digits[minimum(letter_indices)]
                last_digit = letter_digits[maximum(letter_indices)]
            elseif isempty(letter_indices)
                first_digit = parse(Int, ln[minimum(digit_indices)])
                last_digit = parse(Int, ln[maximum(digit_indices)])
            else
                if minimum(letter_indices) < minimum(digit_indices)
                    first_digit = letter_digits[argmin(letter_indices)]
                else
                    first_digit = parse(Int, ln[minimum(digit_indices)])
                end

                if maximum(letter_indices) > maximum(digit_indices)
                    last_digit = letter_digits[argmax(letter_indices)]
                else
                    last_digit = parse(Int, ln[maximum(digit_indices)])
                end
            end
            push!(first_and_last, parse(Int, "$(first_digit)$(last_digit)"))
        end
    end

    sum(first_and_last)
end


function main()

    # Test part 1
    answer = 142
    my_sum = get_digits("testcase.txt")
    @assert answer == my_sum


    # Part 1
    my_sum = get_digits("input.txt")
    println("Part 1 value: $my_sum") 


    # Test part 2
    my_sum = get_digits_with_letters("testcase.txt")
    @assert answer == my_sum

    # Part 2
    my_sum = get_digits_with_letters("input.txt")
    println("Part 2 value: $my_sum") 

end