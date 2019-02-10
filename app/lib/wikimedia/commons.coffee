module.exports =
  # For more complete data (author, license, ...)
  # see in the server repo: server/data/commons/thumb.coffee
  thumbnail: (file, width = '100')->
    file = _.fixedEncodeURIComponent file
    "https://commons.wikimedia.org/wiki/Special:FilePath/#{file}?width=#{width}"
