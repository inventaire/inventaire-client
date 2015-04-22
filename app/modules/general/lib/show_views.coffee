JoyrideWelcomeTour = require 'modules/welcome/views/joyride_welcome_tour'
FeedbacksMenu = require '../views/feedbacks_menu'
{ Loader } = app.View.Behaviors

module.exports =
  showLoader: (options)->
    [region, selector, title] = _.pickToArray options, ['region', 'selector', 'title']
    if region?
      region.Show new Loader, title
    else if selector?
      loader = new Loader
      $(selector).html loader.render()
      app.docTitle title  if title?
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

  showFeedbacksMenu: ->
    app.layout.modal.show new FeedbacksMenu

  copyLink: (e)->
    href = e.currentTarget.href
    unless href?
      throw new Error "couldnt showEntity: href not found"

    prompt 'link to copy & share', href
