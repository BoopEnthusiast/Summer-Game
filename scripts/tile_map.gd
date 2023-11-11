extends TileMap

@export var texture: Texture2D 
@export var color_seed: int

var colors: Dictionary 


func _ready():
	pass # temp while I figure out how to change the texture of the tileset
	
	for i in range(texture.get_width()):
		for o in range(texture.get_height()):
			colors[texture.get_image().get_pixel(i, o)] = null
	
	seed(color_seed)
	var random_hue := randf()
	var count := 0.0
	for i in colors:
		count += 1.0 / colors.size()
		colors[i] = Color.from_ok_hsl(random_hue, 1, count)
	
	for i in range(texture.get_width()):
		for o in range(texture.get_height()):
			texture.get_image().set_pixel(i, o, colors[texture.get_image().get_pixel(i, o)])
