import { pluck } from 'underscore'
import { API } from '#app/api/api'
import app from '#app/app'
import preq from '#app/lib/preq'
import type { Notification } from '#server/types/notification'

let waitForNotifications
export let notifications: Notification[] = []

async function _getNotificationsData () {
  if (!app.user.loggedIn) return
  const { notifications: userNotifications } = await preq.get(API.notifications)
  notifications = userNotifications
}

export async function getNotificationsData () {
  waitForNotifications ??= _getNotificationsData()
  return notifications
}

export async function getNotificationsUnreadCount () {
  await getNotificationsData()
  return notifications.filter(notification => notification.status === 'unread').length
}

export function getNotificationText (type: Notification['type'], attribute?: string, newValue?: boolean) {
  if (attribute != null) {
    if (typeof texts[type][attribute] === 'string') return texts[type][attribute]
    else return texts[type][attribute][newValue]
  } else {
    return texts[type]
  }
}

const texts = {
  userMadeAdmin: 'user_made_admin',
  groupUpdate: {
    name: 'group_update_name',
    description: 'group_update_description',
    searchable: {
      true: 'group_update_searchable_true',
      false: 'group_update_searchable_false',
    },
    open: {
      true: 'group_update_open_true',
      false: 'group_update_open_false',
    },
  },
}

export async function markNotificationsAsRead (notifications: Notification[]) {
  notifications = notifications.filter(notification => notification.status === 'unread')
  if (notifications.length === 0) return
  const times = pluck(notifications, 'time')
  return preq.post(API.notifications, { times })
}
