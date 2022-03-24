$LOAD_PATH << "./lib"

require("bundler/setup")
require 'survey_analyzer'

task(:all) do
  survey = SurveyAnalyzer.new
  GraphExporter.for_groups_and_global(survey)
  TableExporter.verbatims(survey)
  TableExporter.promoter_percent_for_groups_and_global(survey)
end

task(:graph) do
  survey = SurveyAnalyzer.new
  GraphExporter.for_groups_and_global(survey)
end
task(:verbatims) do
  survey = SurveyAnalyzer.new
  TableExporter.verbatims(survey)
end
task(:promoter) do
  survey = SurveyAnalyzer.new
  TableExporter.promoter_percent_for_groups_and_global(survey)
end
