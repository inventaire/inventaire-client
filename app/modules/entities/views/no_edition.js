import noEditionTemplate from './templates/no_edition.hbs'

export default Marionette.View.extend({
  tagName: 'li',
  className: 'no-edition',
  template: noEditionTemplate
})
