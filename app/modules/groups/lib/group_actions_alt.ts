import { API } from '#app/api/api'
import preq from '#app/lib/preq'
import type { GroupId } from '#server/types/group'
import type { UserId } from '#server/types/user'

export async function groupAction ({ action, groupId, userId }: { action: string, groupId: GroupId, userId?: UserId }) {
  const res = await preq.put(API.groups.base, {
    action,
    group: groupId,
    // Required only for actions implying an other user
    user: userId,
  })
  return res
}
