class DashboardRunlist
  include LightweightStandalone::Application.routes.url_helpers

  def initialize(students,base_url)
    # Some students do not have learners yet (they haven't run yet)
    # students =  [] of {name: "joe doe", learner_id: [null|digits] }
    # base_url = the portal url-base eg: "http://localhost:9000"
    # we are going to return students {
    #   name: "joe doe",
    #   answers:[ {
    #     prompt:'prompt',
    #     answer:'answer',
    #     score:3,
    #     feedback:'xxx'}
    #   ]}
    @runs = students.map do |s|
      name       = s[:name]
      learner_id = s[:learner_id]
      answers    = []

      if learner_id
        remote_endpoint = "#{base_url}/dataservice/external_activity_data/#{learner_id}"
        run = Run.find_by_remote_endpoint(remote_endpoint, include: [multiple_choice_answers: :question, open_response_answers: :question, image_question_answers: :question])
        if run
          answers = run.answers.select { |a| a.respond_to? :feedback_items }
        end
        answers.map! do |a|
          question_hash = "#{a.question.class.name}#{a.question_id}",
          tries = a.feedback_items.map do |fi|
            {
              answer: fi.answer,
              feedback: fi.feedback,
              score: fi.score
            }
          end
          score    = tries.last ? tries.last.score : 0
          {
            name: a.question.name,
            prompt: a.question.prompt,
            answer: a.answer_text,
            question_hash: question_hash,
            score: score,
            tries: tries
          }
        end
      end
      {
        team_name: name,
        answers: answers
      }
    end
  end

  def to_hash
    return @runs
  end


  def to_json
    to_hash.to_json
  end

end
