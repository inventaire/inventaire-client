/* eslint-disable
    no-return-assign,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
const def = { x: 0, y: 1 }
const style = { color: 'green', lineWidth: 2 }

export default function () {
  let alreadyDrawn = false
  return function (result) {
    if (alreadyDrawn) { return }

    if (result?.boxes != null) {
      const drawingCtx = Quagga.canvas.ctx.overlay
      // drawingCanvas = Quagga.canvas.dom.overlay

      const box = result.boxes[0]
      Quagga.ImageDebug.drawPath(box, def, drawingCtx, style)

      return alreadyDrawn = true
    }
  }
};
