# This is tailored for handlebars, for other uses, use app.API.img directly.
# Keep in sync with server/lib/emails/handlebars_helpers
module.exports =
  src: (path, width, height)->
    if _.isDataUrl path then return path

    width = getImgDimension width, 1600
    width = bestImageWidth width
    height = getImgDimension height, width
    path = onePictureOnly path

    unless path? then return ''

    return app.API.img path, width, height

onePictureOnly = (arg)->
  if _.isArray(arg) then return arg[0] else arg

getImgDimension = (dimension, defaultValue)->
  if _.isNumber dimension then return dimension
  else defaultValue

bestImageWidth = (width)->
  # under 500, it's useful to keep the freedom to get exactly 64 or 128px etc
  # while still grouping on the initially requested width
  if width < 500 then return width

  # if in a browser, use the screen width as a max value
  if screen?.width then width = Math.min width, screen.width
  # group image width above 500 by levels of 100px to limit generated versions
  return Math.ceil(width / 100) * 100
