# Godot Chunked Vornoi Generator

This is a small project which creates Vornoi diagrams based on chunks, and is therefore infinite and consistent. Feel free to pull bits and pieces from it, or the whole thing - but let me know if you found it useful!

## Files

The important files are Main.tscn, Main.gd, and View.gd.

Main.tscn consists of a Main node and a View node, with the respective scripts attached. The main node generates Voronoi diagrams, and the View node displays them as Polygons2d. 

## Variables

Main.gd contains multiple variables. They are:
* randomSeed - the seed for the map
* widthPerChunk - how many points wide each chunk is
* heightPerChunk - how many points high each chunk is
* distBtwPoints - the distance in units between each point in a chunk
* distBtwVariation - this script generates pseudorandom points; this changes how much randomness there is (specifically, once the points are generated in a grid, how far randomly should the points move, relative to the distBtwPoints variable. I reccomend to setting this to no more than .5, as anything more than that can cause overlap between points).
* voronoiTolerance - this script generates voronois based on the adjacent chunks; this setting tells teh script what proportion of points from adjacent chunks to look at. This will ideally be higher the smaller your chunks are, and lower the bigger your chunks are.
* view - just a holder for the child view node

## Functions
### Main
* randomNumOnCoords - this function takes a vector chunk position, which should be integers (e.g. Vector2(1000, 432)), and an initial seed, and generates a random seed speicifc to those chunk coordinates. Each chunk uses this value for generation of its own points, which make them different from other chunks. This value is reproducible with the initial seed and the vector chunk position. 
* generateCunkPoints - this generates the points in a chunk within the speciifed height and width of that chunk (also integer vectors). By default, it generates points in the whole chunk, but given a height or width, it will generate only the points within that initial height and width.
* generateChunkVoronoi - where the magic happens! Given a chunk coordinate vector, this function generates that chunks points, its neighbor's relevant points, then uses Godot's built in Delaunay triangulation to create Delauney triangles, from which it creates the voronoi polygons. It returns an array of arrays, which cointain the voronoi's 'center' delauney point, and a PoolVector2Array of the polygon vertices.
* clockwisePoints - this function takes a center point and points sorrounding it, then returns the sorrounding points in clockwise order around the center point. This is necessary to make Godot display the Polygon 2d correctly.
* getCircumCenter - this evaulates the circumcenter of a Delaunay triangle, which is one of the vertices of the resulting Voronoi polygon.
* displayVornoiFromChunk - this function uses the view to generate and display a chunk using Polygon2d's. It calls functions from View.gd.

### View
* displayPoints - this displays points provided an array of points, an offset, and an optional color. It is used here to display the original points, or 'centers' of the voronois.
* displayPolygon - this displays a polygon provided a PoolVector2Array, and an offset. The color of the polygon is generated from the randSeed imported from Main, but then progressively changes it for the chunk.
