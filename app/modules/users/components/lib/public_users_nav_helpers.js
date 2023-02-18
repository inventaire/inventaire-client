import preq from '#lib/preq'
import { isValidBbox } from '#map/lib/map'
import { serializeUser } from '#users/lib/users'

export async function getUsersByPosition ({ bbox, usersById }) {
  const docs = await getDocsByPosition('users', bbox)
  for (const doc of docs) {
    if (usersById[doc._id] == null) {
      usersById[doc._id] = serializeUser(doc)
    }
  }
  return usersById
}

export async function getGroupsByPosition ({ bbox, groupsById }) {
  const docs = await getDocsByPosition('groups', bbox)
  for (const doc of docs) {
    if (groupsById[doc._id] == null) {
      groupsById[doc._id] = doc
    }
  }
  return groupsById
}

async function getDocsByPosition (name, bbox) {
  if (!isValidBbox(bbox)) throw new Error(`invalid bbox: ${bbox}`)
  const { [name]: docs } = await preq.get(app.API[name].searchByPosition(bbox))
  return docs
}

export const docIsInBounds = bounds => doc => {
  if (!bounds) return false
  return bounds.contains(doc.position)
}
