export default Marionette.Behavior.extend({
  events: {
    'click .select-button-group > .button': 'updateSelector'
  },

  updateSelector(e){
    const $el = $(e.currentTarget);
    $el.siblings().removeClass('selected');
    $el.addClass('selected');
    const section = $el.parent()[0].id;
    const value = $el[0].id;
    return app.execute(`last:${section}:set`, value);
  }
});
