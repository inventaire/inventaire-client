import { API } from '#app/api/api'
import preq from '#app/lib/preq'

export async function getNextTask (params) {
  const { entitiesType, offset, type } = params
  const { tasks } = await preq.get(API.tasks.byEntitiesType({
    type,
    'entities-type': entitiesType,
    offset,
  }))
  return tasks[0]
}
