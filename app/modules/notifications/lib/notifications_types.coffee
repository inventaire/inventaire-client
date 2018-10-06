template = (name)-> require "../views/templates/#{name}"
model = (name)-> require "../models/#{name}"
groupNotificationTemplate = template 'group_notification'
groupNotificationModel = model 'group_notification'

module.exports =
  templates:
    friendAcceptedRequest: template 'friend_accepted_request'
    userMadeAdmin: groupNotificationTemplate
    groupUpdate: groupNotificationTemplate
  models:
    friendAcceptedRequest: model 'friend_accepted_request'
    userMadeAdmin: groupNotificationModel
    groupUpdate: groupNotificationModel
