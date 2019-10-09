extends Object

class_name Segment

var begin_point = Vector2()
var end_point = Vector2()

enum {DIR_HORIZONTAL,DIR_VERTICAL,DIR_NOTRIGHT}

func _init(begin,end):
	begin_point = begin
	end_point = end

func get_length():
	return begin_point.distance_to(end_point)

# metropolitan length, a length which is measured only in right angle connected segments
func get_metro_length():
	return abs(begin_point.x-end_point.x) + abs(begin_point.y-end_point.y)

func get_direction():
	if(begin_point.x == end_point.x):
		return DIR_VERTICAL
	elif(begin_point.y == end_point.y):
		return DIR_HORIZONTAL
	else:
		return DIR_NOTRIGHT

func is_point_on(point):
	if(self.get_direction() == DIR_VERTICAL):
		if(point.x == self.begin_point.x and point.y >= min(self.begin_point.y,self.end_point.y) and point.y <= max(self.begin_point.y,self.end_point.y)):
			return true
		else:
			return false
	elif(self.get_direction() == DIR_HORIZONTAL):
		if(point.y == self.begin_point.y and point.x >= min(self.begin_point.x,self.end_point.x) and point.x <= max(self.begin_point.x,self.end_point.x)):
			return true
		else:
			return false