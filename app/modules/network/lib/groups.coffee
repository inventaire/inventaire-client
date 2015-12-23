forms_ = require 'modules/general/lib/forms'

module.exports =

  createGroup: (name, description, searchable)->
    { groups } = app.user

    _.preq.post app.API.groups.private,
      action: 'create'
      name: name
      description: description
      searchable: searchable
    .then groups.add.bind(groups)
    .then _.Tap(app.execute.bind(app, 'track:group', 'create'))
    .then _.Log('group')
    .catch _.Error('group create')

  validateName: (name, selector)->
    forms_.pass
      value: name
      tests: groupNameTests
      selector: selector
    return

  validateDescription: (description, selector)->
    forms_.pass
      value: description
      tests: groupDescriptionTests
      selector: selector
    return

groupNameTests =
  "group name can't be longer than 60 characters": (name)->
    name.length > 60

groupDescriptionTests =
  "group description can't be longer than 5000 characters": (description)->
    description.length > 5000
