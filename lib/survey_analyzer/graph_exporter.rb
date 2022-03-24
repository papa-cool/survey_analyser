require "gruff"
require_relative "calculate"

module GraphExporter

  def for_groups_and_global(survey)
    groups = survey.data.first.last.keys
    groups.each do |group|
      FileUtils.mkdir_p("results/#{group}")
    end

    survey.data.each.with_index do |(question_key, count_by_answer_by_group), index|
      puts "Process question " + question_key.to_s
      title = survey.titles[question_key].split("|").last.strip

      percent_by_answer_by_group = count_by_answer_by_group.map do |group, count_by_answer|
        [group, Calculate.percent(count_by_answer)]
      end.to_h
 
      survey.old_data.each.with_index do |data, index|
        puts "Process question " + question_key.to_s + " for#{suffix(index)}"
        percent_by_answer_by_group.merge!(
          data[question_key].map do |group, count_by_answer|
            [group + suffix(index), Calculate.percent(count_by_answer)]
          end.to_h
        )
      end

      puts "Set Min/Max"
      percent_by_answer_by_group["Min"] = percent_by_answer_by_group[survey.min[question_key]]
      percent_by_answer_by_group["Max"] = percent_by_answer_by_group[survey.max[question_key]]

      groups.each do |current_group|
        create_side_stacked_bar(
          survey,
          title,
          build_bar_groups(groups, current_group, percent_by_answer_by_group),
          percent_by_answer_by_group,
          "results/#{current_group}/result_#{(index+1).to_s.rjust(2, '0')}.png"
        )
      end
    end
  end
  module_function :for_groups_and_global

  # Return the name of the bars
  #
  # @example
  # => ["Global TCS -2","Global TCS -1","Global","Finance","Tech",...]
  # => ["Finance TCS -2","Finance TCS -1","Finance","Min", "Global", "Max"]
  def build_bar_groups(groups, current_group, percent_by_answer_by_group)
    bar_groups = current_group == "Global" ? groups.dup : [current_group, "Min", "Global", "Max"]

    index = 0
    while(percent_by_answer_by_group[current_group + suffix(index)]) do
      bar_groups.unshift(current_group + suffix(index))
      index += 1
    end

    bar_groups
  end
  module_function :build_bar_groups

  def create_side_stacked_bar(survey, title, bar_groups, percent_by_answer_by_group, file_name)
    puts "Create graph title=#{title} bar_groups=#{bar_groups} file_name=#{file_name}"
    gruff = Gruff::SideStackedBar.new
    gruff.theme = {
      colors: ["#ff0000", "#e59866", "#7dcea0", "#229954"],
      marker_color: 'black',
      background_colors: ['white', 'white'],
    }
    gruff.title = title
    gruff.labels = bar_groups.map.with_index { |group, index| [index, group] }.to_h
    survey.config[:answers].each do |answer|
      gruff.data answer, bar_groups.map { |group| percent_by_answer_by_group[group][answer] || 0 }
    end
    gruff.write(file_name)
  end
  module_function :create_side_stacked_bar

  # Return suffix to create key name for old survey result
  def suffix(index)
    " TCS -#{index+1}"
  end
  module_function :suffix

end