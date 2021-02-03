import log_ from 'lib/loggers'
import preq from 'lib/preq'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'

export default {
  createGroup (data) {
    const { name, description, searchable, open, position } = data
    const { groups } = app

    return preq.post(app.API.groups.base, {
      action: 'create',
      name,
      description,
      searchable,
      open,
      position
    })
    .then(groups.add.bind(groups))
    .then(log_.Info('group'))
    .catch(error_.Complete('#createGroup'))
  },

  validateName (name, selector) {
    forms_.pass({
      value: name,
      tests: groupNameTests,
      selector
    })
  },

  validateDescription (description, selector) {
    forms_.pass({
      value: description,
      tests: groupDescriptionTests,
      selector
    })
  }
}

const groupNameTests = {
  "group name can't be longer than 60 characters" (name) {
    return name.length > 60
  }
}

const groupDescriptionTests = {
  "group description can't be longer than 5000 characters" (description) {
    return description.length > 5000
  }
}
