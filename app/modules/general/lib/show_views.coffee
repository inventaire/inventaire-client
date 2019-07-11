DonateMenu = require '../views/donate_menu'
FeedbackMenu = require '../views/feedback_menu'

module.exports =
  showLoader: (options = {})->
    loader = '<div class="full-screen-loader"><div></div></div>'
    $(app.layout.main.el).html loader

  showEntity: (e)-> entityAction e, 'show:entity'
  showEntityEdit: (e)-> entityAction e, 'show:entity:edit'
  showEntityCleanup: (e)-> entityAction e, 'show:entity:cleanup'
  showDonateMenu: ->
    app.layout.modal.show new DonateMenu { navigateOnClose: true }
    app.navigate 'donate'

  showFeedbackMenu: (options)->
    # In the case of 'show:feedback:menu', a unique object is passed
    # in which the event object is passed either directly
    # or as the value for the key 'event'
    # but options might also be a click event object
    event = options?.event or options
    # Known case of missing href: #signalDataError anchors won't have an href
    ignoreMissingHref = true
    unless _.isOpenedOutside event, ignoreMissingHref
      options or= {}
      # Do not navigate as that's a  mess to go back then
      # and handle the feedback modals with or without dedicated pathnames
      app.layout.modal.show new FeedbackMenu(options)

entityAction = (e, action)->
  href = e.currentTarget.href
  unless href? then throw new Error "couldnt #{action}: href not found"

  # If the link was Ctrl+clicked or if it was an external link with target='_blank',
  # typically, a link to a Wikidata entity page
  unless _.isOpenedOutside e
    # Any href arriving here should be of the form /entity/:uri(/:label)(/edit)
    [ uri ] = href.split('/entity/')[1].split '/'
    app.execute action, uri
    e.stopPropagation()
