module.exports = (regex_)->
  isLocalImg: (url)-> regex_.LocalImg.test url