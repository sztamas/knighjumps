root = exports ? this


FILES = 'abcdefgh'
SHOW_PATHS_FOR = 2000


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
      DARK_SQUARE_TEXT: 'darkgrey'
      LIGHT_SQUARE_TEXT: '#7d2c17'
    @showCoordinates = true
    @fontFamily = 'Sanchez'

    @image = KNIGHT_IMG
  
    @showingPaths = false
    @pathsToShowIdx = -1

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
      if square.rank == 1
        @showFileCoord square 
      if square.file == 'a'
        @showRankCoord square

  drawSquareText: (square, hAlign, vAlign, font, color, margin, text) ->
    squareSize = @squareSize()
    @context.fillStyle = color
    @context.font = font
    @context.textAlign = hAlign
    @context.textBaseline = vAlign
    if hAlign == 'left'
      x = (square.fileIdx * squareSize) + margin
    else if hAlign == 'right'
      x = ((square.fileIdx+1) * squareSize) - margin
    else if hAlign == 'center'
      x = (square.fileIdx * squareSize) + squareSize/2
    else
      throw "Invalid hAlign '#{hAlign}'"

    if vAlign == 'top'
      y = ((8-square.rank) * squareSize) + margin
    else if vAlign == 'bottom'
      y = ((9-square.rank) * squareSize) - margin
    else if vAlign == 'middle'
      y = ((8-square.rank) * squareSize) + squareSize/2
    else
      throw "Invalid vAlign '#{vAlign}'"
      
    @context.fillText text, x, y


  coordTextColor: (square) ->
     @color (if square.isDark() then 'LIGHT_SQUARE' else 'DARK_SQUARE')

  showFileCoord: (square) ->
    textColor = @coordTextColor(square)
    @drawSquareText square, "right", "bottom", "12px Colibri", textColor, 2, square.file

  showRankCoord: (square) ->
    textColor = @coordTextColor(square)
    @drawSquareText square, "left", "top", "12px Colibri", textColor, 2, square.rank

  clear: ->
    @context.clearRect(0, 0, @canvas.width, @canvas.height)

  draw: =>
    @clear()
    @drawBoard()
    @drawHopNumbers @board.calculateHopNumbers()
    @drawKnight()
    if @showingPaths
       if not @pathsDrawnAt or @pathsDrawnAt < (new Date() - SHOW_PATHS_FOR)
         @pathsDrawnAt = new Date() - 0
         @incPathToShowIdx()
       if @pathsToShowIdx == -1
         @drawPaths @pathsToShow
       else
         @drawPaths @pathsToShow[@pathsToShowIdx..@pathsToShowIdx]
    if @dragging or @showingPaths
      setTimeout @draw, 10

  incPathToShowIdx: =>
    @pathsToShowIdx += 1
    if @pathsToShowIdx >= @pathsToShow.length
      @pathsToShowIdx = -1
    

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
    @context.beginPath()

    lineArrowJoinPoint = calculateLineArrowJoinPoint(startPoint, endPoint)

    @context.moveTo startPoint.x, startPoint.y
    @context.lineTo lineArrowJoinPoint.x, lineArrowJoinPoint.y

    @context.stroke()
    drawArrow(@context, startPoint, endPoint)

  drawBoard: ->
    for square in @board.squares()
      @drawSquare square

  drawKnight: () ->
    squareSize = @squareSize()
    half = Math.floor squareSize / 2
    if @dragging and @mouseCoords
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
    if square.isLight()
      color = @color 'LIGHT_SQUARE_TEXT'
    else
      color = @color 'DARK_SQUARE_TEXT'

    size = Math.floor(@squareSize() / 2)
    font = size + "px '#{@fontFamily}'"

    @drawSquareText square, "center", "middle", font, color, 0, hopNo.toString()
  
  coordsToSquare: (coords) ->
    squareSize = @squareSize()
    fileIdx = Math.floor(coords.x / squareSize)
    rank = 8 - Math.floor(coords.y / squareSize)
    new Square FILES[fileIdx] + rank
    
  onMouseDown: (event) =>
    coords = @canvas.relMouseCoords event
    square = @coordsToSquare coords
    if square.coord == @board.knightSquare.coord
      @dragging = true
      @canvas.onmousemove = @onMouseMove
      @mouseCoords = @coords
    else
      @pathsToShowIdx = -2
      @pathsToShow = @board.calculatePaths square.coord
      @showingPaths = true
    setTimeout @draw, 10

  onMouseMove: (event) =>
    if @dragging
      @mouseCoords = @canvas.relMouseCoords event
 
  onMouseUp: (event) =>
    if @dragging
      coords = @canvas.relMouseCoords event
      square = @coordsToSquare coords
      @board.knightSquare = square
    @dragging = false
    @showingPaths = false
    @pathsDrawnAt = null
    @canvas.onmousemove = null


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


KNIGHT_IMG = new Image()

displayBoardWithKnightOn = (knightCoord) ->
  KNIGHT_IMG.src = 'img/wknight.png'
  board = new Board(new Square(knightCoord))
  view = new BoardView 'myCanvas', board
  view.draw()
  KNIGHT_IMG.onLoad = ->
    view.draw()
 
root.main = ->
  displayBoardWithKnightOn 'e4'

