extends Node;

@export var randomSeed:int;
@export var widthPerChunk: int = 5;
@export var heightPerChunk: int = 5;
@export var distBtwPoints: float = 30;
@export var distBtwVariation: float = .3;
@export var voronoiTolerance:float = .3;

var view;

func randomNumOnCoords(coords:Vector2, initialSeed:int):
	var result = initialSeed
	var randGen = RandomNumberGenerator.new();
	randGen.seed = coords.x;
	result += randGen.randi();
	var newy = randGen.randi() + coords.y;
	randGen.seed = newy;
	result += randGen.randi();
	randGen.seed = result;
	result = randGen.randi();
	return result;

func generateChunkPoints(coords:Vector2, wRange:Vector2=Vector2(0, widthPerChunk), hRange:Vector2=Vector2(0, heightPerChunk)):
	var localRandSeed = randomNumOnCoords(coords, randomSeed);
	var initPoints = PackedVector2Array();
	for w in range(wRange.x, wRange.y):
		for h in range(hRange.x, hRange.y):
			var randGen = RandomNumberGenerator.new();
			var pointRandSeed = randomNumOnCoords(Vector2(w,h), localRandSeed);
			randGen.seed = pointRandSeed;
			var newPoint = Vector2(w*distBtwPoints + randGen.randf_range(-distBtwVariation, distBtwVariation)*distBtwPoints, h*distBtwPoints + randGen.randf_range(-distBtwVariation, distBtwVariation)*distBtwPoints);
			initPoints.append(newPoint)
	return initPoints;

func generateChunkVoronoi(coords:Vector2):
	var initPoints = generateChunkPoints(coords);
	var sorroundingPoints = PackedVector2Array();
	for i in range(-1, 2):
		for j in range(-1, 2):
			if (!(i == 0 && j == 0)):
				var xmin = 0;
				var xmax = 1;
				var ymin = 0;
				var ymax = 1;
				if (i == -1):
					xmin = 1 - voronoiTolerance;
				if (i == +1):
					xmax = voronoiTolerance;
				if (j== -1):
					ymin = 1 - voronoiTolerance;
				if (j== 1):
					ymax = voronoiTolerance;
				var tempPoints = generateChunkPoints(Vector2(coords.x+i, coords.y+j), Vector2(xmin*widthPerChunk, xmax*widthPerChunk), Vector2(ymin*heightPerChunk, ymax*heightPerChunk));
				var resultPoints = PackedVector2Array();
				for point in tempPoints:
					var tempPoint = point + Vector2(i * widthPerChunk * distBtwPoints, j * heightPerChunk * distBtwPoints);
					resultPoints.append(tempPoint);
				sorroundingPoints.append_array(resultPoints)
	var allPoints = initPoints+sorroundingPoints;
	var allDelauney = Geometry2D.triangulate_delaunay(allPoints);
	var triangleArray = [];
	for triple in range(0, allDelauney.size()/3):
		triangleArray.append([allDelauney[triple*3], allDelauney[triple*3+1], allDelauney[triple*3+2]]);
	var circumcenters = PackedVector2Array();
	for triple in triangleArray:
		circumcenters.append(getCircumcenter(allPoints[triple[0]], allPoints[triple[1]], allPoints[triple[2]]));
	var vCtrIdxWithVerts = [];
	for point in range(initPoints.size()):
		var tempVerts = PackedVector2Array();
		for triangle in range(triangleArray.size()):
			if (point == triangleArray[triangle][0] || point == triangleArray[triangle][1] || point == triangleArray[triangle][2]):
				tempVerts.append(circumcenters[triangle]);
		tempVerts = clowckwisePoints(initPoints[point], tempVerts)
		vCtrIdxWithVerts.append([initPoints[point], tempVerts]);
	
	return vCtrIdxWithVerts;

func clowckwisePoints(center:Vector2, sorrounding:PackedVector2Array):
	var result = PackedVector2Array();
	var angles = PackedFloat32Array();
	var sortedIndexes = PackedInt32Array();
	for point in sorrounding:
		angles.append(center.angle_to_point(point));
	var remainingIdx = PackedInt32Array();
	for angle in range(angles.size()):
		remainingIdx.append(angle);
	for angle in range(angles.size()):
		var currentMin = PI;
		var currentTestIdx = 0;
		for test in range(remainingIdx.size()):
			if (angles[remainingIdx[test]] < currentMin):
				currentTestIdx = test;
				currentMin = angles[remainingIdx[test]];
		sortedIndexes.append(remainingIdx[currentTestIdx]);
		remainingIdx.remove_at(currentTestIdx);
	for index in sortedIndexes:
		result.append(sorrounding[index]);
	return result;

func getCircumcenter(a:Vector2, b:Vector2, c:Vector2):
	var result = Vector2(0,0)
	var midpointAB = Vector2((a.x+b.x)/2,(a.y+b.y)/2);
	var slopePerpAB = -((b.x-a.x)/(b.y-a.y));
	var midpointAC = Vector2((a.x+c.x)/2,(a.y+c.y)/2);
	var slopePerpAC = -((c.x-a.x)/(c.y-a.y));
	var bOfPerpAB = midpointAB.y - (midpointAB.x * slopePerpAB);
	var bOfPerpAC = midpointAC.y - (midpointAC.x * slopePerpAC);
	result.x = (bOfPerpAB - bOfPerpAC)/(slopePerpAC - slopePerpAB);
	result.y = slopePerpAB*result.x + bOfPerpAB;
	return result;

func displayVornoiFromChunk(chunkLoc:Vector2):
	view = get_child(0)
	view.randSeed = randomNumOnCoords(chunkLoc, randomSeed);
	var voronoi = generateChunkVoronoi(chunkLoc);
	for each in voronoi:
		view.displayPolygon(Vector2(chunkLoc.x*widthPerChunk*distBtwPoints,chunkLoc.y*heightPerChunk*distBtwPoints), each[1]);
	view.displayPoints(Vector2(chunkLoc.x*widthPerChunk*distBtwPoints,chunkLoc.y*heightPerChunk*distBtwPoints), generateChunkPoints(chunkLoc))
	pass

func _ready():
	for w in 10:
		for h in 10:
			if (w == 5 && h == 5):
				null;
			else:
				displayVornoiFromChunk(Vector2(w, h));
	pass;
