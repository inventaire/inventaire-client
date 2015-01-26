# extracted to be used in both handlebars helpers and scripts/lib/convert_markdown

module.exports = (text, url)->
  "<a href='#{url}' class='link' target='_blank'>#{text}</a>"