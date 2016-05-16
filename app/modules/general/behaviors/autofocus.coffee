# On view show, focus on the first focusable element.
# Should probably only be applied to main layouts or modals
module.exports = Marionette.Behavior.extend
  onShow: ->
    selector = @options.selector or 'input,[tabindex=0]'
    @view.$el.find(selector).first().focus()
