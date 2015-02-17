$ ->
  debugger
  $(document).on 'submit', '.score_mapping_form', (event) ->
    form_data = $(this).serializeArray()
    i = 0
    while i < form_data.length
      if form_data[i].name == 'c_rater_score_mapping[description]' and form_data[i].value == ''
        event.preventDefault()
        alert 'Please enter Title text.'
        $('#c_rater_score_mapping_description').focus()
        return
      if form_data[i].value == ''
        if confirm('You have not entered score mapping text for all the scores.Do you still want to save?')
          return
        else
          event.preventDefault()
          return
      i++
    return
  return