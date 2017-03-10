# build the endpoints routes
module.exports = (name, getBaseOnly)->
  base = "/api/#{name}"
  if getBaseOnly then return base
  action = Action base
  actionPartial = ActionPartial action
  return { base, action, actionPartial }

Action = (base)-> (actionName, attribute, value)->
  # Polymorphism: accept one attribute and one value OR a query object
  # NB: object values aren't passed to encodeURIComponent
  if _.isObject attribute
    query = attribute
  else
    query = {}
    if attribute? then query[attribute] = _.fixedEncodeURIComponent value

  query or= {}
  # Using extend instead of simply defining action on query
  # so that action appears on top of other attributes in the object
  # and thus, comes first in the generated URL
  return _.buildPath base, _.extend({ action: actionName }, query)

# Pass an action name and an attribute, get a partial function
ActionPartial = (actionFn)-> (actionName, attribute)-> (value)->
  actionFn actionName, attribute, value
