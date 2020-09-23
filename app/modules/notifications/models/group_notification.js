/* eslint-disable
    import/no-duplicates,
    no-undef,
    no-unused-expressions,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
// used for: userMadeAdmin, groupUpdate (name, description)

import Notification from './notification'

const { escapeExpression } = Handlebars

export default Notification.extend({
  initSpecific () {
    this.groupId = this.get('data.group')
    return this.grabAttributesModels('group', 'user')
  },

  serializeData () {
    let attrs = this.toJSON()
    attrs.username = this.user?.get('username')
    attrs = getUpdateValue(attrs)
    attrs.pathname = `/network/groups/${this.groupId}`
    if (this.group != null) {
      attrs.picture = this.group.get('picture')
      attrs.groupName = this.group.get('name')
      attrs.text = getText(attrs.type, attrs.data.attribute)
      attrs.previousValue
    }
    return attrs
  }
})

var getText = function (type, attribute) {
  if (attribute != null) {
    return texts[type][attribute]
  } else { return texts[type] }
}

var texts = {
  userMadeAdmin: 'user_made_admin',
  groupUpdate: {
    name: 'group_update_name',
    description: 'group_update_description'
  }
}

var getUpdateValue = function (attrs) {
  const { previousValue, newValue } = attrs.data
  if (previousValue != null) {
    attrs.previousValue = escapeExpression(previousValue)
    attrs.newValue = escapeExpression(newValue)
  }
  return attrs
}
