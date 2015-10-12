template = (name)-> require "../views/templates/#{name}"
model = (name)-> require "../models/#{name}"
groupNotificationTemplate = template 'group_notification'
groupNotificationModel = model 'group_notification'

module.exports =
  templates:
    friendAcceptedRequest: template 'friend_accepted_request'
    newCommentOnFollowedItem: template 'new_comment_on_followed_item'
    userMadeAdmin: groupNotificationTemplate
    groupUpdate: groupNotificationTemplate
  models:
    friendAcceptedRequest: model 'friend_accepted_request'
    newCommentOnFollowedItem: model 'new_comment_on_followed_item'
    userMadeAdmin: groupNotificationModel
    groupUpdate: groupNotificationModel
