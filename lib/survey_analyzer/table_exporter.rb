require_relative "calculate"

module TableExporter

  def average_for_groups_and_global(survey)
    puts "Process average"
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
    puts "Process promoter"
    groups = survey.data.first.last.keys

    CSV.open("results/promoter_percent_for_groups_and_global.csv", "wb") do |csv|
      csv << ["Questions"] + groups
      survey.data.each do |question_key, count_by_group_by_answer|
        csv << [survey.titles[question_key].split(" | ").last] + groups.map { |group| Calculate.promoter_percent(count_by_group_by_answer[group], survey.config[:promoter_answers]).to_s + " %" }
      end
    end
  end
  module_function :promoter_percent_for_groups_and_global

  def verbatims(survey)
    puts "Process verbatims"
    CSV.open("results/verbatims.csv", "wb") do |csv|
      csv << survey.titles.slice(survey.config[:column_for_grouping], *survey.config[:columns_to_extract]).values.map {|v| v.split("|").last.strip}

      survey.data_from_file.each do |row_hash|
        verbatim_values = row_hash.slice(*survey.config[:columns_to_extract]).values
        next unless verbatim_values.any? {|v| !v.to_s.empty?}

        csv << [
          survey.sanitize_group_name(row_hash[survey.config[:column_for_grouping]]),
          *verbatim_values
        ]
      end
    end
  end
  module_function :verbatims

end