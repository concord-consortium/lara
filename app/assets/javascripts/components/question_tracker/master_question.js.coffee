{div, span} = React.DOM

modulejs.define 'components/question_tracker/master_question',
  [
    'components/question_tracker/question_summary',
    'components/question_tracker/question_adder',
    'components/question_tracker/open_response'
  ],
  (QuestionSummaryClass, QuestionAdderClass, OpenResponseClass) ->

    QuestionSummary = React.createFactory QuestionSummaryClass
    QuestionAdder   = React.createFactory QuestionAdderClass
    OpenResponse    = React.createFactory OpenResponseClass

    React.createClass

      updateServer:(state) ->
        return true # fake it for now.
        $.ajax
          url: state.update_url
          type: 'PUT'
          dataType: 'json'
          contentType: 'application/json'
          data: JSON.stringify({
            _method: 'PUT'
            question_tracker: state
            id: @props.question.id
          })
          success: (resp) =>
            @props.alert 'info', 'Saved'

          error: =>
            @props.alert 'error', 'Save Failed!'


      update: (newState) ->
        @setState(newState, => @updateServer(@state))

      render: ->
        question = @props.question
        update = @update

        (div {className: 'master-question'},
          (QuestionAdder {question: question, update: update, edit: @props.edit})
          if @props.question
            if @props.edit
              (div {className: 'edit'}, "editing")
              (QuestionSummary {question: question})
              switch @props.question.type
                when "Embeddable::OpenResponse" then (OpenResponse {initialValue: @props.question.question, update: update})

            else
              (div {className: 'viewing'}, "viewing")
              (QuestionSummary {question: @props.question, update: update})
        )