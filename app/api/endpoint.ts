import { fixedEncodeURIComponent } from '#lib/utils'
import { buildPath } from '#lib/location'

// build the endpoints routes
export default function (name, getBaseOnly) {
  const base = `/api/${name}`
  if (getBaseOnly) return base
  const action = Action(base)
  const actionPartial = ActionPartial(action)
  return { base, action, actionPartial }
}

const Action = base => function (actionName, attribute, value) {
  // Polymorphism: accept one attribute and one value OR a query object
  // NB: object values aren't passed to encodeURIComponent
  let query
  if (_.isObject(attribute)) {
    query = attribute
  } else {
    query = {}
    if (attribute != null) query[attribute] = fixedEncodeURIComponent(value)
  }

  if (!query) query = {}
  // Using extend instead of simply defining action on query
  // so that action appears on top of other attributes in the object
  // and thus, comes first in the generated URL
  return buildPath(base, _.extend({ action: actionName }, query))
}

// Pass an action name and an attribute, get a partial function
const ActionPartial = actionFn => (actionName, attribute) => value => actionFn(actionName, attribute, value)
