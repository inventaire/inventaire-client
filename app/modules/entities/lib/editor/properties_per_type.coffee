# Keep in sync with app/modules/entities/lib/properties.coffee
# and server/controllers/entities/lib/properties.coffee

commonsSeriesWorks =
  'wdt:P50': {} # author
  'wdt:P136': {} # genre
  'wdt:P921': {} # main subject
  # 'wdt:P840': {} # narrative location
  # 'wdt:P674': {} # characters

module.exports = propertiesPerType =
  work: _.extend {}, commonsSeriesWorks,
    # 'wdt:P31: {}' # instance of (=> works aliases)
    'wdt:P577': {} # publication date
    # 'wdt:P110': {} # illustrator
    'wdt:P179': {} # series
    'wdt:P364': {} # original language of work
    # 'wdt:P1476': {} # title (using P364 lang)
    # 'wdt:P1680': {} # subtitle (using P364 lang)
    # 'wdt:P155': {} # follow
    # 'wdt:P156': {} # is follow by

    # Reverse properties
    'wdt:P747': { customLabel: 'editions' } # editions (inverse of wdt:P629)

  edition:
    'wdt:P1476': { customLabel: 'edition title' }
    'wdt:P407': { customLabel: 'edition language' }
    'wdt:P629': {} # edition or translation of
    # 'wdt:P31': {} # P31: instance of (=> edition aliases?)
    # P212 is used as unique ISBN field, accepting ISBN-10 but correcting server-side
    'wdt:P212': {} # ISBN-13
    'wdt:P957': {} # ISBN-10
    'wdt:P577': {} # publication date
    'wdt:P123': {} # publisher
    'wdt:P1104': {} # number of pages

  human:
    'wdt:P1412': {} # languages of expression
    'wdt:P135': {} # movement
    'wdt:P136': {} # genres
    'wdt:P569': {} # date of birth
    'wdt:P570': {} # date of death
    'wdt:P737': {} # influenced by

  serie: commonsSeriesWorks
