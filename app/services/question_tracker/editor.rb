class QuestionTracker::Editor
  include LightweightStandalone::Application.routes.url_helpers

  def initialize(question_tracker)
    @question_tracker = question_tracker
  end

  def to_json
    {
      id: @question_tracker.id,
      name: @question_tracker.name,
      description: @question_tracker.description,
      master_question: map_question(@question_tracker.master_question),
      update_url: question_tracker_path(@question_tracker, format: 'json'),
      questions: map_questions(@question_tracker.questions)
    }
  end

  def update(params)
    @question_tracker.update_attributes(params.select {|k, v| editable_params.include? k })
    self
  end

  private

  def editable_params
    ["name", "description"]
  end


  def map_question(q)
    {
      id: q.id,
      type: q.class.name,
      question: q
    }
  end

  def map_questions(questions)
    questions.map  { |q| map_question(q) }
  end

end
