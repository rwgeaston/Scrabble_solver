#!/usr/bin/env ruby
require './scrabble_solver'

my_grid = Scrabble_grid.new
scorer = Scrabble_score.new
word_finder = Scrabble_move_finder.new

directions = {"horiz" => [1, 0], "vert" => [0, 1]}

directions_reverse = {[1, 0] => "horiz", [0, 1] => "vert"}

column_map = {"A"=>0, "B"=>1, "C"=>2, "D"=>3, "E"=>4, "F"=>5, "G"=>6, "H"=>7,
              "I"=>8, "J"=>9, "K"=>10, "L"=>11, "M"=>12, "N"=>13, "O"=>14}

column_map_reverse = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O"] 

played_word_list = ARGV[0]
my_letters = ARGV[1]

if ARGV.size > 2
  display_option = ARGV[2]
else
  display_option = 'short'
end

move_list = []

if played_word_list == 'none'
  answers = scorer.score_word_list(my_grid, word_finder.first_move(my_grid, my_letters))
else
  file = File.new("./" + played_word_list, "r")
  file.each do |line|
    line_values = line.strip.split(' ')
    grid_position_row = line_values[1][1].to_i - 1
    grid_position_column = column_map[line_values[1][0]]
    grid_position = [grid_position_row, grid_position_column]
    direction = directions[line_values[2]]
    move_list << [line_values[0], grid_position, direction]
  end
  
  if move_list.size == 0
    answers = scorer.score_word_list(my_grid, word_finder.first_move(my_grid, my_letters))
  else
    move_list.each do |move|
      my_grid.add_word(*move)
    end
    answers = scorer.score_word_list(my_grid, word_finder.filter_with_hashes(my_grid, my_letters))
  end
end

if display_option == 'short'
  counts = [0, 0, 0, 0, 0, 0]
  answers.each do |answer|
    category = answer[0] / 10
    if category > 5
      category = 5
    end
    counts[category] += 1
  end
  (0..4).each do |tens|
    puts "#{ tens * 10 }-#{tens*10 + 9}: #{counts[tens]}"
  end
  puts "50+: #{counts[5]}"
elsif display_option == 'extra'
  good_answers = answers.sort!.reverse![(0...20)]
  good_answers.each do |i|
    puts i[0]
  end
elsif display_option == 'bigcheater'
  good_answers = answers.sort!.reverse![(0...20)]
  good_answers.each do |i|
    puts "#{i[0]} #{i[1]} #{column_map_reverse[i[2][0]]}#{(i[2][1] + 1)} #{directions_reverse[i[3]]}"
  end
end
