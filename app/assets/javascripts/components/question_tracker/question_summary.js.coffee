{div, span} = ReactFactories

modulejs.define 'components/question_tracker/question_summary',[],() ->

  createReactClass

    key: ->
      "question_#{@props.question.id}"

    className: ->
      "question-summary"

    text: ->
      "#{@props.question.id} – #{@props.question.type} – #{@props.question.question.prompt}"

    render: ->
      (div {key: @key(), className: @className()}, @text())
