require_relative 'survey_analyzer/data_from_file'
require_relative 'survey_analyzer/table_exporter'
require_relative 'survey_analyzer/graph_exporter'

class SurveyAnalyzer

  attr_reader :config, :old_data, :data, :min, :max, :titles, :data_from_file

  def initialize
    @config = {
      header: (1..47).to_a,
      column_for_grouping: 2, # later [2,3,[2,3]],
      columns_to_evaluate: (4..12).to_a + (14..22).to_a + (24..32).to_a + (34..46).to_a,
      columns_to_extract: [13, 23, 33, 47],
      answers: ["1", "2", "3", "4"],
      answers_mapping: {
        "1" => -2,
        "2" => -1,
        "3" => +1,
        "4" => +2,
      },
      promoter_answers: ["3", "4"],
    }
    @old_data_from_file = DataFromFile.from_path("data/take_care_survey2.csv", "csv", @config[:header])
    @old_data = count_by(@old_data_from_file)
    @data_from_file = DataFromFile.from_path("data/take_care_survey3.csv", "csv", @config[:header])
    @data = count_by(@data_from_file)
    @min, @max = extract_min_max_group_per_question(@data)
    @titles = @data_from_file.titles
  end

  def sanitize_group_name(group_name)
    group_name.split(" ").first
  end

  # Organize result by question counting by group and answer
  #
  # @example
  # => {
  #   4 => {"global" => {"1" => 11, "2" => 17, ..., "avg" => 2.2 }, "Tech" => {"1" => 3, "2" => 7, ... "avg" => 2.2 }}
  #   5 => {"global" => {"1" => 9, "2" => 15, ...}, "Tech" => {"1" => 3, "2" => 7, ...}}
  # }
  def count_by(row_data)
    counted_data = Hash.new do |questions, column_key|
      questions[column_key] = Hash.new do |count_by_group_by_answer, grouping_key|
        count_by_group_by_answer[grouping_key] = Hash.new { |count_by_answer, answer_key| count_by_answer[answer_key] = 0 }
      end
    end

    row_data.each do |row|
      @config[:columns_to_evaluate].each do |column_key|
        counted_data[column_key]["Global"][row[column_key]] += 1
        grouping_key = sanitize_group_name(row[@config[:column_for_grouping]])
        counted_data[column_key][grouping_key][row[column_key]] += 1
      end
    end

    counted_data
  end


  def extract_min_max_group_per_question(data)
    min, max = {}, {}

    data.each do |question, count_by_group_by_answer|
      group_per_average = count_by_group_by_answer.map do |group, count_by_answer|
        [Calculate.average(count_by_answer, config[:answers_mapping]), group]
      end.to_h
      min[question] = group_per_average[group_per_average.keys.min]
      max[question] = group_per_average[group_per_average.keys.max]
    end

    [min, max]
  end

end

survey = SurveyAnalyzer.new
# TableExporter.average_for_groups_and_global(survey)
# TableExporter.promoter_percent_for_groups_and_global(survey)
GraphExporter.for_groups_and_global(survey)
TableExporter.verbatims(survey)

