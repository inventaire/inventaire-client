const template = name => require(`../views/templates/${name}.hbs`)
const model = name => require(`../models/${name}`)
const groupNotificationTemplate = template('group_notification')
const groupNotificationModel = model('group_notification')

export const templates = {
  friendAcceptedRequest: template('friend_accepted_request'),
  userMadeAdmin: groupNotificationTemplate,
  groupUpdate: groupNotificationTemplate
}

export const models = {
  friendAcceptedRequest: model('friend_accepted_request'),
  userMadeAdmin: groupNotificationModel,
  groupUpdate: groupNotificationModel
}
