import DonateMenu from '../views/donate_menu'
import FeedbackMenu from '../views/feedback_menu'

export default {
  showLoader (options = {}) {
    const loader = '<div class="full-screen-loader"><div></div></div>'
    return $(app.layout.main.el).html(loader)
  },

  showEntity (e) {
    entityAction(e, 'show:entity')
    if (!_.isOpenedOutside(e)) {
      // Required to close the ItemShow modal if one was open
      return app.execute('modal:close')
    }
  },

  showEntityEdit (e) { return entityAction(e, 'show:entity:edit') },
  showEntityCleanup (e) { return entityAction(e, 'show:entity:cleanup') },
  showDonateMenu () {
    app.layout.modal.show(new DonateMenu({ navigateOnClose: true }))
    return app.navigate('donate')
  },

  showFeedbackMenu (options) {
    // In the case of 'show:feedback:menu', a unique object is passed
    // in which the event object is passed either directly
    // or as the value for the key 'event'
    // but options might also be a click event object
    const event = options?.event || options
    // Known case of missing href: #signalDataError anchors won't have an href
    const ignoreMissingHref = true
    if (!_.isOpenedOutside(event, ignoreMissingHref)) {
      if (!options) { options = {} }
      // Do not navigate as that's a  mess to go back then
      // and handle the feedback modals with or without dedicated pathnames
      return app.layout.modal.show(new FeedbackMenu(options))
    }
  }
}

var entityAction = function (e, action) {
  const {
    href
  } = e.currentTarget
  if (href == null) { throw new Error(`couldnt ${action}: href not found`) }

  // If the link was Ctrl+clicked or if it was an external link with target='_blank',
  // typically, a link to a Wikidata entity page
  if (!_.isOpenedOutside(e)) {
    // Any href arriving here should be of the form /entity/:uri(/:label)(/edit)
    const [ uri ] = Array.from(href.split('/entity/')[1].split('/'))
    app.execute(action, uri)
    return e.stopPropagation()
  }
}
