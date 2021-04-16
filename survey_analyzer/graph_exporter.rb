require 'gruff'
require 'SVG/Graph/Bar'
require "gnuplot"
require_relative 'calculate'

module GraphExporter

  def for_groups_and_global(survey)
    groups = survey.data.first.last.keys
    groups.each do |group|
      FileUtils.mkdir_p("results/#{group}")
    end

    survey.data.each.with_index do |(question_key, count_by_answer_by_group), index|
      title = survey.titles[question_key].split(" | ").last

      percent_by_answer_by_group = count_by_answer_by_group.map do |group, count_by_answer|
        [group, Calculate.percent(count_by_answer)]
      end.to_h

      if survey.old_data
        previous_percent_by_answer_by_group = survey.old_data[question_key].map do |group, count_by_answer|
          [group + " TCS-1", Calculate.percent(count_by_answer)]
        end.to_h
        percent_by_answer_by_group.merge!(previous_percent_by_answer_by_group)
      end

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

  def build_bar_groups(groups, current_group, percent_by_answer_by_group)
    bar_groups = current_group == "Global" ? groups : [current_group, "Min", "Global", "Max"]
    previous_group = current_group + " TCS-1"
    bar_groups = [previous_group] + bar_groups if percent_by_answer_by_group[previous_group]
    bar_groups
  end
  module_function :build_bar_groups

  def create_side_stacked_bar(survey, title, bar_groups, percent_by_answer_by_group, file_name)
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

end