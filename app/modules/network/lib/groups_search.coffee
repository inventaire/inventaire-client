module.exports = (groups)->

  filtered = new FilteredCollection groups

  queried = []

  searchByText = (text)->
    queryIfNeeded text
    .then addGroupsAndFilterByText.bind(null, text)
    .catch (err)->
      # removing text from the list of past queries
      # to allow it to be re-queried
      queried = _.without queried, text
      throw err

  queryIfNeeded = (text)->
    noQueryNeeded = text in queried or text is ''
    if noQueryNeeded then Promise.resolve false
    else
      queried.push text
      _.preq.get app.API.groups.search(text)

  addGroupsAndFilterByText = (text, groupsData)->
    if groupsData then groups.add groupsData
    filtered.filterByText text

  searchByPosition = (bbox)->
    _.preq.get app.API.groups.searchByPosition(bbox)
    .then _.Log('groups by position')
    .then addGroupsUnlessHere

  addGroupsUnlessHere = (groups)->
    app.request 'waitForData'
    .then ->
      for group in groups
        addGroupUnlessHere group
      return

  addGroupUnlessHere = (group)->
    { _id } = group
    unless app.user.groups.byId(_id)?
      app.user.groups.add group

  filtered.searchByText = _.debounce searchByText, 200
  filtered.searchByPosition = searchByPosition

  app.reqres.setHandlers
    # return a filtered collection
    'group:search:byName': searchByText

  return filtered
