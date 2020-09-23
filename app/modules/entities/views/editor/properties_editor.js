export default Marionette.CompositeView.extend({
  className: 'properties-editor',
  template: require('./templates/properties_editor'),
  childView: require('./property_editor'),
  childViewContainer: '.properties',
  initialize() {
    const { propertiesShortlist } = this.options;
    this.hasPropertiesShortlist = (propertiesShortlist != null);

    if (this.hasPropertiesShortlist) {
      // set propertiesShortlist to display only a subset of properties by default
      return this.filter = function(child, index, collection){
        let needle;
        return (needle = child.get('property'), propertiesShortlist.includes(needle));
      };
    }
  },

  ui: {
    showAllProperties: '#showAllProperties'
  },

  events: {
    'click #showAllProperties': 'showAllProperties'
  },

  onShow() {
    if (this.hasPropertiesShortlist) { return this.ui.showAllProperties.show(); }
  },

  showAllProperties() {
    this.filter = null;
    this.render();
    return this.ui.showAllProperties.hide();
  }
});
