import preq from '#lib/preq'

export async function updateRelationStatus ({ user, action }) {
  const { _id: userId } = user
  return preq.post(app.API.relations, { action, user: userId })
}
