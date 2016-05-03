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
    if params['action']
      do_action(params['action'])
    end
    @question_tracker.update_attributes(params.select {|k, v| editable_params.include? k })
    self
  end

  def do_action(action)
    return self unless action
    case action['type']
    when "replaceMaster"
      return replace_master(action)
    when "modifyMaster"
      return modify_master(action)
    when "addChoice"
      return add_choice(action)
    when "deleteChoice"
      return remove_choice(action)
    end
    return self
  end
  private


  def add_choice(action)
    @question_tracker.master_question.add_choice()
    return self
  end

  def remove_choice(action)
    @question_tracker.master_question.choices.find(action['choice_id']).destroy
    @question_tracker.master_question.reload
    return self
  end

  def modify_master(action)
    @question_tracker.master_question.update_attributes(action['question'])
    return self
  end

  def replace_master(action)
    class_name = action['value']
    QuestionTracker.transaction do
      prompt = @question_tracker.master_question.prompt
      @question_tracker.master_question.delete
      @question_tracker.master_question = class_name.constantize.create(prompt: prompt)
      if @question_tracker.master_question.is_a?(Embeddable::MultipleChoice)
        @question_tracker.master_question.create_default_choices
      end
    end
    return self
  end

  def editable_params
    ["name", "description"]
  end


  def serialized_multiple_choice(q)
     {
        id: q.id,
        name: q.name,
        prompt: q.prompt,
        custom: q.custom,
        enable_check_answer: q.enable_check_answer,
        multi_answer: q.multi_answer,
        show_as_menu: q.show_as_menu,
        choices: q.choices.map { |c| {prompt: c.prompt, is_correct: c.is_correct, choice: c.choice, id: c.id } }
    }

  end

  def question_details(q)
    case q
      when Embeddable::MultipleChoice
        return serialized_multiple_choice(q)
      else
        return q
      end
  end

  def map_question(q)
    {
      id: q.id,
      type: q.class.name,
      question: question_details(q)
    }
  end

  def map_questions(questions)
    questions.map  { |q| map_question(q) }
  end

end
