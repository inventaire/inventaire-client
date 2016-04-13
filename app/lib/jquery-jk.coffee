# adapted from jquery-jk from https://github.com/nakajima/jquery-jk
module.exports.initialize = ($)->
  focused = -> @find '.focus'
  focusOn = (dir)->
    return @find('*:first').addClass('focus')  unless @focused().length
    focusedOld = @focused()
    focusedNew = focusedOld[dir]()
    if focusedNew.size()
      focusedOld.trigger('focus:lost').removeClass 'focus'
      focusedNew.trigger('focus:added').addClass 'focus'
    else
      @trigger 'paginate:' + dir

  selected = -> @find '.selected'
  selectOn = ->
    focused = @focused()
    (if focused.toggleClass('selected').hasClass('selected') then focused.trigger('selection:added') else focused.trigger('selection:lost'))

  # handlers
  nextKey = -> $.jk.NEXT.charCodeAt()
  prevKey = -> $.jk.PREV.charCodeAt()
  selectKey = -> $.jk.SELECT.charCodeAt()
  attempt = (event)->
    return  unless event.which
    return  if $(event.target).is(':input')
    if event.which is nextKey()
      $.jk.focusNext()
      $.jk.scrollToFocused()
    if event.which is prevKey()
      $.jk.focusPrev()
      $.jk.scrollToFocused()
    $.jk.select()  if event.which is selectKey()

  $.jk =
    PREV: 'k'
    NEXT: 'j'
    SELECT: 'x'
    focusNext: -> $('.jk').focusOn 'next'
    focusPrev: -> $('.jk').focusOn 'prev'
    select: -> $('.jk').selectOn()
    scrollToFocused: ->
      $focus = $('.focus')
      if $focus.length > 0
        targetedHeight = $focus.offset().top - 50
        $('html, body').animate({scrollTop: targetedHeight}, 100)
  $.fn.focused = focused
  $.fn.focusOn = focusOn
  $.fn.selected = selected
  $.fn.selectOn = selectOn

  $(document).ready -> $(document).bind 'keypress', attempt