import noEditionTemplate from './templates/no_edition.hbs'

export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'no-edition',
  template: noEditionTemplate
})
