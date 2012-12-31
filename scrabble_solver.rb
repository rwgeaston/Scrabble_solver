require 'set'

class String
    def each_with_index
        (0...self.size).each { |i| yield i, self[i] }
    end
    
    def remove_character(letter)
        letter_location = self.index(letter)
        return self[(0...letter_location)].concat(self[(letter_location + 1 ... self.size)])
    end
    
    def contains(letter)
        if self.index(letter)
            return true
        else
            return false
        end
    end
end

class Array
    def add(second_array)
        if self.size != second_array.size
            raise "Arrays must be the same length to add"
        end
        return Array.new(self.size) {|i| self[i] + second_array[i]}
    end
    
    def multiply(scalar)
        return Array.new(self.size) {|i| self[i] * scalar}
    end
    
    def product()
        result = 1
        self.each {|i| result *= i}
        return result
    end
end

class Scrabble_grid
    def initialize
        @grid_state = Array.new(15) { Array.new(15) {0} }
    end

    def get_tile(coord)
        if coord[0] == -1 or coord[0] == 15 or coord[1] == -1 or coord[1] == 15
            return 0
        end
        return @grid_state[coord[0]][coord[1]]
    end

    def set_tile(coord, value)
        if get_tile(coord) != 0 and get_tile(coord) != value
            puts "something seems very fishy here"
        end
        @grid_state[coord[0]][coord[1]] = value
    end

    def to_s
        strings = []
        (0...15).each do |row|
            (0...15).each do |column|
                strings << get_tile([column, row]) << ' '
            end
            strings << "\n"
        end
        return strings.join
    end

    def add_word(word, start_coord, direction)
        word.each_with_index do |index, letter|
            set_tile(start_coord.add(direction.multiply(index)), letter)
        end
    end

    def find_perpendicular_word(coord, word_direction, letter, show_blanks_as_letters)
        if show_blanks_as_letters
            show_blanks = -1
        else
            show_blanks = 0
        end
        perp_word = letter
        perp_direction = word_direction.reverse
        [-1, 1].each do |direction|
            working_coord = coord.add(perp_direction.multiply(direction))
            while get_tile(working_coord) != 0
                if direction == -1
                    perp_word = get_tile(working_coord)[show_blanks] + perp_word            
                else
                    perp_word += get_tile(working_coord)[show_blanks]    
                end
                working_coord = working_coord.add(perp_direction.multiply(direction))
            end
        end
        return perp_word
    end

    def get_all_letters_this_line(line_num, direction)
        letters_in_line = ''
        perp_direction = direction.reverse
        (0...15).each do |line_entry|
            letter = get_tile(direction.multiply(line_entry).add(perp_direction.multiply(line_num)))
            if letter != 0
                letters_in_line = letters_in_line.concat(letter[-1])
            end
        end
        return letters_in_line
    end
end

class Scrabble_score
    def initialize
        @letter_scores = {'a' => 1, 'b' => 3, 'c' => 3, 'd' => 2, 'e' => 1, 'f' => 4, 'g' => 2,
                          'h' => 4, 'i' => 1, 'j' => 8, 'k' => 5, 'l' => 1, 'm' => 3, 'n' => 1,
                          'o' => 1, 'p' => 3, 'q' => 10, 'r' => 1, 's' => 1, 't' => 1, 'u' => 1,
                          'v' => 4, 'w' => 4, 'x' => 8, 'y' => 4, 'z' => 10, '-' => 0}
                                       
        @special_squares = {[7, 3] => 'dl', [4, 4] => 'dw', [9, 1] => 'tl', [5, 9] => 'tl', [3, 0] => 'dl',
                            [2, 8] => 'dl', [12, 12] => 'dw', [11, 11] => 'dw', [5, 13] => 'tl', [0, 7] => 'tw',
                            [9, 9] => 'tl', [6, 2] => 'dl', [2, 12] => 'dw', [11, 14] => 'dl', [3, 7] => 'dl',
                            [0, 14] => 'tw', [7, 11] => 'dl', [0, 3] => 'dl', [3, 14] => 'dl', [10, 4] => 'dw',
                            [13, 13] => 'dw', [12, 2] => 'dw', [13, 1] => 'dw', [5, 5] => 'tl', [6, 6] => 'dl',
                            [12, 6] => 'dl', [0, 0] => 'tw', [1, 5] => 'tl', [0, 11] => 'dl', [2, 2] => 'dw',
                            [7, 7] => 'dw', [8, 6] => 'dl', [1, 1] => 'dw', [4, 10] => 'dw', [7, 14] => 'tw',
                            [2, 6] => 'dl', [8, 2] => 'dl', [9, 13] => 'tl', [1, 13] => 'dw', [14, 14] => 'tw',
                            [3, 11] => 'dw', [11, 0] => 'dl', [14, 3] => 'dl', [1, 9] => 'tl', [9, 5] => 'tl',
                            [14, 0] => 'tw', [6, 12] => 'dl', [3, 3] => 'dw', [14, 11] => 'dl', [11, 7] => 'dl',
                            [11, 3] => 'dw', [7, 0] => 'tw', [6, 8] => 'dl', [8, 12] => 'dl', [10, 10] => 'dw',
                            [14, 7] => 'tw', [13, 5] => 'tl', [8, 8] => 'dl', [5, 1] => 'tl', [13, 9] => 'tl',
                            [12, 8] => 'dl'}
        
        @special_square_meaning = {'dl' => [2, 1], 'tl' => [3, 1], 'dw' => [1, 2], 'tw' => [1, 3]}

    end
    
    def score_word(word, start_coord, direction, current_grid)
        parallel_score = 0
        parallel_multiplier = 1
        perpendicular_score = 0
        letters_used = 0
        word.each_with_index do |index, letter|
            working_coord = start_coord.add(direction.multiply(index))
            if current_grid.get_tile(working_coord) != 0
                lm = 1
            else
                letters_used += 1
                if @special_squares.has_key?(working_coord)
                    lm, wm = *(@special_square_meaning[@special_squares[working_coord]])
                else
                    lm, wm = [1, 1]
                end

                parallel_multiplier *= wm

                perp_word = current_grid.find_perpendicular_word(working_coord,
                                                                 direction,
                                                                 letter,
                                                                 false)
                if perp_word.size > 1
                    perp_word_score = 0
                    perp_word.each_char do |perp_letter|
                        perp_word_score += @letter_scores[perp_letter]
                    end    
                    perp_word_score += (lm - 1) * @letter_scores[letter]
                    perp_word_score *= wm
                    perpendicular_score += perp_word_score
                end
                
            end
            
            parallel_score += lm * @letter_scores[letter]
        end
 
        total_score = parallel_score * parallel_multiplier + perpendicular_score
        if letters_used == 0
            return 0
        elsif 0 < letters_used and letters_used < 7
            return total_score
        elsif letters_used == 7
            return total_score + 50
        else
            raise 'Too many letters used'
        end
    end
    
    def score_word_list(current_grid, word_list)
        word_list.collect do |word, start_coord, direction|
            [score_word(word, start_coord, direction, current_grid), word, start_coord, direction]
        end
    end
end
class Scrabble_move_finder
    def initialize
        file = File.new("./hashed_sowpods.txt", "r")
        @word_list = Array.new
        @word_set = Set.new
        file.each do |line|
            line_values = line.strip.split(',')
            @word_list << [line_values[0].to_i, line_values[1]]
            @word_set << line_values[1]
        @horiz = [1, 0]
        @vert = [0, 1]
        end
    end
    
    def is_a_word(word)
        return @word_set.member?(word)
    end
    
    def filter_with_hashes(current_grid, letters_held)
        rows = Array.new(15) {0}
        checker = Word_hash.new(current_grid, letters_held)
        valid_moves = []
        @word_list.each do |word|
            if checker.try_full_grid(word)
                (0...15).each do |line_num|
                    if checker.try_row(line_num, word)
                        valid_moves.push(*try_placing_line(current_grid, letters_held,
                                                           word[1], line_num, @horiz))
                    end
                    if checker.try_column(line_num, word)
                        valid_moves.push(*try_placing_line(current_grid, letters_held,
                                                  word[1], line_num, @vert))
                    end
                end
            end
        end
        return valid_moves
    end
    
    def try_placing_line(current_grid, letters_held, word, line_num, direction)
        valid_moves = []
        constant_coord = direction.reverse.multiply(line_num)
        (0..(15 - word.size)).select do |start_index|
            start_coord = direction.multiply(start_index).add(constant_coord)
            if try_placing(current_grid, letters_held, word, start_coord, direction)
                valid_moves << [word, start_coord, direction]
            end 
        end
        return valid_moves
    end
    
    def try_placing(current_grid, letters_held, word, start_coord, direction)
        letters_left = letters_held
        if current_grid.get_tile(start_coord.add(direction.multiply(-1))) != 0
            return false
        end
        if current_grid.get_tile(start_coord.add(direction.multiply(word.size))) != 0
            return false
        end
        meets_existing_words = false
        word.each_with_index do |index, letter|
            coord_checking = start_coord.add(direction.multiply(index))
            if current_grid.get_tile(coord_checking) == 0
                if letters_left.contains(letter)
                   letters_left = letters_left.remove_character(letter)
                elsif letters_left.contains('-')
                    letters_left = letters_left.remove_character('-')
                else
                    return false
                end
            else
                meets_existing_words = true
                if current_grid.get_tile(coord_checking) != letter
                    return false
                end
            end
            perp_word = current_grid.find_perpendicular_word(coord_checking,
                                                             direction,
                                                             letter, true)
            if perp_word.size > 1
                meets_existing_words = true
                if not is_a_word(perp_word)
                    return false
                end
            end
        end
        if letters_left == letters_held
            # no tiles were used
            return false
        end
        # last check: must touch existing used tile
        return meets_existing_words
    end
    
    def first_move(current_grid, letters_held)
        checker = Word_hash.new(current_grid, letters_held)
        valid_moves = []
        @word_list.each do |word|
            if checker.try_full_grid(word)
                (8-word.size..7).each do |start_position|
                    valid_moves << [word[1], [7, start_position], [0, 1]]
                end
            end
        end
        return valid_moves
    end
end

class Word_hash
    def initialize(current_grid, letters_held)
        @letter_hash = {'e' => 2, 's' => 3, 'i' => 5, 'a' => 7, 'r' => 11, 'n' => 13, 'o' => 17,
                        't' => 19, 'l' => 23, 'c' => 29, 'd' => 31, 'u' => 37, 'p' => 41, 'm' => 43,
                        'g' => 47, 'h' => 53, 'b' => 59, 'y' => 61, 'f' => 67, 'v' => 71, 'k' => 73,
                        'w' => 79, 'z' => 83, 'x' => 89, 'q' => 97, 'j' => 101}
        @horiz = [1, 0]
        @vert = [0, 1]
        
        # list of possible hashes for letters held by giving different values to the blank tiles
        # usually returns array of length 1 (if no blank tiles)
        letters_held_hash = get_letter_hash_list(letters_held)
        
        # for each column list the hashes of that column * letters_held
        @column_hashes = Array.new(15) do |i|
            letters_held_hash.collect do |hash_value|
                hash_word(current_grid.get_all_letters_this_line(i, @vert)) * hash_value
            end
        end
        
        # need 15 row hashes without letters_held to make full grid hash
        row_hashes_temp = Array.new(15) { |i| hash_word(current_grid.get_all_letters_this_line(i, @horiz)) }
        full_product = row_hashes_temp.product
        @full_grid_hash = letters_held_hash.collect do |hash_value|
            full_product * hash_value
        end
            
        # now make proper row hashes as with columns    
        @row_hashes = Array.new(15) do |i|
            letters_held_hash.collect do |hash_value|
                row_hashes_temp[i] * hash_value
            end
        end
        
        # if the row on both sides is empty, no point trying to put a word in this row (horizontally)
        # same with columns
        
        row_letter_counts = Array.new(15) do
            |line_num| current_grid.get_all_letters_this_line(line_num, @horiz).size
        end
        column_letter_counts = Array.new(15) do
            |line_num| current_grid.get_all_letters_this_line(line_num, @vert).size
        end
        if row_letter_counts[1] == 0
            @row_hashes[0] = [1]
        end
        if row_letter_counts[13] == 0
            @row_hashes[14] = [1]
        end
        if column_letter_counts[1] == 0
            @column_hashes[0] = [1]
        end
        if column_letter_counts[13] == 0
            @column_hashes[14] = [1]
        end
        (1..13).each do |line_num|
            if row_letter_counts[line_num - 1] == 0 and row_letter_counts[line_num + 1] == 0
                @row_hashes[line_num] = [1]
            end
            if column_letter_counts[line_num - 1] == 0 and column_letter_counts[line_num + 1] == 0
                @column_hashes[line_num] = [1]
            end
        end
        
    end
    
    def get_letter_hash_list(letters_held)
        if letters_held.contains('-')
            letters_held = letters_held.remove_character('-')
            if letters_held.contains('-')
                letters_held = letters_held.remove_character('-')
                part_hash = hash_word(letters_held)
                possible_letter_pairs = ('aa'..'zz').select {|pair| pair[0] <= pair[1]}
                return possible_letter_pairs.collect { |pair| hash_word(pair) * part_hash }
            else
                part_hash = hash_word(letters_held)
                return ('a'..'z').collect { |pair| hash_word(pair) * part_hash }
            end
        else
            return [hash_word(letters_held)]
        end
    end
    
    def hash_word(word)
        hash = 1
        word.chars do |letter|
            hash *= @letter_hash[letter]
        end
        return hash
    end
    
    def try_full_grid(word)
        @full_grid_hash.each do |hash_value|
            if hash_value % word[0] == 0
                return true
            end
        end
        return false
    end
    
    def try_row(row_number, word)
        @row_hashes[row_number].each do |hash_value|
            if hash_value % word[0] == 0
                return true
            end
        end
        return false
    end
    
    def try_column(column_number, word)
        @column_hashes[column_number].each do |hash_value|
            if hash_value % word[0] == 0
                return true
            end
        end
        return false
    end
end
