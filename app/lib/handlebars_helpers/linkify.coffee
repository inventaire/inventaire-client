# extracted to be used in both handlebars helpers and scripts/lib/convert_markdown

module.exports = (text, url, classes='link')->
  "<a href=\"#{url}\" class='#{classes}' target='_blank'>#{text}</a>"