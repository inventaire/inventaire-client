module.exports = Marionette.ItemView.extend
  className: 'position-welcome'
  template: require './templates/map_welcome'
  events:
    'click #showPositionPicker': -> app.execute 'show:position:picker:main:user'
