# Keep in sync with app/modules/general/scss/_topbar.scss
topbarHeight = 45

module.exports = Marionette.Behavior.extend
  initialize: ->
    @marginTop = @options.marginTop or topbarHeight
    @scrollDuration = @options.marginTop or 0

    delay = @options.debounce or 500
    @_lazyScroll = _.debounce @scrollToTarget.bind(@), delay

  onShow: ->
    @alreadyScrolled = false

  onRender: -> @_lazyScroll()

  # defining it on the Class to allow event binding
  lazyScroll: -> @_lazyScroll()
  events:
    # retry once new child view are ready, in case the target wasn't found
    # on render
    'child:view:ready': 'lazyScroll'

  scrollToTarget: ->
    if @alreadyScrolled then return

    { hash } = location
    if hash isnt ''
      $target = @$el.find hash
      if $target.length > 0
        _.scrollTop $target, @scrollDuration, @marginTop
        @alreadyScrolled = true
