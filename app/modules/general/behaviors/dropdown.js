/* eslint-disable
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.Behavior.extend({
  ui: {
    dropdown: '.dropdown'
  },

  events: {
    'click .has-dropdown': 'toggleDropdown'
  },

  toggleDropdown (e) {
    const $hasDropdown = $(e.currentTarget)
    const isDisabled = $hasDropdown.hasClass('disabled')
    const $dropdown = $hasDropdown.find('.dropdown')
    const isVisible = $dropdown.css('display') !== 'none'
    if (isVisible) {
      return hide($dropdown)
    } else if (!isDisabled) {
      show($dropdown)
      // Let a delay so that the toggle click itself isn't catched by the listener
      return this.view.setTimeout(closeOnClick.bind(this, $dropdown), 100)
    }
  }
})

var hide = function ($dropdown) {
  $dropdown.hide()
  return $dropdown.removeClass('hover')
}

var show = function ($dropdown) {
  $dropdown.show()
  return $dropdown.addClass('hover')
}

var closeOnClick = function ($dropdown) {
  return this.listenToOnce(app.vent, 'body:click', hide.bind(null, $dropdown))
}
