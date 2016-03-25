module.exports = ->
  alreadyDrawn = false

  return drawCanvas = (result)->
    if alreadyDrawn then return

    if result?.boxes?

      drawingCtx = Quagga.canvas.ctx.overlay
      # drawingCanvas = Quagga.canvas.dom.overlay

      box = result.boxes[0]
      Quagga.ImageDebug.drawPath box, def(0, 1), drawingCtx, style('green', 2)

      alreadyDrawn = true

def = (x, y)->
  x: x
  y: y

style = (color, lineWidth)->
  color: color
  lineWidth: lineWidth
