import feedLiTemplate from './templates/feed_li.hbs'

export default Marionette.ItemView.extend({
  template: feedLiTemplate,
  className: 'feedLi',
  modelEvents: {
    // Required for entity that deduce their label from another entity (e.g. edtions)
    change: 'render'
  }
})
