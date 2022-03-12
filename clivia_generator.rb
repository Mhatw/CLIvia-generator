# do not forget to require your gem dependencies
# do not forget to require_relative your local dependencies
require_relative "presenter"
require_relative "services"
require "htmlentities"
require "terminal-table"
require "colorize"
require "colorized_string"
class String
  def black
    "\e[30m#{self}\e[0m"
  end

  def red
    "\e[31m#{self}\e[0m"
  end

  def green
    "\e[32m#{self}\e[0m"
  end

  def brown
    "\e[33m#{self}\e[0m"
  end

  def blue
    "\e[34m#{self}\e[0m"
  end

  def magenta
    "\e[35m#{self}\e[0m"
  end

  def cyan
    "\e[36m#{self}\e[0m"
  end

  def gray
    "\e[37m#{self}\e[0m"
  end

  def bg_black
    "\e[40m#{self}\e[0m"
  end

  def bg_red
    "\e[41m#{self}\e[0m"
  end

  def bg_green
    "\e[42m#{self}\e[0m"
  end

  def bg_brown
    "\e[43m#{self}\e[0m"
  end

  def bg_blue
    "\e[44m#{self}\e[0m"
  end

  def bg_magenta
    "\e[45m#{self}\e[0m"
  end

  def bg_cyan
    "\e[46m#{self}\e[0m"
  end

  def bg_gray
    "\e[47m#{self}\e[0m"
  end

  def bold
    "\e[1m#{self}\e[22m"
  end

  def italic
    "\e[3m#{self}\e[23m"
  end

  def underline
    "\e[4m#{self}\e[24m"
  end

  def blink
    "\e[5m#{self}\e[25m"
  end

  def reverse_color
    "\e[7m#{self}\e[27m"
  end
end

class CliviaGenerator
  include Presenter
  # maybe we need to include a couple of modules?

  def initialize
    # we need to initialize a couple of properties here
    filepass = ARGV.shift
    if filepass.nil?
      @score_table = []
      @file = "temp2.json"
    else
      @file = "temp.json"
      @score_table = JSON.parse(File.read(filepass))
    end
    @action_op = ["random", "scores", "exit".bg_red.gray]
    @coder = HTMLEntities.new
    @trivia = Services::Session.new
  end

  def start
    # keep going until the user types exit
    action = ""
    until action == "exit"
      # welcome message
      print_welcome("Welcome to Clivia Generator")
      # prompt the user for an action
      action = print_get_valid_actions(@action_op, "> ".green)
      case action
      when "random"
        random_trivia
      when "scores"
        print_scores
      when "exit"
        puts "thanks for playing".bg_gray.black # change for dibujo
        loading
        puts "--by: Mhatw🦖".bg_gray.blue
        sleep 1
        puts "Cohort 6 - {CodeAble}".bg_gray.blue
      else
        puts "🚫Invalid option".red.bg_gray
      end
    end
  end

  def random_trivia
    # load the questions from the api
    @questions = @trivia.trivia_qa(10)
    @score = 0
    # ask each question
    @questions[:content][:results].each do |q|
      print_questions(q)
      options = (q[:incorrect_answers] << q[:correct_answer]).shuffle
      options.each_with_index { |n, i| puts "#{"#{i + 1}.".yellow} #{@coder.decode(n).gray}" }
      ask_questions(q, options)
      sleep 1
    end
    sleep 1
    puts "Well done! Your score is #{@score}"
    save
  end

  def ask_questions(question, options)
    answer = until_part(options)
    print "#{@coder.decode(options[answer.to_i - 1])} is".yellow
    loading

    if options[answer.to_i - 1] == question[:correct_answer]
      # if response is correct, put a correct message and increase score
      puts "Correct!".green
      sleep 1
      @score += 10
      puts "#{'+10 points'.green}! now your score is: #{@score}"
    else
      # if response is incorrect, put an incorrect message, and which was the correct answer
      puts "Incorrect!".red
      sleep 1
      puts "#{'The correct answer was:'.green} #{@coder.decode(question[:correct_answer])}"
    end
    puts ("-" * 50).to_s
  end

  def save
    # once the questions end, show user's score and promp to save it
    puts "Do you want to save your score? (#{'y'.green}/#{'n'.red})"
    save_a = gets.chomp.downcase
    case save_a
    when "y"
      print "Type the name to assign to the score\n> "
      user = gets.chomp
      user = "Anonymous" if user.empty?
      @score_table << { "user" => user, "score" => @score }
      # write to file the scores data
      parse_scores
    when "n"

    else
      puts "🚫please select valid option".red.bg_gray
    end
  end

  def parse_scores
    # get the scores data from file
    File.write(@file, JSON.pretty_generate(@score_table))
  end

  def print_scores
    # print the scores sorted from top to bottom
    @score_table = (@score_table.sort_by { |k| k["score"] }).reverse
    table = Terminal::Table.new # genero tabla
    table.title = "Top Scores".yellow
    table.headings = ["Name", "Score"]
    @score_table.map do |sc|
      table.add_row [sc["user"].cyan, sc["score"]]
    end
    puts table
  end
end

trivia = CliviaGenerator.new
trivia.start
