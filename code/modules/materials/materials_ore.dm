/obj/item/weapon/ore
	name = "ore"
	icon_state = "lump"
	icon = 'icons/obj/materials/ore.dmi'
	randpixel = 8
	w_class = 2
	var/material/material
	var/datum/geosample/geologic_data

/obj/item/weapon/ore/get_material()
	return material

/obj/item/weapon/ore/New(var/newloc, var/_mat)
	if(_mat)
		matter = list()
		matter[_mat] = SHEET_MATERIAL_AMOUNT
	..(newloc)

/obj/item/weapon/ore/Initialize()
	for(var/stuff in matter)
		var/material/M = SSmaterials.get_material_by_name(stuff)
		if(M)
			name = M.ore_name
			desc = M.ore_desc || "A lump of ore."
			material = M
			color = M.icon_colour
			icon_state = M.ore_icon_overlay
			if(M.ore_desc)
				desc = M.ore_desc
			if(icon_state == "dust")
				slot_flags = SLOT_HOLSTER
			break
	. = ..()

// POCKET SAND!
/obj/item/weapon/ore/throw_impact(atom/hit_atom)
	..()
	if(icon_state == "dust")
		var/mob/living/carbon/human/H = hit_atom
		if(istype(H) && H.has_eyes() && prob(85))
			to_chat(H, "<span class='danger'>Some of \the [src] gets in your eyes!</span>")
			H.eye_blind += 5
			H.eye_blurry += 10
			QDEL_IN(src, 1)

// Map definitions.
/obj/item/weapon/ore/uranium/New(var/newloc)
	..(newloc, "pitchblende")
/obj/item/weapon/ore/iron/New(var/newloc)
	..(newloc, "hematite")
/obj/item/weapon/ore/coal/New(var/newloc)
	..(newloc, "graphene")
/obj/item/weapon/ore/glass/New(var/newloc)
	..(newloc, "sand")
/obj/item/weapon/ore/silver/New(var/newloc)
	..(newloc, "silver")
/obj/item/weapon/ore/gold/New(var/newloc)
	..(newloc, "gold")
/obj/item/weapon/ore/diamond/New(var/newloc)
	..(newloc, "diamond")
/obj/item/weapon/ore/osmium/New(var/newloc)
	..(newloc, "platinum")
/obj/item/weapon/ore/hydrogen/New(var/newloc)
	..(newloc, "mhydrogen")
/obj/item/weapon/ore/slag/New(var/newloc)
	..(newloc, "waste")
/obj/item/weapon/ore/phoron/New(var/newloc)
	..(newloc, "phoron")
