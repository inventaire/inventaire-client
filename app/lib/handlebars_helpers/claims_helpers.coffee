entityValue = require 'modules/general/views/behaviors/templates/entity_value'
propertyValue = require 'modules/general/views/behaviors/templates/property_value'
{ SafeString, escapeExpression } = Handlebars
wdk = require 'lib/wikidata-sdk'
error_ = require 'lib/error'

prop = (uri)->
  # Be more restrictive on the input to be able to use it in SafeStrings
  if /^wdt:P\d+$/.test uri then propertyValue { uri }
  else if wdk.isWikidataPropertyId(uri) then propertyValue { uri: "wdt:#{uri}" }

entity = (uri, entityLink, alt, property, title)->
  # Be restricting on the input to be able to use it in SafeStrings
  unless wdk.isWikidataItemId(uri) or _.isEntityUri(uri)
    throw error_.new 'invalid entity uri', 500, { uri }

  unless typeof alt is 'string' then alt = ''
  app.execute 'uriLabel:update'
  alt = escapeExpression alt

  if not property? or property in propertyWithSpecialLayout
    pathname = "/entity/#{uri}"
  else
    pathname = "/entity/#{property}-#{uri}"

  return entityValue { uri, pathname, entityLink, alt, label: alt, title }

propertyWithSpecialLayout = [
  'wdt:P50' # author
  'wdt:P179' # serie
  'wdt:P629' # work
  'wdt:P123' # publisher
]

module.exports =
  prop: prop
  entity: entity
  # handlebars pass a sometime confusing {data:, hash: object} as last argument
  # this method is used to make helpers less error-prone by removing this object
  neutralizeDataObject: (args)->
    last = _.last args
    if last?.hash? and last.data? then args[0...-1]
    else args

  getValuesTemplates: (valueArray, entityLink, property)->
    # prevent any null value to sneak in
    _.compact valueArray
    .map (uri)-> entity(uri, entityLink, null, property).trim()
    .join ', '

  labelString: (pid, omitLabel)->
    if omitLabel then '' else prop pid

  claimString: (label, values, inline)->
    text = "#{label} #{values}"
    unless inline then text += ' <br>'
    return new SafeString text
