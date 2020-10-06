import AuthorPreview from './author_preview'

export default Marionette.CompositeView.extend({
  template: require('./templates/authors_preview_list.hbs'),
  childViewContainer: 'ul',
  childView: AuthorPreview,
  className: 'author-preview-list',
  serializeData () {
    return { name: this.options.name }
  }
})
