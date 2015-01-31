NoItem = require './no_item'

module.exports = NoItem.extend
  className: "text-center welcomingNoItem"
  template: require './templates/welcoming_no_item'
  onShow: -> $('.itemsList').removeClass('columnsLayout')
  onDestroy: -> $('.itemsList').addClass('columnsLayout')
  events:
    'click #jumpIn': -> app.execute 'show:joyride:welcome:tour'
