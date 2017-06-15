module.exports = Marionette.Behavior.extend
  ui:
    dropdown: '.dropdown'

  events:
    'click .has-dropdown': 'toggleDropdown'

  toggleDropdown: (e)->
    $dropdown = $(e.currentTarget).find '.dropdown'
    isVisible = $dropdown.css('display') isnt 'none'
    if isVisible
      $dropdown.hide()
    else
      $dropdown.show()
      closeOnClick = => @listenToOnce app.vent, 'body:click', $dropdown.hide.bind($dropdown)
      # Let a delay so that the toggle click itself isn't catched by the listener
      setTimeout closeOnClick, 100
