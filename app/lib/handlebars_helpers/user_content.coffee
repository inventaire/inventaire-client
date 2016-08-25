{ SafeString, escapeExpression } = Handlebars

# regex inspired by https://gist.github.com/efeminella/2034192
link = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]+)/gim
protocolText = '<a href="$1" class="content-link" target="_blank" rel="noopener nofollow">$1</a>'

module.exports =
  userContent: (text)->
    if text?
      text = escapeExpression text
      text = text
        .replace /\n/g, '<br>'
        .replace link, protocolText
      return new SafeString text
    else return
