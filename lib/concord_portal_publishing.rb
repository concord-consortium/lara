module ConcordPortalPublishing
  def portal_url
    (ENV['CONCORD_PORTAL_URL'] || "http://localhost:3000") + '/external_activities/publish'
  end

  def portal_publish(activity)
    data = {
      "name" => activity.name,
      "description" => activity.description,
      "url" => activity_url(activity),
      "create_url" => activity_url(activity)
    }

    pages = []
    activity.pages.each do |page|
      elements = []
      page.embeddables.each do |embeddable|
        case embeddable
        when Embeddable::OpenResponse
          elements.push({
            "type" => "open_response",
            "id" => embeddable.id,
            "prompt" => embeddable.prompt
          })
        when Embeddable::MultipleChoice
          choices = []
          embeddable.choices.each do |choice|
            choices.push({
              "id" => choice.id,
              "content" => choice.choice,
              "correct" => choice.is_correct
            })
          end
          mc_data = {
            "type" => "multiple_choice",
            "id" => embeddable.id,
            "prompt" => embeddable.prompt,
            "choices" => choices
          }

          elements.push(mc_data)
        else
          # We don't suppoert this embeddable type right now
        end
      end
      pages.push({
        "name" => page.name,
        "elements" => elements
      })
    end

    section = {
      "name" => "#{activity.name} Section",
      "pages" => pages
    }

    data["sections"] = [section]
    bearer_token = 'Bearer %s' % current_user.authentication_token
    response = HTTParty.post(portal_url, :body => data.to_json, :headers => {"Authorization" => bearer_token, "Content-Type" => 'application/json'})
    # report success
    # TODO Probably this should be better about saying why it failed, if it does...
    return response.code == 201
  end
end