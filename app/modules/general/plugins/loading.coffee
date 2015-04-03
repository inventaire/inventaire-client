module.exports =
  startLoading: -> @$el.trigger 'loading'
  stopLoading: -> @$el.trigger 'stopLoading'
