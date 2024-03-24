import preq from '#lib/preq'

export async function groupAction ({ action, groupId, userId }) {
  const res = await preq.put(app.API.groups.base, {
    action,
    group: groupId,
    // Required only for actions implying an other user
    user: userId
  })
  return res
}
