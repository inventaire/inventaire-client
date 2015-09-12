urls = require('lib/urls')
{ banner } = urls.images

module.exports = Marionette.ItemView.extend
  template: require './templates/joyride_welcome_tour'
  onShow: ->
    app.execute 'foundation:joyride:start',
      joyride:
        expose: true
        modal: false
        pre_step_callback : openHiddenParts
        post_step_callback : closeHiddenParts

    setTimeout @hackNubPositions.bind(@), 500

  serializeData: ->
    urls: urls
    banner: banner
    add:
      pointer: if _.smallScreen() then 'addIconButton' else 'addIconButtonTop'
      options: tipOptions
        prev_button: false
    network:
      pointer: if _.smallScreen() then 'networkIconButton' else 'networkIconButtonTop'
      options: tipOptions()

  hackNubPositions: ->
    # the tip nub doesn't follow the element position
    # so it needs to be pushed by hand
    if _.smallScreen()
      middle = elMiddle '#networkIconButton'
      $('.joyride-tip-guide[data-index="1"] .joyride-nub').css 'margin-left', middle

nubOffset = 22

elMiddle = (selector)->
  $button = $(selector)
  start = $button.offset().left
  end = $button.next().offset().left
  return (start + end) / 2 - nubOffset

tipOptions = (options={})->
  base =
    tip_location: if _.smallScreen() then 'bottom' else 'right'
    tip_animation: 'fade'

  _.log base, 'base'
  return _.extend base, options


openHiddenParts = ->
  id = @$target[0].id
  switch id
    when 'searchField' then openSmallScreenMenu()
    when 'editProfile' then openSettingsMenu()


closeHiddenParts = ->
  id = @$target[0].id
  switch id
    when 'editProfile' then closeSmallScreenSettingsMenu()

openSmallScreenMenu = ->
  # opens the menu on small screens
  # no effet on large ones
  $('.menu-icon').trigger('click')

openSettingsMenu = ->
  if _.smallScreen()
    $('#settingsMenu').find('a').first().trigger('click')
    reflow()
  else
    $('#settingsMenu').trigger('click')

closeSmallScreenSettingsMenu = ->
  if _.smallScreen()
    $('#settingsMenu').find('.back').trigger('click')

reflow = -> $(document).foundation('joyride', 'reflow')