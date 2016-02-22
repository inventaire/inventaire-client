module.exports = (key, ctx)->
  { currentLocale:lang } = app.polyglot
  val = app.polyglot.t key, ctx

  if lang in hasModifiers then return modifiers[lang](key, val, ctx)
  else return val

modifiers =
  # make _.i18n('user_comment', {username: 'adamsberg'})
  # return "Commentaire d'adamsberg" instead of "Commentaire de adamsberg"
  fr: (key, val, data)->
    if data? and isShortkey key
      k = app.polyglot.phrases[key]
      { username } = data
      if username?
        firstLetter = username[0].toLowerCase()
        if firstLetter in vowels
          if /de\s(<strong>)?%{username}/.test k
            re = new RegExp "de (<strong>)?#{username}"
            return val.replace re, "d'$1#{username}"

    return val

hasModifiers = Object.keys(modifiers)

isShortkey = (key)-> /_/.test key
vowels = 'aeiouy'
