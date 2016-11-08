JoyrideWelcomeTour = require 'modules/welcome/views/joyride_welcome_tour'
DonateMenu = require '../views/donate_menu'
FeedbackMenu = require '../views/feedback_menu'
# ShareMenu = require '../views/share_menu'
Loader = require '../views/behaviors/loader'

module.exports =
  showLoader: (options={})->
    [ region, selector, title ] = _.pickToArray options, ['region', 'selector', 'title']
    if region?
      region.Show new Loader, title
    else if selector?
      loader = new Loader
      $(selector).html loader.render()
      app.docTitle(title)  if title?
    else
      app.layout.main.Show new Loader, title

  showEntity: (e)-> entityAction e, 'show:entity'
  showEntityEdit: (e)-> entityAction e, 'show:entity:edit'
  showJoyrideWelcomeTour: -> @joyride.show new JoyrideWelcomeTour

  showDonateMenu: -> app.layout.modal.show new DonateMenu
  showFeedbackMenu: (options)-> app.layout.modal.show new FeedbackMenu(options)
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
