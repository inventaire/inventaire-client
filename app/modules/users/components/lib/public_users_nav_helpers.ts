import { API } from '#app/api/api'
import preq from '#app/lib/preq'
import type { BBox } from '#server/types/common'
import { serializeUser } from '#users/lib/users'

export async function getUsersByPosition ({ bbox }: { bbox: BBox }) {
  const usersById = {}
  const docs = await getDocsByPosition('users', bbox)
  for (const doc of docs) {
    if (usersById[doc._id] == null) {
      usersById[doc._id] = serializeUser(doc)
    }
  }
  return usersById
}

export async function getGroupsByPosition ({ bbox }: { bbox: BBox }) {
  const groupsById = {}
  const docs = await getDocsByPosition('groups', bbox)
  for (const doc of docs) {
    if (groupsById[doc._id] == null) {
      groupsById[doc._id] = doc
    }
  }
  return groupsById
}

export async function getDocsByPosition (name: 'users' | 'groups', bbox: BBox) {
  const { [name]: docs } = await preq.get(API[name].searchByPosition(bbox))
  return docs
}
