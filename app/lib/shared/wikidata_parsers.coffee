module.exports = (wd_)->
  wmflabs:
    ids: (res)->
      {items} = res
      return wd_.normalizeIds items