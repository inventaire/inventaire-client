module.exports = Marionette.ItemView.extend
  template: require './templates/joyride_welcome_tour'
  onShow: ->
    options =
      joyride:
        expose: true
        modal: false
        pre_step_callback : openHiddenParts
        post_step_callback : closeHiddenParts

    app.execute 'foundation:joyride:start', options

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