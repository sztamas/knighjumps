
FILES = 'abcdefgh'

class Square
  constructor: (coord) ->
    @coord = coord
    @file = coord[0]
    @fileIdx = FILES.indexOf(@file)
    @rank = parseInt(coord[1])
    @rankIdx = @rank - 1

  color: ->
    if @fileIdx % 2 == @rank % 2 then 'light' else 'dark'

  isLight: ->
    @color() == 'light'

  isDark: ->
    @color() == 'dark'


class Board
  constructor: (knightSquare) ->
    @knightSquare = knightSquare
    @squares = @initSquares

  initSquares: ->
    squares = []
    ranks = [1..8]
    for rank in ranks
      for file in FILES
        squares.push new Square(file + rank)
    return squares

  allKnightMoves: (from) ->
    result = []
    coords = ([from.fileIdx + distance[0], from.rank + distance[1]] for distance in [[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]])
    validCoords = (FILES[coord[0]] + coord[1] for coord in coords when 0 <= coord[0] < 8 and 0 < coord[1] <= 8)
    return validCoords

  calculateHopNumbers: ->
    hopNumbers = {}
    hopNumbers[@knightSquare.coord] = 0

    length = (m) ->
      (k for k,v of hopNumbers).length
        
    step = 1
    while length(hopNumbers) < 64
      for lastPos in (coord for coord, hopNo of hopNumbers when hopNo == step-1)
        for coord in @allKnightMoves(new Square(lastPos))
          hopNumbers[coord] = step unless coord of hopNumbers
      step += 1

    return hopNumbers

  calculatePaths: (to) ->
    paths = [
        [@knightSquare]
    ]

    endPointReached = false
    while not endPointReached
      newPaths = []
      for path in paths
        for coord in @allKnightMoves(path[path.length-1])
          newPath = path[..]
          newPath.push(new Square(coord))
          newPaths.push newPath
          endPointReached = true if to == coord
      paths = newPaths
    return (path for path in paths when path[path.length-1].coord == to)


class BoardView
  constructor: (elementId, board) ->
    @board = board
    @canvas = document.getElementById elementId
    @canvas.onmousedown = @onMouseDown
    @canvas.onmouseup = @onMouseUp
    @context = @canvas.getContext '2d'
    @colorscheme =
      DARK_SQUARE: '#a65400'
      LIGHT_SQUARE: '#ffbf73'
      #DARK_SQUARE: 'black'
      #LIGHT_SQUARE: 'white'
      COORD_TEXT: 'darkgrey'
    @showCoordinates = false
    #@showCoordinates = true
    @fontFamily = 'Sanchez'

    @image = KNIGHT_IMG
  
    @pathsToShowIdx = -1
    @pathsToShowIdx2 = 0

  color: (type) ->
    @colorscheme[type]
 
  squareSize: ->
    Math.min(@canvas.height, @canvas.width) / 8

  drawSquare: (square) ->
    squareSize = @squareSize()
    squareColor = if square.isLight() then 'LIGHT_SQUARE' else 'DARK_SQUARE'
    @context.fillStyle = @color squareColor

    @context.fillRect square.fileIdx*squareSize, (8-square.rank)*squareSize, squareSize, squareSize

    if @showCoordinates
      # TODO extract method
      @context.fillStyle = @color "COORD_TEXT"
      @context.textAlign = "left"
      @context.textBaseline = "bottom"
      @context.font = "12px Colibri"
      margin = 2
      @context.fillText square.coord, square.fileIdx*squareSize+margin, (9-square.rank)*squareSize-margin
   
  clear: ->
    @context.clearRect(0, 0, @canvas.width, @canvas.height)

  draw: =>
    @clear()
    @drawBoard()
    @drawHopNumbers @board.calculateHopNumbers()
    @drawKnight()
    if @pathsToShow
      if @pathsToShowIdx == -1
        @drawPaths @pathsToShow
      else
        @drawPaths @pathsToShow[@pathsToShowIdx..@pathsToShowIdx]
      if @pathsToShowIdx2 < 100
        @pathsToShowIdx2 += 1
      else
        if @pathsToShowIdx >= @pathsToShow.length-1
          @pathsToShowIdx = -1
        else
          @pathsToShowIdx += 1
        @pathsToShowIdx2 = 0

  drawPaths: (paths) ->
    for path in paths
      prev = path[0]
      for square in path[1..]
        @drawLine prev, square, "rgba(10, 133, 62, .6)"
        prev = square

  squareCentre: (square) ->
    squareSize = @squareSize()
    half = squareSize / 2
    {
      x: square.fileIdx * squareSize + half
      y: (8-square.rank)* squareSize + half
    }

  drawLine: (from, to, color) ->
    startPoint = @squareCentre from
    endPoint = @squareCentre to

    @context.lineWidth = 8
    @context.strokeStyle = color
    @context.fillStyle = color
    drawArrow @context, startPoint.x, startPoint.y, endPoint.x, endPoint.y, 1, 1, Math.PI/8, 25

  drawBoard: ->
    for square in @board.squares()
      @drawSquare square

  drawKnight: () ->
    squareSize = @squareSize()
    half = Math.floor squareSize / 2
    if @draging and @mouseCoords
      x = Math.max(0, @mouseCoords.x - half)
      y = Math.max(0, @mouseCoords.y - half)
      @context.drawImage @image, x, y, squareSize, squareSize
      return

    knightSquare = @board.knightSquare
    @context.drawImage @image, squareSize * knightSquare.fileIdx, squareSize * (8-knightSquare.rank), squareSize, squareSize

  drawHopNumbers: (hopNumbers) ->
    for squareCoord, hopNo of hopNumbers when hopNo > 0
      @drawHopNumber new Square(squareCoord), hopNo

  drawHopNumber: (square, hopNo) ->
    @context.textAlign = "center"
    @context.textBaseline = "middle"

    if square.isLight()
      @context.fillStyle = "#7d2c17"
    else
      #@context.fillStyle = "#7d2c17"
      @context.fillStyle = "darkgrey"

    squareSize = @squareSize()
    halfSquare = squareSize/2
 
    size = Math.floor(squareSize / 2)
    @context.font = size + "px '#{@fontFamily}'"

    @context.fillText hopNo.toString(), square.fileIdx*squareSize + halfSquare, (8-square.rank)*squareSize + halfSquare
  
  coordsToSquare: (coords) ->
    squareSize = @squareSize()
    fileIdx = Math.floor(coords.x / squareSize)
    rank = 8 - Math.floor(coords.y / squareSize)
    new Square FILES[fileIdx] + rank
    
  onMouseDown: (event) =>
    coords = @canvas.relMouseCoords event
    square = @coordsToSquare coords
    if square.coord == @board.knightSquare.coord
      @draging = true
      @canvas.onmousemove = @onMouseMove
      @mouseCoords = @coords
    else
      @pathsToShowIdx = -1
      @pathsToShowIdx2 = 0
      @pathsToShow = @board.calculatePaths square.coord

  onMouseMove: (event) =>
    if @draging
      @mouseCoords = @canvas.relMouseCoords event
 
  onMouseUp: (event) =>
    if @draging
      coords = @canvas.relMouseCoords event
      square = @coordsToSquare coords
      @board.knightSquare = square
    @draging = false
    @canvas.onmousemove = null
    @pathsToShow = null
    @pathsToShowIdx = -1


relMouseCoords = (event) ->
  totalOffsetX = 0
  totalOffsetY = 0
  canvasX = 0
  canvasY = 0
  currentElement = @

  totalOffsetX += currentElement.offsetLeft - currentElement.scrollLeft
  totalOffsetY += currentElement.offsetTop - currentElement.scrollTop
  while currentElement == currentElement.offsetParent
    totalOffsetX += currentElement.offsetLeft - currentElement.scrollLeft
    totalOffsetY += currentElement.offsetTop - currentElement.scrollTop

  canvasX = event.pageX - totalOffsetX
  canvasY = event.pageY - totalOffsetY

  return {x:canvasX, y:canvasY}

HTMLCanvasElement.prototype.relMouseCoords = relMouseCoords


displayBoardWithKnightOn = (knightCoord) ->
  board = new Board(new Square(knightCoord))
  view = new BoardView 'myCanvas', board
  view.draw()
  window.lastId = setInterval(view.draw, 10)

KNIGHT_IMG = new Image()
KNIGHT_IMG.src = 'img/wknight.png'
 
window.main = ->
  displayBoardWithKnightOn 'e4'

