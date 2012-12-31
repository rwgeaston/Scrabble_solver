require './scrabble_solver'

my_grid = Scrabble_grid.new
scorer = Scrabble_score.new
word_finder = Scrabble_move_finder.new

horiz = [1, 0]
vert = [0, 1]

moves = [["first_word_played", [7, 7], horiz],
         ["next_word_played", [6, 6], [1, 0]]]

moves.each do |move|
    my_grid.add_word(*move)
end

my_current_letters = 'abcdef-'

# use this line for the first move
#answers = scorer.score_word_list(my_grid, word_finder.first_move(my_grid, my_current_letters))

# use this line for normal moves
answers = scorer.score_word_list(my_grid, word_finder.filter_with_hashes(my_grid, my_current_letters))

good_answers = answers.sort!.reverse![(0...20)]
good_answers.each do |i|
    print i
    puts
end