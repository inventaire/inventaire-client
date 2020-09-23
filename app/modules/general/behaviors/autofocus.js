# On view show, focus on the first focusable element.
# Should probably only be applied to main layouts or modals
module.exports = Marionette.Behavior.extend
  onShow: ->
    # Do not auto focus on mobile as it displays the virtual keyboard
    # which can take pretty much all the screen
    if _.isMobile then return
    selector = @options.selector or 'input,[tabindex=0]'
    @view.$el.find(selector).first().focus()
