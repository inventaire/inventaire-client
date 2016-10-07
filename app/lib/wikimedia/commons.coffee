smallThumb = (file, width="100")->
  file = _.fixedEncodeURIComponent file
  "https://commons.wikimedia.org/w/thumb.php?width=#{width}&f=#{file}"

# more complete data access: can include author and license
thumbData = (file, width=500)->
  width = _.bestImageWidth width
  preq.get app.API.data.commonsThumb(file, width)

module.exports =
  smallThumb: smallThumb
  thumbData: thumbData
  thumb: (file, width=500)->
    thumbData file, width
    .get 'thumbnail'
    .catch (err)->
      console.warn "couldnt find #{file} via tools.wmflabs.org, will use the small thumb version"
      return smallThumb file, 200
