export default Marionette.Region.extend({
  attachHtml (view) {
    // uses the fake region el to have it's own el
    // inserted just after the fake region
    return $(view.el).insertAfter(this.$el)
  }
})
