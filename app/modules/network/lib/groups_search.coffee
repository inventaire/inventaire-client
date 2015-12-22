module.exports = (groups)->

  groups.filtered = filtered = new FilteredCollection groups

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

  filtered.searchByText = _.debounce searchByText, 200
