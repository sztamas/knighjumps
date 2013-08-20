root = exports ? this

drawPolygon = (context, shape) ->
  context.beginPath()
  lastPoint = shape[shape.length-1]
  context.moveTo lastPoint[0], lastPoint[1]
  for point in shape
    context.lineTo point[0], point[1]
  context.closePath()
  context.fill() 

translateShape = (shape, x, y) ->
  ([ point[0] + x, point[1] + y ] for point in shape)

rotatePoint = (angle, x, y) ->
  [ x * Math.cos(angle) - y * Math.sin(angle),
    x * Math.sin(angle) + y * Math.cos(angle) ]

rotateShape = (shape, angle) =>
  (rotatePoint(angle, point[0], point[1]) for point in shape)

DEFAULT_ARROW_SHAPE = [
    [   0,  0 ]
    [ -25, -12 ]
    [ -25,  12 ]
]
DEFAULT_ARROW_LENGTH = 25

root.drawArrow = (context, startPoint, endPoint, arrow = DEFAULT_ARROW_SHAPE) ->
  lineAngle = Math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
  drawPolygon(context, translateShape(rotateShape(arrow, lineAngle), endPoint.x, endPoint.y))

root.calculateLineArrowJoinPoint = (startPoint, endPoint, arrowLength=DEFAULT_ARROW_LENGTH) ->
  lineAngle = Math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
  lineEndPoint = rotatePoint(lineAngle, -arrowLength, 0)
  { 
     x: endPoint.x+lineEndPoint[0]
     y: endPoint.y+lineEndPoint[1] 
  }



