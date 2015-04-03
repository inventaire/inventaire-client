module.exports =
  startLoading: (options)->
    if _.isString(options) then options = {selector: options}
    @$el.trigger 'loading', options
  stopLoading: -> @$el.trigger 'stopLoading'
