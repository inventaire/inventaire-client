import { buildPath } from '#app/lib/location'
import type { QueryParams } from '#app/types/entity'
import type { RelativeUrl, Url } from '#server/types/common'

export function getEndpointBase (name: string) {
  return `/api/${name}` as RelativeUrl
}

export function getEndpointPathBuilders (name: string) {
  const base: Url = `/api/${name}`
  const action = actionFactory(base)
  const actionPartial = actionPartialFactory(action)
  return { base, action, actionPartial }
}

function actionFactory (base: Url) {
  return function (actionName: string, query: QueryParams = {}) {
    // Using extend instead of simply defining action on query
    // so that action appears above other attributes in the object
    // and thus, comes first in the generated URL
    return buildPath(base, Object.assign({ action: actionName }, query)) as Url
  }
}

// Pass an action name and an attribute, get a partial function
function actionPartialFactory (actionFn: ReturnType<typeof actionFactory>) {
  return function (actionName: string, attribute: string) {
    return function (value: string | number) {
      return actionFn(actionName, { [attribute]: value })
    }
  }
}
