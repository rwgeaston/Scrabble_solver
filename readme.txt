scrabble_solver.rb does all the work finding and scoring scrabble moves
hashed_sowpods.txt is a word list with a hash value for each word, to save time searching for words that fit
scrabble_example.rb shows an example of how to use scrabble_solver.rb
scrabble_interface.rb is an easy interface for this that uses only command line arguments:

format for usage is ruby scrabble_interface.rb <wordlist.txt> <current letters in lower case> <optional formatting argument>

the optional-formatting argument is 'short', 'extra' or 'bigcheater'