export default function() {

  let categories, name;
  const cache = {};

  const all = function(name, categories){
    if (!categories) { categories = name; }
    return cache[name] || recalculateAll(name, categories);
  };

  // locking the context for use here-after
  const getUsersIds = this.getUsersIds.bind(this);

  var recalculateAll = function(name, categories){
    categories = _.forceArray(categories);
    const ids = _.chain(categories).map(getUsersIds).flatten().value();
    return cache[name] = ids;
  };

  for (name in aggregates) {
    categories = aggregates[name];
    const Name = _.capitalise(name);
    // ex: @allMembersIds
    this[`all${Name}Ids`] = all.bind(this, name, categories);
  }

  return this.recalculateAllLists = () => (() => {
    const result = [];
    for (name in aggregates) {
      categories = aggregates[name];
      result.push(recalculateAll(name, categories));
    }
    return result;
  })();
};

var aggregates = {
  admins: 'admins',
  membersStrict: 'members',
  members: ['admins', 'members'],
  invited: 'invited',
  requested: 'requested'
};
