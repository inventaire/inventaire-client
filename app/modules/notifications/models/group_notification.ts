// used for: userMadeAdmin, groupUpdate (name, description)

import Handlebars from 'handlebars/runtime'
import Notification from './notification.ts'

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
      attrs.text = getText(attrs.type, attrs.data.attribute, attrs.newValue)
    }
    return attrs
  },
})

const getText = function (type, attribute, newValue) {
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

const getUpdateValue = function (attrs) {
  const { previousValue, newValue } = attrs.data
  if (previousValue != null) {
    attrs.previousValue = escapeExpression(previousValue)
    attrs.newValue = escapeExpression(newValue)
  }
  return attrs
}
