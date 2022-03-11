# do not forget to require your gem dependencies
# do not forget to require_relative your local dependencies
require_relative "presenter"
require_relative "services"
require "htmlentities"
require "terminal-table"

class CliviaGenerator
  include Presenter
  # maybe we need to include a couple of modules?

  def initialize(score = [])
    # we need to initialize a couple of properties here
    @action_op = ["ramdom", "scores", "exit"]
    @coder = HTMLEntities.new
    @trivia = Services::Session.new
    @score_table = score
  end

  def start
    # welcome message
    action = ""
    # keep going until the user types exit
    # prompt the user for an action
    until action == "exit"
      print_welcome("Welcome to Clivia Generator")
      action = print_get_valid_actions(@action_op, "> ")
      case action
      when "ramdom"
        random_trivia
      when "scores"
        print_scores
      when "exit"
        puts "ty for playing" # change for dibujo
      else
        puts "Invalid option"
      end
    end
  end

  def random_trivia
    # load the questions from the api
    @questions = @trivia.trivia_qa(1)
    @score = 0
    # ask each question
    @questions[:content][:results].each do |q|
      puts "Category: #{@coder.decode(q[:category])} | Difficulty: #{@coder.decode(q[:difficulty])}"
      puts "Question: #{@coder.decode(q[:question])}"
      options = (q[:incorrect_answers] << q[:correct_answer]).shuffle
      options.each_with_index { |n, i| puts "#{i + 1}. #{@coder.decode(n)}" }
      ask_questions(q, options)
      save
    end
  end

  def ask_questions(question, options)
    print "> "
    answer = gets.chomp
    print "#{@coder.decode(options[answer.to_i - 1])} is"
    loading

    if options[answer.to_i - 1] == question[:correct_answer]
      # if response is correct, put a correct message and increase score
      puts "Correct!"
      sleep 1
      @score += 10
      puts "+10 points! now your score is: #{@score}"
    else
      # if response is incorrect, put an incorrect message, and which was the correct answer
      puts "Incorrect!"
      sleep 1
      puts "The correct answer was: #{@coder.decode(question[:correct_answer])}"
    end
    puts ("-" * 50).to_s
    sleep 1
    puts "Well done! Your score is #{@score}"
  end

  def save
    # once the questions end, show user's score and promp to save it
    puts "Do you want to save your score? (y/n)"
    save_a = gets.chomp.downcase
    case save_a
    when "y"
      print "Type the name to assign to the score\n> "
      user = gets.chomp
      user = "Anonymous" if user.empty?
      @score_table << { user: user, score: @score }

      # write to file the scores data
      parse_scores
    when "n"

    else
      puts "please select valid option"
    end
  end

  def parse_scores
    # get the scores data from file

    File.write("temp.json", JSON.pretty_generate(@score_table))
  end

  def loading
    # ask the api for a random set of questions
    # then parse the questions
    5.times do
      sleep 0.5
      print "."
    end
  end

  def parse_questions
    # questions came with an unexpected structure, clean them to make it usable for our purposes
  end

  def print_scores
    # print the scores sorted from top to bottom
    table = Terminal::Table.new # genero tabla
    table.title = "Top Scores"
    table.headings = ["Name", "Score"]
    @score_table.map do |sc|
      table.add_row [sc[:user], sc[:score]]
    end
    puts table
  end
end

trivia = CliviaGenerator.new
trivia.start
