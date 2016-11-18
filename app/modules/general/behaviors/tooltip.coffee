module.exports = Marionette.Behavior.extend
  events:
    # Make sure that the click event bubble to elements below the tooltip.
    'click .diy-tooltip-content': (e)-> e.stopImmediatePropagation()
