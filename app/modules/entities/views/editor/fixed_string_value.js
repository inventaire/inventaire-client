import fixedStringValueTemplate from './templates/fixed_string_value.hbs'

export default Marionette.ItemView.extend({
  className: 'fixed-string-value value-editor-commons fixed-value',
  template: fixedStringValueTemplate
})
