# Keep in sync with app/modules/entities/lib/properties.coffee
# and server/controllers/entities/lib/properties.coffee

work =
  'wdt:P50': {} # author
  'wdt:P577': {} # publication date
  'wdt:P136': {} # genre
  'wdt:P179': {} # series
  'wdt:P1545': {} # series ordinal
  'wdt:P921': {} # main subject
  'wdt:P364': {} # original language of work
  # 'wdt:P31: {}' # instance of (=> works aliases)
  # 'wdt:P110': {} # illustrator
  # 'wdt:P1476': {} # title (using P364 lang)
  # 'wdt:P1680': {} # subtitle (using P364 lang)
  # 'wdt:P840': {} # narrative location
  # 'wdt:P674': {} # characters

  # Reverse properties
  'wdt:P747': { customLabel: 'editions' } # editions (inverse of wdt:P629)

module.exports = (_)->
  work: work
  edition:
    'wdt:P629': {} # edition or translation of
    'wdt:P1476': { customLabel: 'edition title' }
    'wdt:P407': { customLabel: 'edition language' }
    'wdt:P18': { customLabel: 'cover' }
    # 'wdt:P31': {} # P31: instance of (=> edition aliases?)
    # P212 is used as unique ISBN field, accepting ISBN-10 but correcting server-side
    'wdt:P212': {} # ISBN-13
    'wdt:P957': {} # ISBN-10
    'wdt:P577': {} # publication date
    'wdt:P123': {} # publisher
    'wdt:P1104': {} # number of pages
    'wdt:P2679': {} # author of foreword
    'wdt:P2680': {} # author of afterword

  human:
    'wdt:P1412': {} # languages of expression
    'wdt:P135': {} # movement
    'wdt:P569': {} # date of birth
    'wdt:P570': {} # date of death
    'wdt:P737': {} # influenced by

  # Using omit instead of having a common list, extended for works, so that
  # the properties order isn't constrained by being part or not of the common properties
  serie: _.omit work, [ 'wdt:P179', 'wdt:P1545', 'wdt:P747' ]
