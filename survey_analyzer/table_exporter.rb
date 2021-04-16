require_relative 'calculate'

module TableExporter

  def average_for_groups_and_global(survey)
    groups = survey.data.first.last.keys

    CSV.open("results/average_for_groups_and_global.csv", "wb") do |csv|
      csv << ["Questions"] + groups
      survey.data.each do |question_key, count_by_group_by_answer|
        csv << [survey.titles[question_key]] + groups.map { |group| Calculate.average(count_by_group_by_answer[group], survey.config[:answers_mapping]) }
      end
    end
  end
  module_function :average_for_groups_and_global

  def promoter_percent_for_groups_and_global(survey)
    groups = survey.data.first.last.keys

    CSV.open("results/promoter_percent_for_groups_and_global.csv", "wb") do |csv|
      csv << ["Questions"] + groups
      survey.data.each do |question_key, count_by_group_by_answer|
        csv << [survey.titles[question_key].split(" | ").first] + groups.map { |group| Calculate.promoter_percent(count_by_group_by_answer[group], survey.config[:promoter_answers]).to_s + " %" }
      end
    end
  end
  module_function :promoter_percent_for_groups_and_global

end