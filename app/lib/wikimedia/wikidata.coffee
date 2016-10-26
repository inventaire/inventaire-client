preq = requireProxy 'lib/preq'
wd_ = sharedLib('wikidata')(preq, _)

module.exports = _.extend wd_,
  # It sometimes happen that a Wikidata label is a direct copy of the Wikipedia
  # title, which can then have desambiguating parenthesis: we got to drop those
  formatLabel: (label)-> label.replace /\s\(.*\)$/, ''

  # wd_.getLabel is defined in app/lib/uri_label/uri_label.coffee
