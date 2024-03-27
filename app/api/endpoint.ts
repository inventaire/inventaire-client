import { buildPath } from '#lib/location'

export function getEndpointBase (name: string) {
  return `/api/${name}`
}

export function getEndpointPathBuilders (name: string) {
  const base = `/api/${name}`
  const action = Action(base)
  const actionPartial = ActionPartial(action)
  return { base, action, actionPartial }
}

const Action = (base: string) => function (actionName: string, query: Record<string, unknown> = {}) {
  // Using extend instead of simply defining action on query
  // so that action appears on top of other attributes in the object
  // and thus, comes first in the generated URL
  return buildPath(base, Object.assign({ action: actionName }, query))
}

// Pass an action name and an attribute, get a partial function
const ActionPartial = actionFn => (actionName, attribute) => value => actionFn(actionName, attribute, value)
