import authorPreviewTemplate from './templates/author_preview.hbs'

export default Marionette.View.extend({
  tagName: 'li',
  template: authorPreviewTemplate,
  className: 'author-preview'
})
