module.exports = class UserLi extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "userLi row"
  template: require 'views/users/templates/user_li'

  events:
    'click #unfriend': -> app.request 'unfriend', @model
    'click #cancel': -> app.request 'request:cancel', @model
    'click #discard': -> app.request 'request:discard', @model
    'click #accept': -> app.request 'request:accept', @model
    'click #request': -> app.request 'request:send', @model
    # 'click .selectUser': 'togglerSelectUser'

  initialize:->
    @listenTo @model, 'change', @render

  serializeData: ->
    attrs = @model.toJSON()
    status = attrs.status
    # converting the status into a boolean for the template
    attrs[status] = true
    _.log attrs, "#{attrs.username} attr"
    return attrs

  # togglerSelectUser: (e)->
  #   if @$el.hasClass('selected')
  #     @unselectUser()
  #   else
  #     @selectUser()

  # selectUser: ->
  #   app.execute('user:fetchItems', @model)  unless @model.get('following')
  #   app.execute 'filter:inventory:owner', Items.friends.filtered, @model.id
  #   $('.selected').removeClass('selected')
  #   @$el.addClass('selected')

  # unselectUser: ->
  #   app.filteredItems.removeFilter 'owner'
  #   @$el.removeClass('selected')
