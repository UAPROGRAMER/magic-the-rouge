extends Node2D

class_name AttackParticles

@onready var attack_particles: CPUParticles2D = $attack_particles

func activate() -> void:
	attack_particles.emitting = true
