import { forceArray } from 'lib/utils'
export default function () {
  let categories, name
  const cache = {}

  const all = function (name, categories) {
    if (!categories) { categories = name }
    return cache[name] || recalculateAll(name, categories)
  }

  // locking the context for use here-after
  const getUsersIds = this.getUsersIds.bind(this)

  const recalculateAll = function (name, categories) {
    categories = forceArray(categories)
    const ids = _.chain(categories).map(getUsersIds).flatten().value()
    cache[name] = ids
    return cache[name]
  }

  for (name in aggregates) {
    categories = aggregates[name]
    const Name = _.capitalise(name)
    // ex: @allMembersIds
    this[`all${Name}Ids`] = all.bind(this, name, categories)
  }

  this.recalculateAllLists = () => {
    for (name in aggregates) {
      categories = aggregates[name]
      recalculateAll(name, categories)
    }
  }
}

const aggregates = {
  admins: 'admins',
  membersStrict: 'members',
  members: [ 'admins', 'members' ],
  invited: 'invited',
  requested: 'requested'
}
