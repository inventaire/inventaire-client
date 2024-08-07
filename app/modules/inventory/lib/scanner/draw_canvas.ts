const def = { x: 0, y: 1 }
const style = { color: 'green', lineWidth: 2 }

export function drawCanvasFactory (Quagga) {
  let alreadyDrawn = false
  return function drawCanvas (result) {
    if (alreadyDrawn) return

    if (result?.boxes != null) {
      const drawingCtx = Quagga.canvas.ctx.overlay
      // drawingCanvas = Quagga.canvas.dom.overlay

      const box = result.boxes[0]
      Quagga.ImageDebug.drawPath(box, def, drawingCtx, style)

      alreadyDrawn = true
    }
  }
}
