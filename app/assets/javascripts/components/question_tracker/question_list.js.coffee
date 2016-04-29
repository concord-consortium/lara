{div, input, label, span} = React.DOM

modulejs.define 'components/question_tracker/question_list',
  ['components/question_tracker/question_summary'],
  (QuestionSummaryClass) ->

    QuestionSummary = React.createFactory QuestionSummaryClass

    React.createClass
      render: ->
        edit = @props.edit
        questions = @props.questions
        (div {className: 'question-list'},
          if edit
            (div {className: 'edit'}, "editing")
            for question, i in questions
              (QuestionSummary {question: question, key: question.id})
          else
            (div {className: 'viewing'}, "viewing")
            for question, i in questions
              (QuestionSummary {question: question, key: question.id})
        )