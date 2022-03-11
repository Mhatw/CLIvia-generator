module Presenter
  def print_welcome(prompt)
    # print the welcome message
    space = prompt.size < 34 ? (34 - prompt.size) / 2 : 0
    puts "#{'#' * 36}\n##{' ' * space}#{prompt} #{' ' * space}#\n#{'#' * 36}"
  end

  def print_get_valid_actions(arr, get = "")
    print "#{arr.join(' | ')}\n#{get}"
    gets.chomp
  end

  def print_score(score)
    # print the score message
  end
end
