# imported from http://stackoverflow.com/questions/11978995/how-to-change-color-of-svg-image-using-css-jquery-svg-image-replacement
#
#* Replace all SVG images with inline SVG
#

module.exports =
  initialize: ($)->
    $("img.svg").each ->
      $img = $(this)
      imgID = $img.attr 'id'
      imgClass = $img.attr 'class'
      imgURL = $img.attr 'src'
      $.get imgURL, dataBuilder, "xml"

dataBuilder = (data) ->
  # Get the SVG tag, ignore the rest
  $svg = $(data).find("svg")

  # Add replaced image's ID to the new SVG
  $svg = $svg.attr("id", imgID)  if imgID?

  # Add replaced image's classes to the new SVG
  $svg = $svg.attr("class", imgClass + " replaced-svg")  if imgClass?

  # Remove any invalid XML tags as per http://validator.w3.org
  $svg = $svg.removeAttr("xmlns:a")

  # Replace image with new SVG
  $img.replaceWith $svg
  return