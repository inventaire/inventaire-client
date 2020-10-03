export default Marionette.ItemView.extend({
  template: require('./templates/feed_li.hbs'),
  className: 'feedLi',
  modelEvents: {
    // Required for entity that deduce their label from another entity (e.g. edtions)
    change: 'render'
  }
})
