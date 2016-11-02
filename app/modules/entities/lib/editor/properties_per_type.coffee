# Keep in sync with app/modules/entities/lib/properties.coffee

module.exports =
  work: [
    # 'wdt:P31' # instance of (=> works aliases)
    'wdt:P50' # author
    # 'wdt:P110' # illustrator
    # 'wdt:P577' # publication date
    # 'wdt:P179' # series

    # 'wdt:P364' # original language of work
    # 'wdt:P1476' # title (using P364 lang)
    # 'wdt:P1680' # subtitle (using P364 lang)

    # 'wdt:P155' # follow
    # 'wdt:P156' # is follow by
    'wdt:P136' # genre
    'wdt:P921' # main subject
    # 'wdt:P840' # narrative location
    # 'wdt:P674' # characters
  ]
  edition: [
    # 'wdt:P31' # P31: instance of (=> edition aliases?)
    # P212 is used as unique ISBN field, accepting ISBN-10 but correcting server-side
    'wdt:P212' # ISBN-13
    'wdt:P957' # ISBN-10
    'wdt:P407' # language of work
  ]
