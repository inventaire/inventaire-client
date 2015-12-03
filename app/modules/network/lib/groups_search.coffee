module.exports = (groups)->

  groups.filtered = filtered = new FilteredCollection groups

  queried = []

  searchByText = (text)->

    unless _.isNonEmptyString text then return
    if text in queried then return

    queried.push text

    _.preq.get app.API.groups.search(text)
    .then addGroupsAndFilterByText.bind(null, text)
    .catch (err)->
      # removing text from the list of past queries
      # to allow it to be re-queried
      queried = _.without queried, text
      throw err

  filtered.searchByText = _.debounce searchByText, 200

  addGroupsAndFilterByText = (text, groupsData)->
    groups.add groupsData
    filtered.filterByText text
