{div, h1, input, label, a} = ReactFactories

modulejs.define 'components/question_tracker/editor',
  [
    'components/question_tracker/text_input',
    'components/question_tracker/question_list',
    'components/question_tracker/master_question',
    'components/question-tracker/alert'
  ],
  (TextInputClass, QuestionsListClass, MasterQuestionClass, AlertClass) ->

    TextInput = React.createFactory TextInputClass
    QuestionList = React.createFactory QuestionsListClass
    MasterQuestion = React.createFactory MasterQuestionClass
    Alert = React.createFactory AlertClass

    createReactClass
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
          setTimeout (=> @_processAlertQueue()), 4000
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
            @setState(resp)

          error: =>
            @alert 'error', 'Save Failed!'


      update: (newState) ->
        @setState(newState, => @updateServer(@state))

      render: ->
        edit = true # edit = @state.edit
        (div {className: "question-tracker-editor"},
          (Alert {alert: @state.alert})
          (div {className: "navigation"},
            (h1 {}, "Tracked Question #{@state.name} (#{@state.id})")
            if @props.doneLink
              (a {id: "done-link", href: @props.doneLink, className: "done-link"}, "done")
          )
          (TextInput {name: "name", label: "Name:", value: @state.name, onChange: @update})
          (TextInput {name: "description", label: "Description:", value:@state.description, onChange: @update})
          (MasterQuestion {edit: true, question: @state.master_question, update: @update})
          (div {className: "use count"}, "Used in #{@state.questions.length} activities")
        )
