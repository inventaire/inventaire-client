module.exports = Marionette.Behavior.extend
  ui:
    dropdown: '.dropdown'

  events:
    'click .has-dropdown': 'toggleDropdown'

  toggleDropdown: (e)->
    $hasDropdown = $(e.currentTarget)
    isDisabled = $hasDropdown.hasClass 'disabled'
    $dropdown = $hasDropdown.find '.dropdown'
    isVisible = $dropdown.css('display') isnt 'none'
    if isVisible
      hide $dropdown
    else if not isDisabled
      show $dropdown
      # Let a delay so that the toggle click itself isn't catched by the listener
      @view.setTimeout closeOnClick.bind(@, $dropdown), 100

hide = ($dropdown)->
  $dropdown.hide()
  $dropdown.removeClass 'hover'

show = ($dropdown)->
  $dropdown.show()
  $dropdown.addClass 'hover'

closeOnClick = ($dropdown)->
  @listenToOnce app.vent, 'body:click', hide.bind(null, $dropdown)
