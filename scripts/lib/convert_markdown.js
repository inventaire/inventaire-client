/* eslint-disable
    import/no-duplicates,
    no-useless-escape,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import linkify from '../../app/lib/handlebars_helpers/linkify'

const convertMarkdownBold = text => text?.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')

const convertMarkdownLinks = function (text) {
  if (text == null) { return }

  return text
  // Replacing local links first
  // that is links starting by / or a variable starting with %
  // Example:
  // - "your_item_was_requested_subject": "%{username} requested your book [%{title}](%{link})"
  .replace(/\[([^\]]+)\]\(((\/|%)[^\)]+)\)/g, dynamicLink)
  // Remove the target on those local links
  .replace(" target='_blank'", '')
  // Then replace other links and keep the target='_blank'
  .replace(/\[([^\]]+)\]\(([^\)]+)\)/g, dynamicLink)
}

// used by String::replace to pass text -> $1 and url -> $2 values
var dynamicLink = linkify('$1', '$2')

export default text => convertMarkdownLinks(convertMarkdownBold(text))
