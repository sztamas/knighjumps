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

root.createArrow = (width, height) ->
  halfWidth = Math.floor( width / 2 )
  [ 
    [       0,          0 ]
    [ -height, -halfWidth ] 
    [ -height,  halfWidth ] 
  ]

DEFAULT_ARROW_HEIGHT = 25
DEFAULT_ARROW_WIDTH = 24
DEFAULT_ARROW_SHAPE = createArrow(DEFAULT_ARROW_WIDTH, DEFAULT_ARROW_HEIGHT)

root.drawArrow = (context, startPoint, endPoint, arrow = DEFAULT_ARROW_SHAPE) ->
  lineAngle = Math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
  drawPolygon(context, translateShape(rotateShape(arrow, lineAngle), endPoint.x, endPoint.y))

root.calculateLineArrowJoinPoint = (startPoint, endPoint, arrowHeight=DEFAULT_ARROW_HEIGHT) ->
  lineAngle = Math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
  lineEndPoint = rotatePoint(lineAngle, -arrowHeight, 0)
  { 
     x: endPoint.x+lineEndPoint[0]
     y: endPoint.y+lineEndPoint[1] 
  }




