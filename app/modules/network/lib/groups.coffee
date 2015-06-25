forms_ = require 'modules/general/lib/forms'

module.exports =
  validateName: (name, selector)->
    forms_.pass
      value: name
      tests: groupNameTests
      selector: selector

    return

  createGroup: (name)->
    { groups } = app.user

    _.preq.post app.API.groups,
      action: 'create'
      name: name
    .then groups.add.bind(groups)
    .then _.Log('group')
    .catch _.Error('group create')

groupNameTests =
  "groups name can't be longer than 60 characters": (name)->
    name.length > 60
