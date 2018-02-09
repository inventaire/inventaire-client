module.exports = Marionette.Behavior.extend
  ui:
    extract: '.extract'
    togglers: '.toggler i'

  events:
    'click .toggler': 'toggleExtractLength'

  toggleExtractLength: ->
    @ui.extract.toggleClass 'clamped'
    @ui.togglers.toggleClass 'hidden'
