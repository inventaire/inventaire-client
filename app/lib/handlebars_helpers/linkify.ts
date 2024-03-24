// customized for client-side needs
export default function (text, url, classes = 'link', title) {
  // prevent [object Object] classes
  // avoiding using _.isString as the module is used in scripts with differents environments
  if (typeof classes !== 'string') classes = ''

  const isExternalLink = url[0] !== '/'
  // on rel='noopener' see: https://mathiasbynens.github.io/rel-noopener
  const openOutsideAttributes = isExternalLink ? "target='_blank' rel='noopener'" : ''

  // Not using isNonEmptyString to prevent having to depend on _
  if ((typeof title === 'string') && (title.length > 0)) {
    title = title.replace(/"/g, '&quot;')
    title = `title="${title}"`
  } else {
    title = ''
  }

  return `<a href="${url}" class='${classes}' ${title} ${openOutsideAttributes}>${text}</a>`
}
