export default Marionette.Behavior.extend({
  events: {
    loading: 'showSpinningLoader',
    stopLoading: 'hideSpinningLoader',
    somethingWentWrong: 'somethingWentWrong'
  },

  showSpinningLoader (e, params = {}) {
    let $target
    let { selector, message, timeout, progressionEventName } = params
    if (this._targets == null) { this._targets = {} }
    this._targets[selector] = ($target = this.getTarget(selector))

    if ($target.length !== 1) { return _.warn($target, 'loading: failed to find single target') }

    let body = '<div class="small-loader"></div>'
    if (message != null) {
      const mes = params.message
      body += `<p class='grey'>${mes}</p>`
    }

    const $parent = $target.parent()

    // If the container is flex, no need to adjust to get the loader centered
    if ($parent.css('display') !== 'flex') {
      body = body.replace('small-loader', 'small-loader adjust-vertical-alignment')
    }

    $target.html(body)
    // Elements to hide when loading should share the same parent as the .loading element
    $parent.find('.hide-on-loading').hide()

    if (!timeout) { timeout = 60 }
    if (timeout !== 'none') {
      const cb = this.somethingWentWrong.bind(this, null, params)
      this.view.setTimeout(cb, timeout * 1000)
    }

    if (progressionEventName != null) {
      if (this._alreadyListingForProgressionEvent) { return }
      this._alreadyListingForProgressionEvent = true

      const fn = updateProgression.bind(this, body, $target)
      const lazyUpdateProgression = _.debounce(fn, 500, true)
      this.listenTo(app.vent, progressionEventName, lazyUpdateProgression)
    }

    return e.stopPropagation()
  },

  hideSpinningLoader (e, params = {}) {
    const { selector } = params
    if (this._targets == null) { console.warn('hideSpinningLoader called before showSpinningLoader') }
    if (this._targets == null) { this._targets = {} }
    if (!this._targets[selector]) { this._targets[selector] = this.getTarget(selector) }
    const $target = this._targets[selector]
    $target.empty()
    $target.parent().find('.hide-on-loading').show()
    this.hidden = true
    return e.stopPropagation()
  },

  somethingWentWrong (e, params = {}) {
    if (!this.hidden) {
      const { selector } = params
      if (!this._targets[selector]) { this._targets[selector] = this.getTarget(selector) }
      const $target = this._targets[selector]

      const oups = _.I18n('something went wrong :(')
      const body = _.icon('bolt') + `<p> ${oups}</p>`

      $target.html(body)
    }

    return e?.stopPropagation()
  },

  // Priority:
  // - #{selector} .loading
  // - #{selector}
  // - .loading
  getTarget (selector) {
    if (_.isNonEmptyString(selector)) {
      const $target = this.$el.find(selector)
      const $targetAlt = $target.find('.loading')
      if ($targetAlt.length === 1) { return $targetAlt } else { return $target }
    } else {
      return this.$el.find('.loading')
    }
  }
})

var updateProgression = function (body, $target, data) {
  if (this.hidden) { return }
  const counter = `${data.done}/${data.total}`
  return $target.html(`<span class='progression'>${counter}</span> ${body}`)
}
