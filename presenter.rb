module Presenter
  def print_welcome(prompt)
    # print the welcome message
    space = prompt.size < 34 ? (34 - prompt.size) / 2 : 0
    puts "#{'#' * 36}\n##{' ' * space}#{prompt} #{' ' * space}#\n#{'#' * 36}".yellow
  end

  def loading
    5.times do
      sleep 0.5
      print "."
    end
  end

  def print_get_valid_actions(arr, get = "")
    print "#{arr.join(' | '.brown)}\n#{get}"
    gets.chomp
  end

  def until_part(options)
    print "> ".green
    answer = gets.chomp
    until answer != "" && answer.to_i <= options.size
      puts "🚫Select a valid option".red.bg_gray
      print "> ".green
      answer = gets.chomp
    end
    answer
  end

  def print_questions(quest)
    print "#{'Category:'.green} #{@coder.decode(quest[:category])} "
    puts "#{'|'.yellow} #{'Difficulty:'.green} #{@coder.decode(quest[:difficulty])}"
    puts "#{'Question:'.green} #{@coder.decode(quest[:question])}"
  end
end
