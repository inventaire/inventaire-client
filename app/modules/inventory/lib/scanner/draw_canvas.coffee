module.exports = ->
  alreadyDrawn = false

  return drawCanvas = (result)->
    if alreadyDrawn then return
    drawingCtx = Quagga.canvas.ctx.overlay
    # drawingCanvas = Quagga.canvas.dom.overlay

    if result?.boxes?
      alreadyDrawn = true

      result.boxes
      .filter (box) -> box != result.box
      .forEach (box) ->
        Quagga.ImageDebug.drawPath box, def(0, 1), drawingCtx, style('green', 2)

def = (x, y)->
  x: x
  y: y

style = (color, lineWidth)->
  color: color
  lineWidth: lineWidth
