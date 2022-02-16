import AuthorPreview from './author_preview.js'
import authorsPreviewListTemplate from './templates/authors_preview_list.hbs'

export default Marionette.CollectionView.extend({
  template: authorsPreviewListTemplate,
  childViewContainer: 'ul',
  childView: AuthorPreview,
  className: 'author-preview-list',
  serializeData () {
    return { name: this.options.name }
  }
})
