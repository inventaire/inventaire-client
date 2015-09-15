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

    _.preq.post app.API.groups.private,
      action: 'create'
      name: name
    .then groups.add.bind(groups)
    .then _.Tap(app.execute.bind(app, 'track:group', 'create'))
    .then _.Log('group')
    .catch _.Error('group create')

groupNameTests =
  "groups name can't be longer than 60 characters": (name)->
    name.length > 60
