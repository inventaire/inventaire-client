def = { x: 0, y: 1 }
style = { color: 'green', lineWidth: 2 }

module.exports = ->
  alreadyDrawn = false
  return (result)->
    if alreadyDrawn then return

    if result?.boxes?

      drawingCtx = Quagga.canvas.ctx.overlay
      # drawingCanvas = Quagga.canvas.dom.overlay

      box = result.boxes[0]
      Quagga.ImageDebug.drawPath box, def, drawingCtx, style

      alreadyDrawn = true
