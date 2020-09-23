import forms_ from 'modules/general/lib/forms';
import error_ from 'lib/error';

export default {
  createGroup(data){
    const { name, description, searchable, position } = data;
    const { groups } = app;

    return _.preq.post(app.API.groups.base, {
      action: 'create',
      name,
      description,
      searchable,
      position
    }).then(groups.add.bind(groups))
    .then(_.Log('group'))
    .catch(error_.Complete('#createGroup'));
  },

  validateName(name, selector){
    forms_.pass({
      value: name,
      tests: groupNameTests,
      selector
    });
  },

  validateDescription(description, selector){
    forms_.pass({
      value: description,
      tests: groupDescriptionTests,
      selector
    });
  }
};

var groupNameTests = {
  "group name can't be longer than 60 characters"(name){
    return name.length > 60;
  }
};

var groupDescriptionTests = {
  "group description can't be longer than 5000 characters"(description){
    return description.length > 5000;
  }
};
