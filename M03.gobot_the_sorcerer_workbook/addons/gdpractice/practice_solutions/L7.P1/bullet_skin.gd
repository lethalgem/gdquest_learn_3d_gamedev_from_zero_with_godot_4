extends CSGSphere3D

var tween: Tween


# Plays the appear animation, scaling the bullet up.
func appear() -> void:
	tween = create_tween()
	scale = Vector3.ZERO
	tween.tween_property(self, "scale", Vector3.ONE, 0.2)


# Plays the bullet's destroy animation and frees the skin.
func destroy() -> void:
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)
	tween.tween_callback(queue_free)
