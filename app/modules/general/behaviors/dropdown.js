export default Marionette.Behavior.extend({
  events: {
    'click [aria-haspopup="menu"]': 'toggleDropdown'
  },

  toggleDropdown (e) {
    const $dropdownButton = $(e.currentTarget)
    const isDisabled = $dropdownButton.hasClass('disabled')
    if (!$dropdownButton.parent().hasClass('dropdown-wrapper')) throw new Error('dropdown wrapper not found')
    const $dropdown = $dropdownButton.parent().find('[role="menu"]')
    const isVisible = $dropdown.css('display') !== 'none'
    if (isVisible) {
      hide($dropdown)
      $dropdownButton.attr('aria-expanded', 'false')
    } else if (!isDisabled) {
      show($dropdown)
      $dropdownButton.attr('aria-expanded', 'true')
      // Let a delay so that the toggle click itself isn't catched by the listener
      this.view.setTimeout(closeOnClick.bind(this, $dropdown), 100)
    }
  }
})

const hide = function ($dropdown) {
  $dropdown.hide()
  $dropdown.removeClass('hover')
}

const show = function ($dropdown) {
  $dropdown.show()
  $dropdown.addClass('hover')
}

const closeOnClick = function ($dropdown) {
  this.listenToOnce(app.vent, 'body:click', hide.bind(null, $dropdown))
}
