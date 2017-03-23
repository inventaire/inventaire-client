module.exports =
  ui:
    groupNameField: '.groupNameField'
    groupUrlWrapper: 'p.group-url'
    groupUrl: '#groupUrl'

  events:
    'keyup .groupNameField': 'lazyUpdateUrl'

  LazyUpdateUrl: (view)-> _.debounce updateUrl.bind(view), 200

updateUrl = ->
  name = @ui.groupNameField.val()
  if _.isNonEmptyString name
    _.preq.get app.API.groups.slug(name)
    .then (res)=>
      @ui.groupUrl.text "#{window.location.root}/groups/#{res.slug}"
      @ui.groupUrlWrapper.show()
  else
    @ui.groupUrlWrapper.hide()
