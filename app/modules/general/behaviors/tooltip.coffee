showViews = require 'modules/general/lib/show_views'

module.exports = Marionette.Behavior.extend
  events:
    # Make sure that the click event bubble to elements below the tooltip.
    'click .diy-tooltip-content': (e)-> e.stopImmediatePropagation()
    # As we stop the propagation, we need to proxy the global events needed on the tooltip
    'click a.showEntity': 'showEntity'

  showEntity: showViews.showEntity
