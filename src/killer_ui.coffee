$(document).ready ->

  canvas = document.getElementById "killer"

  size = canvas.width
  console.log "The canvas ain't square you bozo - this won't render very well"

  ctx = canvas.getContext "2d"
  ctx.fillStyle = "#EEEEEE"
  ctx.fillRect 0, 0, canvas.width, canvas.height

  drawGridLines = (ctx, numberOfGridLines, strokeStyle) ->
    ctx = canvas.getContext "2d"
    ctx.strokeStyle = strokeStyle
    ctx.beginPath
    for index in [0..numberOfGridLines]
      x = y = Math.floor index * (size / numberOfGridLines)
      console.log x
      ctx.moveTo x, 0
      ctx.lineTo x, size
      ctx.moveTo 0, y
      ctx.lineTo size, y
    ctx.stroke();

  drawGridLines ctx, 3, '#000000'
  drawGridLines ctx, 9, '#DDDDDD'



