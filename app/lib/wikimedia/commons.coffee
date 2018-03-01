module.exports =
  # For more complete data (author, license, ...)
  # see in the server repo: server/data/commons/thumb.coffee
  smallThumb: (file, width = '100')->
    file = _.fixedEncodeURIComponent file
    "https://commons.wikimedia.org/w/thumb.php?width=#{width}&f=#{file}"
