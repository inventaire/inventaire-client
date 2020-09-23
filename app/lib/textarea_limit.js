module.exports =
  updateLimit: (textareaEl, limitEl, limit)->
    currentLength = @ui[textareaEl].val().length
    if (currentLength / limit) > 0.9
      remaingCharacters = limit - currentLength
      counter = "<span class='counter'>#{remaingCharacters}</span>"
      text = "#{_.i18n('remaing characters:')} #{counter}"
      className = if remaingCharacters < 0 then 'exceeded' else 'good'
      @ui[limitEl].html "<p class='#{className}'>#{text}</p>"
    else
      @ui[limitEl].html '<p class="good"></p>'
