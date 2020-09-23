import screen_ from 'lib/screen'
// Keep in sync with app/modules/general/scss/_topbar.scss
const topbarHeight = 45

export default Marionette.Behavior.extend({
  initialize () {
    this.marginTop = this.options.marginTop || topbarHeight
    this.scrollDuration = this.options.marginTop || 0

    const delay = this.options.debounce || 500
    return this._lazyScroll = _.debounce(this.scrollToTarget.bind(this), delay)
  },

  onShow () {
    return this.alreadyScrolled = false
  },

  onRender () { return this._lazyScroll() },

  // defining it on the Class to allow event binding
  lazyScroll () { return this._lazyScroll() },
  events: {
    // retry once new child view are ready, in case the target wasn't found
    // on render
    'child:view:ready': 'lazyScroll'
  },

  scrollToTarget () {
    if (this.alreadyScrolled) { return }

    const { hash } = location
    if (hash !== '') {
      const $target = this.$el.find(hash)
      if ($target.length > 0) {
        screen_.scrollTop($target, this.scrollDuration, this.marginTop)
        return this.alreadyScrolled = true
      }
    }
  }
})
