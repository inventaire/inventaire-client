JoyrideWelcomeTour = require 'modules/welcome/views/joyride_welcome_tour'
DonateMenu = require '../views/donate_menu'
FeedbackMenu = require '../views/feedback_menu'
ShareMenu = require '../views/share_menu'
Loader = require '../views/behaviors/loader'

module.exports =
  showLoader: (options)->
    [region, selector, title] = _.pickToArray options, ['region', 'selector', 'title']
    if region?
      region.Show new Loader, title
    else if selector?
      loader = new Loader
      $(selector).html loader.render()
      app.docTitle(title)  if title?
    else
      app.layout.main.Show new Loader, title

  showEntity: (e)->
    href = e.currentTarget.href
    unless href?
      throw new Error "couldnt showEntity: href not found"

    unless _.isOpenedOutside(e)
      data = href.split('/entity/').last()
      [uri, label] = data.split '/'
      app.execute 'show:entity', uri, label


  showJoyrideWelcomeTour: -> @joyride.show new JoyrideWelcomeTour

  showDonateMenu: -> app.layout.modal.show new DonateMenu
  showFeedbackMenu: -> app.layout.modal.show new FeedbackMenu
  shareLink: -> app.layout.modal.show new ShareMenu
