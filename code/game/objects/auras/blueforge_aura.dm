/obj/aura/blueforge_aura
	name = "Blueforge Aura"
	icon = 'icons/mob/human_races/species/eyes.dmi'
	icon_state = "eyes_blueforged_s"
	plane = ABOVE_HUMAN_PLANE
	layer = MOB_LAYER

/obj/aura/blueforge_aura/life_tick()
	user.adjustToxLoss(-10)
	return 0

/obj/aura/blueforge_aura/bullet_act(var/obj/item/projectile/P)
	if(P.damtype == DAMAGE_TYPE_BURN)
		P.damage *=2
	else if(P.agony || P.stun)
		return AURA_FALSE
	return 0
