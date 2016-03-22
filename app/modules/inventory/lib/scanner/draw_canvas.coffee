offsetLeft = 640*0.25
offsetRight = 640*0.75
path = [ {x: offsetLeft, y: 240}, {x: offsetRight, y: 240 } ]
drawPath = Quagga.ImageDebug.drawPath.bind Quagga.ImageDebug

module.exports = (result)->
  drawingCtx = Quagga.canvas.ctx.overlay
  drawingCanvas = Quagga.canvas.dom.overlay

  # Draw a red line to help adjust the camera
  drawPath path, def('x', 'y'), drawingCtx, style('red', 2)

  if result
    # Draw a green box around located patterns
    if result.boxes
      width = parseInt drawingCanvas.getAttribute('width')
      height = parseInt drawingCanvas.getAttribute('height')
      drawingCtx.clearRect 0, 0, width, height

      result.boxes
      .filter (box) -> box != result.box
      .forEach (box) ->
        drawPath box, def(0, 1), drawingCtx, style('green', 2)

    # # Draw a blue box around result
    # if result.box
    #   drawPath result.box, def(0, 1), drawingCtx, style('#00F', 2)

def = (x, y)->
  x: x
  y: y

style = (color, lineWidth)->
  color: color
  lineWidth: lineWidth
