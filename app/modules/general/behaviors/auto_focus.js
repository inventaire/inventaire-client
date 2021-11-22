import isMobile from 'lib/mobile_check'

// On view show, focus on the first focusable element.
// Should probably only be applied to main layouts or modals
export default Marionette.Behavior.extend({
  onRender () {
    // Do not auto focus on mobile as it displays the virtual keyboard
    // which can take pretty much all the screen
    if (isMobile) return
    const selector = this.options.selector || 'input,[tabindex=0]'
    this.view.$el.find(selector).first().focus()
  }
})
