module.exports = (regex_)->
  isLocalImg: (url)-> regex_.LocalImg.test url
  isLang: (lang)-> regex_.Lang.test lang
