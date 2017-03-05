# build the endpoints routes
module.exports = (name, getBaseOnly)->
  base = "/api/#{name}"
  if getBaseOnly then return base
  action = ActionBuilder base
  return { base, action, actionPartial }

ActionBuilder = (base)-> (actionName, attribute, value)->
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
  url = _.buildPath base, _.extend({ action: actionName }, query)
  return _.log url, "#{actionName} URL"

# Pass an (action name) or (an action name and an attribute),
# get a partial function
actionPartial = (action)-> (args...)->
  args = [ null ].concat args
  return action.bind.apply null, args
