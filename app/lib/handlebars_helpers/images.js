// This is tailored for handlebars, for other uses, use app.API.img directly.
// Keep in sync with server/lib/emails/handlebars_helpers
export default {
  imgSrc (path, width, height) {
    if (_.isDataUrl(path)) { return path }

    width = getImgDimension(width, 1600)
    width = bestImageWidth(width)
    height = getImgDimension(height, width)
    path = onePictureOnly(path)

    if (path == null) { return '' }

    return app.API.img(path, width, height)
  }
}

var onePictureOnly = function (arg) {
  if (_.isArray(arg)) { return arg[0] } else { return arg }
}

var getImgDimension = function (dimension, defaultValue) {
  if (_.isNumber(dimension)) {
    return dimension
  } else { return defaultValue }
}

var bestImageWidth = function (width) {
  // under 500, it's useful to keep the freedom to get exactly 64 or 128px etc
  // while still grouping on the initially requested width
  if (width < 500) { return width }

  // if in a browser, use the screen width as a max value
  if (screen?.width) { width = Math.min(width, screen.width) }
  // group image width above 500 by levels of 100px to limit generated versions
  return Math.ceil(width / 100) * 100
}
