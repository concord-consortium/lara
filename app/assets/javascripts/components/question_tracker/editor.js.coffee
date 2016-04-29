{div, input, label} = React.DOM

modulejs.define 'components/question_tracker/editor',
  [
    'components/question_tracker/text_input',
    'components/question_tracker/question_list',
    'components/question_tracker/master_question',
  ],
  (TextInputClass, QuestionsListClass, MasterQuestionClass) ->

    TextInput = React.createFactory TextInputClass
    QuestionList = React.createFactory QuestionsListClass
    MasterQuestion = React.createFactory MasterQuestionClass
    React.createClass
      componentWillMount: ->
        @alerts = []

      getInitialState: ->
        @props.initialState

      toggleEdit: ->
        @setState
          edit: not @state.edit

      _processAlertQueue: ->
        if @alerts.length > 0
          @setState alert: @alerts.shift()
          setTimeout (=> @_processAlertQueue()), 1000
        else
          @setState alert: null

      alert: (type, text, layout='bar') ->  # other layout option is 'pill'
        @alerts.push
          type: type
          text: text
          layout: layout
        @_processAlertQueue() if @alerts.length is 1

      updateServer:(state) ->
        $.ajax
          url: state.update_url
          type: 'PUT'
          dataType: 'json'
          contentType: 'application/json'
          data: JSON.stringify({
              _method: 'PUT'
              question_tracker: state
              id: state.id
            })
          success: (resp) =>
            @alert 'info', 'Saved'

          error: =>
            @alert 'error', 'Save Failed!'


      update: (newState) ->
        @setState(newState, => @updateServer(@state))

      render: ->
        (div {className: 'question-tracker-editor'},
          (div {className:'alert'}, @state.alert?.text)
          (div {onClick: @toggleEdit}, 'EDIT')
          if @state.edit
            (div {id: "editing", className: 'edit'},
              (div {}, "Editing")
              (div {}, "id #{@state.id}")
              (TextInput {name: 'name', label: "Name:", value: @state.name, onChange: @update})
              (TextInput {name: 'description', label: "Description:", value:@state.description, onChange: @update})
              (MasterQuestion {edit: true, question: @state.master_question, update: @update})
            )
          else
            (div {id: "showing", className: 'read-only'},
              (div {}, "id #{@state.id}" )
              (div {}, "name: #{@state.name}" )
              (div {}, "description: #{@state.description}")
              (MasterQuestion {edit: false, question: @state.master_question, update: @update})
            )
          (QuestionList {edit: false, questions: @state.questions })
        )