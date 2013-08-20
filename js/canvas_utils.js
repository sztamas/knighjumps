// Generated by CoffeeScript 1.6.3
(function() {
  var DEFAULT_ARROW_LENGTH, DEFAULT_ARROW_SHAPE, drawPolygon, root, rotatePoint, rotateShape, translateShape,
    _this = this;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  drawPolygon = function(context, shape) {
    var lastPoint, point, _i, _len;
    context.beginPath();
    lastPoint = shape[shape.length - 1];
    context.moveTo(lastPoint[0], lastPoint[1]);
    for (_i = 0, _len = shape.length; _i < _len; _i++) {
      point = shape[_i];
      context.lineTo(point[0], point[1]);
    }
    context.closePath();
    return context.fill();
  };

  translateShape = function(shape, x, y) {
    var point, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = shape.length; _i < _len; _i++) {
      point = shape[_i];
      _results.push([point[0] + x, point[1] + y]);
    }
    return _results;
  };

  rotatePoint = function(angle, x, y) {
    return [x * Math.cos(angle) - y * Math.sin(angle), x * Math.sin(angle) + y * Math.cos(angle)];
  };

  rotateShape = function(shape, angle) {
    var point, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = shape.length; _i < _len; _i++) {
      point = shape[_i];
      _results.push(rotatePoint(angle, point[0], point[1]));
    }
    return _results;
  };

  DEFAULT_ARROW_SHAPE = [[0, 0], [-25, -12], [-25, 12]];

  DEFAULT_ARROW_LENGTH = 25;

  root.drawArrow = function(context, startPoint, endPoint, arrow) {
    var lineAngle;
    if (arrow == null) {
      arrow = DEFAULT_ARROW_SHAPE;
    }
    lineAngle = Math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x);
    return drawPolygon(context, translateShape(rotateShape(arrow, lineAngle), endPoint.x, endPoint.y));
  };

  root.calculateLineArrowJoinPoint = function(startPoint, endPoint, arrowLength) {
    var lineAngle, lineEndPoint;
    if (arrowLength == null) {
      arrowLength = DEFAULT_ARROW_LENGTH;
    }
    lineAngle = Math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x);
    lineEndPoint = rotatePoint(lineAngle, -arrowLength, 0);
    return {
      x: endPoint.x + lineEndPoint[0],
      y: endPoint.y + lineEndPoint[1]
    };
  };

}).call(this);