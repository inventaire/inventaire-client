propObj = (property, multivalue=true, allowEntityCreation=false)->
  property: property
  multivalue: multivalue
  allowEntityCreation: allowEntityCreation

module.exports =
  book: [
    # instance of (=> books aliases)
    # propObj 'wdt:P31', true
    # author
    propObj 'wdt:P50', true, true
    # illustrator
    # propObj 'wdt:P110', true
    # publication date
    # propObj 'wdt:P577', false
    # series
    # propObj 'wdt:P179', false

    # original language of work
    # propObj 'wdt:P364', false
    # title (using P364 lang)
    # propObj 'wdt:P1476', false
    # subtitle (using P364 lang)
    # propObj 'wdt:P1680', false

    # follow
    # propObj 'wdt:P155', false
    # is follow by
    # propObj 'wdt:P156', false
    # genre
    propObj 'wdt:P136', true, false
    # main subject
    # propObj 'wdt:P921', true
    # narrative location
    # propObj 'wdt:P840', true
    # characters
    # propObj 'wdt:P674', true
  ]
  edition: [
    # instance of (=> edition aliases?)
    # P31:
    # propObj 'wdt:P31', true
    # ISBN-13
    propObj 'wdt:P212', false
    # ISBN-10
    propObj 'wdt:P957', false
    # language of work
    propObj 'wdt:P407', true
  ]
