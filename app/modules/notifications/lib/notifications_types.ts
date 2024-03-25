import friendAcceptedRequestModel from '../models/friend_accepted_request.ts'
import groupNotificationModel from '../models/group_notification.ts'
import friendAcceptedRequestTemplate from '../views/templates/friend_accepted_request.hbs'
import groupNotificationTemplate from '../views/templates/group_notification.hbs'

export const templates = {
  friendAcceptedRequest: friendAcceptedRequestTemplate,
  userMadeAdmin: groupNotificationTemplate,
  groupUpdate: groupNotificationTemplate,
}

export const models = {
  friendAcceptedRequest: friendAcceptedRequestModel,
  userMadeAdmin: groupNotificationModel,
  groupUpdate: groupNotificationModel,
}
