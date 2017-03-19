# customized for client-side needs
module.exports = (text, url, classes='link', title)->
  # prevent [object Object] classes
  # avoiding using _.isString as the module is used in scripts with differents environments
  unless typeof classes is 'string' then classes = ''

  isExternalLink = url[0] isnt '/'
  # on rel='noopener' see: https://mathiasbynens.github.io/rel-noopener
  openOutsideAttributes = if isExternalLink then "target='_blank' rel='noopener'" else ''

  # Not using _.isNonEmptyString to prevent having to depend on _
  if typeof title is 'string' and title.length > 0
    title = title.replace /"/g, '&quot;'
    title = "title=\"#{title}\""
  else
    title = ''

  "<a href=\"#{url}\" class='#{classes}' #{title} #{openOutsideAttributes}>#{text}</a>"
