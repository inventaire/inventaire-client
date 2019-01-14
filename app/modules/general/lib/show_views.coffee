DonateMenu = require '../views/donate_menu'
FeedbackMenu = require '../views/feedback_menu'
Loader = require '../views/behaviors/loader'

entityAction = (action)-> (e)->
  { href } = e.currentTarget
  unless href? then throw new Error "couldnt #{action}: href not found"

  # If the link was Ctrl+clicked or if it was an external link with target='_blank',
  # typically, a link to a Wikidata entity page
  unless _.isOpenedOutside e
    # Any href arriving here should be of the form /entity/:uri(/:label)(/edit)
    [ uri ] = href.split('/entity/')[1].split '/'
    app.execute action, uri
    e.stopPropagation()

module.exports =
  showLoader: (options = {})->
    { region, selector } = options
    if selector?
      loader = new Loader
      $(selector).html loader.render()
    else
      region or= app.layout.main
      region.show new Loader

  showEntity: entityAction 'show:entity'
  showEntityEdit: entityAction 'show:entity:edit'
  showEntityCleanup: entityAction 'show:entity:cleanup'
  showEntityHistory: entityAction 'show:entity:history'
  showDonateMenu: ->
    app.layout.modal.show new DonateMenu { navigateOnClose: true }
    app.navigate 'donate'

  showFeedbackMenu: (options)->
    # In the case of 'show:feedback:menu', a unique object is passed
    # in which the event object is passed either directly
    # or as the value for the key 'event'
    event = options?.event or options
    if options.minimal or not _.isOpenedOutside event
      options or= {}
      options.navigateOnClose = not options.minimal
      app.layout.modal.show new FeedbackMenu(options)
      unless options.minimal then app.navigate 'feedback'
