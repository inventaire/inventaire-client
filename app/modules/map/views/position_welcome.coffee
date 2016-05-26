module.exports = Marionette.ItemView.extend
  className: 'position-welcome'
  template: require './templates/map_welcome'
  events:
    'click #showPositionPicker': -> app.execute 'show:position:picker:main:user'

  onShow: ->
    # Listen for the server confirmation instead of simply the change
    # so that 'nearby' request aren't done while the server is still editing the user's position
    # and might thus return a 400
    @listenTo app.user, 'confirmed:position', app.Execute('show:inventory:nearby')
