import friendAcceptedRequestTemplate from '../views/templates/friend_accepted_request.hbs'
import groupNotificationTemplate from '../views/templates/group_notification.hbs'
import friendAcceptedRequestModel from '../models/friend_accepted_request'
import groupNotificationModel from '../models/group_notification'

export const templates = {
  friendAcceptedRequest: friendAcceptedRequestTemplate,
  userMadeAdmin: groupNotificationTemplate,
  groupUpdate: groupNotificationTemplate
}

export const models = {
  friendAcceptedRequest: friendAcceptedRequestModel,
  userMadeAdmin: groupNotificationModel,
  groupUpdate: groupNotificationModel
}
