module Calculate

  def average(count_by_answer, answers_mapping)
    total = count_by_answer.values.sum
    (count_by_answer.reduce(0) { |sum, (answer, count)| sum = sum + answers_mapping.fetch(answer) * count }.to_f / total).round(2)
  end
  module_function :average

  def promoter_percent(count_by_answer, promoter_answers)
    total = count_by_answer.values.sum
    (count_by_answer.reduce(0) { |sum, (answer, count)| sum = promoter_answers.include?(answer) ? sum + count : sum }.to_f / total * 100).round.to_i
  end
  module_function :promoter_percent

  def percent(count_by_answer)
    total = count_by_answer.values.sum
    count_by_answer.map { |answer, count| [answer, (count.to_f * 100 / total).round(2)] }.to_h
  end
  module_function :percent

end