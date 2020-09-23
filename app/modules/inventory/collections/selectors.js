export default Backbone.Collection.extend({
  comparator (model) {
    // Push the 'unknown' entity at the bottom of the list
    if (model.get('uri') === 'unknown') {
      return Infinity
    } else { return -model.get('count') }
  }
})
