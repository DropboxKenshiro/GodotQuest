extends Panel

onready var hero = $"../../../Hero"

export (PoolColorArray) var class_color_list

func _ready():
	$HeroClass.text = hero.hero_name
	$HeroClass.modulate = self.class_color_list[hero.hero_class]
	
	$Level.text = "LVL" + String(hero.level).pad_zeros(2)
