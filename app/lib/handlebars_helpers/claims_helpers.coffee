wdQ = require 'modules/general/views/behaviors/templates/wikidata_Q'
wdP = require 'modules/general/views/behaviors/templates/wikidata_P'
{ SafeString, escapeExpression } = Handlebars

P = (id)->
  if /^P[0-9]+$/.test id then wdP {id: id}
  else wdP {id: "P#{id}"}

Q = (id, linkify, alt)->
  if id?
    unless typeof alt is 'string' then alt = ''
    app.execute 'qlabel:update'
    alt = escapeExpression alt
    return wdQ {id: id, linkify: linkify, alt: alt, label: alt}

module.exports =
  P: P
  Q: Q
  # handlebars pass a sometime confusing {data:, hash: object} as last argument
  # this method is used to make helpers less error-prone by removing this object
  neutralizeDataObject: (args)->
    last = args.last()
    if last?.hash? and last.data? then args[0...-1]
    else args

  getQsTemplates: (valueArray, linkify)->
    # prevent any null value to sneak in
    _.compact valueArray
    .map (id)-> Q(id, linkify).trim()
    .join ', '

  labelString: (pid, omitLabel)->
    if omitLabel then '' else P pid

  claimString: (label, values, inline)->
    text = "#{label} #{values}"
    unless inline then text += ' <br>'
    return new SafeString text
