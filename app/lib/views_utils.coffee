module.exports.addMultipleSelectorEvents = ->
  @events ||= new Object
  if @multipleSelectorEvents?
    for selectorsString, handler of @multipleSelectorEvents
      selectors = selectorsString.split ' '
      event = selectors.shift()
      selectors.forEach (selector)=>
        @events["#{event} #{selector}"] = handler