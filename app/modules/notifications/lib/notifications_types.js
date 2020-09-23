const template = name => require(`../views/templates/${name}`);
const model = name => require(`../models/${name}`);
const groupNotificationTemplate = template('group_notification');
const groupNotificationModel = model('group_notification');

export let templates = {
  friendAcceptedRequest: template('friend_accepted_request'),
  userMadeAdmin: groupNotificationTemplate,
  groupUpdate: groupNotificationTemplate
};

export let models = {
  friendAcceptedRequest: model('friend_accepted_request'),
  userMadeAdmin: groupNotificationModel,
  groupUpdate: groupNotificationModel
};
