module.exports =
  ui:
    groupNameField: '.groupNameField'
    groupUrlWrapper: 'p.group-url'
    groupUrl: '#groupUrl'

  events:
    'keyup .groupNameField': 'lazyUpdateUrl'

  LazyUpdateUrl: (view)->
    groupId = view.model?.id
    return _.debounce updateUrl.bind(view, groupId), 200

updateUrl = (groupId)->
  name = @ui.groupNameField.val()
  if _.isNonEmptyString name
    _.preq.get app.API.groups.slug(name, groupId)
    .then (res)=>
      @ui.groupUrl.text "#{window.location.root}/groups/#{res.slug}"
      @ui.groupUrlWrapper.show()
  else
    @ui.groupUrlWrapper.hide()
