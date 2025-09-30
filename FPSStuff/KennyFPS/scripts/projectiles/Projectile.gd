extends Node3D
class_name Projectile

signal Hit_Successfull

@export_enum ("Hitscan","Rigidbody_Projectile","over_ride") var Projectile_Type: String = "Rigidbody_Projectile"
@export var Display_Debug_Decal: bool = false

@export_category("Rigid Body Projectile Properties")
@export var Projectile_Velocity: int = 20
@export var Expirey_Time: int = 10
@export var Rigid_Body_Projectile: PackedScene
@export var pass_through: bool = false

@onready var Debug_Bullet = preload("res://objects/projectiles/hit_debug.tscn")

var damage: float = 0
var Projectiles_Spawned: Array = []
var hit_objects: Array = []

func _ready() -> void:
	get_tree().create_timer(Expirey_Time).timeout.connect(_on_timer_timeout)

func _Set_Projectile(_damage: int = 0, _spread: Vector2 = Vector2.ZERO, _Range: int = 1000, origin_point: Vector3 = Vector3.ZERO):
	damage = _damage
	Fire_Projectile(_spread, _Range, Rigid_Body_Projectile, origin_point)

func Fire_Projectile(_spread: Vector2, _range: int, _proj: PackedScene, origin_point: Vector3):
	var Camera_Collision = Camera_Ray_Cast(_spread, _range)
	match Projectile_Type:
		"Hitscan":
			Hit_Scan_Collision(Camera_Collision, damage, origin_point)
		"Rigidbody_Projectile":
			Launch_Rigid_Body_Projectile(Camera_Collision, _proj, origin_point)
		"over_ride":
			_over_ride_collision(Camera_Collision, damage)

func _over_ride_collision(_camera_collision: Array, _damage: float) -> void:
	pass

func Camera_Ray_Cast(_spread: Vector2 = Vector2.ZERO, _range: float = 1000):
	var _Camera = get_viewport().get_camera_3d()
	var _Viewport = get_viewport().get_size()
	var Ray_Origin = _Camera.project_ray_origin(_Viewport / 2)
	var Ray_End = (Ray_Origin + _Camera.project_ray_normal((_Viewport / 2) + Vector2i(_spread)) * _range)
	var New_Intersection: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Ray_Origin, Ray_End)
	New_Intersection.set_collision_mask(0b11111111)
	New_Intersection.set_hit_from_inside(false)
	var Intersection = get_world_3d().direct_space_state.intersect_ray(New_Intersection)
	if not Intersection.is_empty():
		var Collision = [Intersection.collider, Intersection.position, Intersection.normal]
		return Collision
	else:
		return [null, Ray_End, null]

func Hit_Scan_Collision(Collision: Array, _damage: float, origin_point: Vector3):
	var Point = Collision[1]
	if Collision[0]:
		Load_Decal(Point, Collision[2])
		var Bullet = get_world_3d().direct_space_state
		var Bullet_Direction = (Point - origin_point).normalized()
		var New_Intersection = PhysicsRayQueryParameters3D.create(origin_point, Point + Bullet_Direction * 2)
		New_Intersection.set_collision_mask(0b11111111)
		New_Intersection.set_hit_from_inside(false)
		New_Intersection.set_exclude(hit_objects)
		var Bullet_Collision = Bullet.intersect_ray(New_Intersection)
		if Bullet_Collision and Bullet_Collision.collider and Bullet_Collision.collider.has_method("damage"):
			Bullet_Collision.collider.damage(_damage)
			Hit_Successfull.emit()
	queue_free()

func Load_Decal(_pos: Vector3, _normal: Vector3):
	if Display_Debug_Decal:
		var rd = Debug_Bullet.instantiate()
		get_tree().current_scene.add_child(rd)
		rd.global_translate(_pos + (_normal * .01))

func Launch_Rigid_Body_Projectile(Collision_Data: Array, _projectile: PackedScene, _origin_point: Vector3):
	var _Point = Collision_Data[1]
	var _proj: RigidBody3D = _projectile.instantiate()
	_proj.position = _origin_point
	get_tree().current_scene.add_child(_proj)
	_proj.look_at(_Point)
	Projectiles_Spawned.push_back(_proj)
	# Connect to body_entered for walls/floors (no need to pass _Norm, it's in signal)
	_proj.body_entered.connect(_on_body_entered.bind(_proj))
	# Connect to EnemyDetector Area3D for Area3D enemies
	var enemy_detector = _proj.get_node_or_null("EnemyDetector")
	if enemy_detector:
		enemy_detector.area_entered.connect(_on_area_entered.bind(_proj))
	var _Direction = (_Point - _origin_point).normalized()
	_proj.set_linear_velocity(_Direction * Projectile_Velocity)

func _on_body_entered(_body: Node, _proj: RigidBody3D):
	# Hit something solid (wall, floor, etc) - always cleanup
	# Use projectile forward direction as approximate normal
	var approx_normal: Vector3 = -_proj.global_transform.basis.z
	Load_Decal(_proj.get_position(), approx_normal)
	_cleanup_projectile(_proj)

func _on_area_entered(area: Area3D, _proj: RigidBody3D):
	# Check if we hit an Area3D enemy with damage method
	if area and area.has_method("damage"):
		area.damage(damage)
		Hit_Successfull.emit()
	# Use projectile forward direction as approximate normal
	var approx_normal: Vector3 = -_proj.global_transform.basis.z
	Load_Decal(_proj.get_position(), approx_normal)
	_cleanup_projectile(_proj)

func _cleanup_projectile(_proj: RigidBody3D):
	if is_instance_valid(_proj):
		_proj.queue_free()
	Projectiles_Spawned.erase(_proj)
	if Projectiles_Spawned.is_empty():
		queue_free()

func _on_timer_timeout():
	queue_free()
