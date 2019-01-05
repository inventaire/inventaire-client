module.exports = screen_ =
  # /!\ window.screen.width is the screen's width not the current window width
  width: -> $(window).width()
  height: -> $(window).height()
  # keep in sync with app/modules/general/scss/_grid_and_media_query_ranges.scss
  isSmall: (ceil = 1000)-> screen_.width() < ceil

  # Scroll to the top of an $el
  # Increase marginTop to scroll to a point before the element top
  scrollTop: ($el, duration = 500, marginTop = 0)->
    # Polymorphism: accept jquery objects or selector strings as $el
    if _.isString then $el = $($el)
    top = $el.position().top - marginTop
    $('html, body').animate { scrollTop: top }, duration

  # Scroll to a given height
  scrollHeight: (height, ms = 500)->
    $('html, body').animate { scrollTop: height }, ms

  # Scroll to the top of an element inside a element with a scroll,
  # typically a list of search results partially hidden
  innerScrollTop: ($parent, $children)->
    if $children?.length > 0
      selectedTop = $children.position().top
      # Adjust scroll to the selected element
      scrollTop = $parent.scrollTop() + selectedTop - 50
    else
      scrollTop = 0
    $parent.animate { scrollTop }, { duration: 50, easing: 'swing' }
