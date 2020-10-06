import authorPreviewTemplate from './templates/author_preview.hbs'

export default Marionette.ItemView.extend({
  tagName: 'li',
  template: authorPreviewTemplate,
  className: 'author-preview'
})
