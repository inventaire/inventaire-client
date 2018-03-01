# Prevent default click event behavior selectively

module.exports = (e)->
  # largely inspired by
  # https://github.com/jmeas/backbone.intercept/blob/master/src/backbone.intercept.js

  # Only intercept left-clicks
  if e.which isnt 1 then return

  # Don't intercept if ctrlKey is pressed
  # it should open the targeted anchor href in a new tab/window
  # Prevent the normal handler to also fire:
  # `unless _.isOpenedOutside(e) then handler()
  # Ignore missing href though, as this behavior is applied to some anchors
  # purposedly without anchor.Ex: visibility dropdown menus
  if _.isOpenedOutside(e, true) then return

  # If there is no href on current target, then the default
  # behaviour is to do nothing.
  # Therefore, there is no reason to preventDefault.
  if e.currentTarget?
    $link = $(e.currentTarget)
    # Get the href; stop processing if there isn't one
    href = $link.attr 'href'
    unless href then return

  # Return if the URL is absolute (thus with ://)
  # or if the protocol is mailto or javascript
  if /^#|javascript:|mailto:|(?:\w+:)?\/\//.test(href) then return

  # Return if the URL is an API call
  # Ex: Wikidata Oauth, data export, etc.
  if /^\/api\//.test(href) then return

  # If we haven't been stopped yet, then we prevent the default action
  e.preventDefault()
