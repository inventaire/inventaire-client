DonateMenu = require '../views/donate_menu'
FeedbackMenu = require '../views/feedback_menu'
Loader = require '../views/behaviors/loader'
# ShareMenu = require '../views/share_menu'

module.exports =
  showLoader: (options={})->
    { region, selector } = options
    if selector?
      loader = new Loader
      $(selector).html loader.render()
    else
      region or= app.layout.main
      region.show new Loader

  showEntity: (e)-> entityAction e, 'show:entity'
  showEntityEdit: (e)-> entityAction e, 'show:entity:edit'
  showDonateMenu: -> app.layout.modal.show new DonateMenu
  showFeedbackMenu: (options)->
    # In the case of 'show:feedback:menu', a unique object is passed
    # in which the event object is passed either directly
    # or as the value for the key 'event'
    event = options?.event or options
    # options might simply be a click event object
    unless _.isOpenedOutside event
      app.layout.modal.show new FeedbackMenu(options)

  # shareLink: -> app.layout.modal.show new ShareMenu

entityAction = (e, action)->
  href = e.currentTarget.href
  unless href? then throw new Error "couldnt #{action}: href not found"

  # If the link was Ctrl+clicked or if it was an external link with target='_blank',
  # typically, a link to a Wikidata entity page
  unless _.isOpenedOutside e
    # Any href arriving here should be of the form /entity/:uri(/:label)(/edit)
    [ uri ] = href.split('/entity/')[1].split '/'
    app.execute action, uri
