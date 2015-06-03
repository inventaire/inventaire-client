# GENERAL RULE
# adding PreventDefault behavior is needed when a click event is catched by an event listener before app_layout unpreventDefault catchs it

module.exports = Marionette.Behavior.extend
  events:
    'click a': 'unpreventDefault'

  unpreventDefault: (e)->
    # largely inspired by
    # https://github.com/jmeas/backbone.intercept/blob/master/src/backbone.intercept.js

    # Only intercept left-clicks
    return  if e.which isnt 1

    # Don't intercept if ctrlKey is pressed
    # it should open the targeted anchor href in a new tab/window
    # Prevent the normal handler to also fire:
    # `unless _.isOpenedOutside(e) then handler()`
    return  if _.isOpenedOutside(e)

    $link = $(e.currentTarget)
    # Get the href; stop processing if there isn't one
    href = $link.attr("href")
    return  unless href

    # Return if the URL is absolute (thus with ://)
    # or if the protocol is mailto or javascript
    return  if /^#|javascript:|mailto:|(?:\w+:)?\/\//.test(href)

    # If we haven't been stopped yet, then we prevent the default action
    e.preventDefault()
