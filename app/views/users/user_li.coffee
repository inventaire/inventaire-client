module.exports = class UserLi extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "user row"
  template: require 'views/users/templates/user_li'

  events:
    'click #follow': -> app.execute 'user:follow', @model
    'mouseenter #unfollow': 'toggleSuccessAlertClasses'
    'mouseleave #unfollow': 'toggleSuccessAlertClasses'
    'click #unfollow': -> app.execute 'user:unfollow', @model
    'click .selectUser': 'togglerSelectUser'

  initialize:->
    @listenTo @model, 'change:following', @render

  serializeData: ->
    attrs = @model.toJSON()
    attrs.following = @model.following
    return attrs

  toggleSuccessAlertClasses: (e)->
    $(e.currentTarget)
    .toggleClass('alert').toggleClass('success')
    .find('i').toggleClass('fa-check').toggleClass('fa-minus').width(11)

  togglerSelectUser: (e)->
    if @$el.hasClass('selected')
      @unselectUser()
    else
      @selectUser()

  selectUser: ->
    app.execute('user:fetchItems', @model)  unless @model.get('following')
    app.execute 'filter:inventory:owner', Items.friends.filtered, @model.id
    $('.selected').removeClass('selected')
    @$el.addClass('selected')

  unselectUser: ->
    app.filteredItems.removeFilter 'owner'
    @$el.removeClass('selected')
