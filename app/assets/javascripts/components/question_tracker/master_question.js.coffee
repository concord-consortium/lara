{div, span} = ReactFactories

modulejs.define 'components/question_tracker/master_question',
  [
    'components/question_tracker/question_summary',
    'components/question_tracker/question_adder',
    'components/question_tracker/open_response',
    'components/question_tracker/image_question',
    'components/question_tracker/multiple_choice'

  ],
  (QuestionSummaryClass, QuestionAdderClass, OpenResponseClass, ImageQuestionClass, MultipleChoiceClass) ->

    QuestionSummary = React.createFactory QuestionSummaryClass
    QuestionAdder   = React.createFactory QuestionAdderClass
    OpenResponse    = React.createFactory OpenResponseClass
    ImageQuestion   = React.createFactory ImageQuestionClass
    MultipleChoice  = React.createFactory MultipleChoiceClass

    createReactClass

      update: (newState) ->
        @props.update(newState)

      render: ->
        question = @props.question
        details = question.question
        edit = @props.edit
        update = @update

        (div {className: 'master-question'},
          (QuestionAdder {question: question, update: update, edit: edit})
          if question
            if edit
              (div {className: 'edit'}, "editing")
              (QuestionSummary {question: question})
              switch question.type
                when "Embeddable::OpenResponse"
                  (OpenResponse {question: details, update: update, edit: edit})
                when "Embeddable::ImageQuestion"
                  (ImageQuestion {question: details, update: update, edit: edit})
                when "Embeddable::MultipleChoice"
                  (MultipleChoice {question: details, update: update, edit: edit})

            else
              (div {className: 'viewing'}, "viewing")
              (QuestionSummary {question: question, update: update})
        )
