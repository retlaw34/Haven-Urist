/obj/structure/iv_drip
	name = "\improper IV drip"
	icon = 'icons/obj/iv_drip.dmi'
	anchored = 0
	density = 0
	var/mob/living/carbon/human/attached
	var/mode = 1 // 1 is injecting, 0 is taking blood.
	var/obj/item/weapon/reagent_containers/beaker
	var/list/transfer_amounts = list(REM, 1, 2)
	var/transfer_amount = 1

/obj/structure/iv_drip/Initialize()
	. = ..()
	queue_icon_update()

/obj/structure/iv_drip/verb/set_APTFT()
	set name = "Set IV transfer amount"
	set category = "Object"
	set src in range(1)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in transfer_amounts
	if(N)
		transfer_amount = N

/obj/structure/iv_drip/queue_icon_update()
	overlays.Cut()

	var/mutable_appearance/base = mutable_appearance(icon, "nothing")
	base.icon_state = "[!!beaker && "beaker" || "nothing"][!!attached && "_hooked" || ""]"
	overlays += base

	if(beaker)
		var/datum/reagents/reagents = beaker.reagents
		var/percent = round((reagents.total_volume / beaker.volume) * 100)
		if(reagents.total_volume)
			var/mutable_appearance/filling = mutable_appearance(icon, "reagent")
			switch(percent)
				if(0)
					filling.icon_state = "reagentempty"
				if(1 to 9)
					filling.icon_state = "reagent0"
				if(10 to 24)
					filling.icon_state = "reagent10"
				if(25 to 49)
					filling.icon_state = "reagent25"
				if(50 to 74)
					filling.icon_state = "reagent50"
				if(75 to 79)
					filling.icon_state = "reagent75"
				if(80 to 90)
					filling.icon_state = "reagent80"
				if(91 to INFINITY)
					filling.icon_state = "reagent100"
			filling.color = reagents.get_color()
			overlays += filling

		// I know this is bad, but fuck it
		if(istype(beaker, /obj/item/weapon/reagent_containers/ivbag))
			var/mutable_appearance/ivbaglabel = mutable_appearance(icon, "ivbag_label")
			overlays += ivbaglabel

		if(attached)
			var/mutable_appearance/light = mutable_appearance(icon, "light_full")
			if(percent < 15)
				light.icon_state = "light_low"
			else if(percent < 60)
				light.icon_state = "light_mid"
			overlays += light

/obj/structure/iv_drip/MouseDrop(over_object, src_location, over_location)
	if(!CanMouseDrop(over_object))
		return
	if(attached)
		drip_detach()
	else if(ishuman(over_object))
		hook_up(over_object, usr)

/obj/structure/iv_drip/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/reagent_containers))
		if(!isnull(src.beaker))
			to_chat(user, "There is already a reagent container loaded!")
			return
		if(!user.unEquip(W, src))
			return
		beaker = W
		to_chat(user, "You attach \the [W] to \the [src].")
		queue_icon_update()
	else
		return ..()

/obj/structure/iv_drip/Destroy()
	STOP_PROCESSING(SSobj,src)
	attached = null
	qdel(beaker)
	beaker = null
	. = ..()

/obj/structure/iv_drip/Process()
	if(attached)
		if(!Adjacent(attached))
			visible_message("The needle is ripped out of [src.attached], doesn't that hurt?")
			attached.apply_damage(1, DAMAGE_TYPE_BRUTE, pick(BP_R_ARM, BP_L_ARM))
			attached = null
			update_icon()
			return PROCESS_KILL
	else
		return PROCESS_KILL

	if(!beaker)
		return

	//SSObj fires twice as fast as SSMobs, so gotta slow down to not OD our victims.
	if(SSobj.times_fired % 2)
		return

	if(mode) // Give blood
		if(beaker.volume > 0)
			beaker.reagents.trans_to_mob(attached, transfer_amount, CHEM_BLOOD)
			queue_icon_update()
	else // Take blood
		var/amount = beaker.reagents.maximum_volume - beaker.reagents.total_volume
		amount = min(amount, 4)

		if(amount == 0) // If the beaker is full, ping
			if(prob(5)) visible_message("\The [src] pings.")
			return

		if(!attached.should_have_organ(BP_HEART))
			return

		// If the human is losing too much blood, beep.
		if(attached.get_blood_volume() < BLOOD_VOLUME_SAFE * 1.05)
			visible_message("\The [src] beeps loudly.")

		if(attached.take_blood(beaker,amount))
			queue_icon_update()

/obj/structure/iv_drip/attack_hand(mob/user as mob)
	if(attached)
		drip_detach()
	else if(beaker)
		beaker.dropInto(loc)
		beaker = null
		queue_icon_update()
	else
		return ..()

/obj/structure/iv_drip/attack_robot(var/mob/user)
	if(Adjacent(user))
		attack_hand(user)

/obj/structure/iv_drip/verb/drip_detach()
	set category = "Object"
	set name = "Detach IV Drip"
	set src in range(1)

	if(!attached)
		return

	if(!usr.Adjacent(attached))
		to_chat(usr, "<span class='warning'>You are too far away from the [attached]!</span>")
		return

	visible_message("\The [attached] is taken off \the [src].")
	attached = null

	queue_icon_update()
	STOP_PROCESSING(SSobj,src)

/obj/structure/iv_drip/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle IV Mode"
	set src in view(1)

	if(!istype(usr, /mob/living))
		to_chat(usr, "<span class='warning'>You can't do that.</span>")
		return

	if(usr.incapacitated())
		return

	mode = !mode
	to_chat(usr, "The IV drip is now [mode ? "injecting" : "taking blood"].")

/obj/structure/iv_drip/examine(mob/user)
	. = ..(user)

	if (get_dist(src, user) > 2)
		return

	to_chat(user, "The IV drip is [mode ? "injecting" : "taking blood"].")
	to_chat(user, "It is set to transfer [transfer_amount]u of chemicals per cycle.")

	if(beaker)
		if(beaker.reagents && beaker.reagents.total_volume)
			to_chat(usr, "<span class='notice'>Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid.</span>")
		else
			to_chat(usr, "<span class='notice'>Attached is an empty [beaker].</span>")
	else
		to_chat(usr, "<span class='notice'>No chemicals are attached.</span>")

	to_chat(usr, "<span class='notice'>[attached || "No one"] is hooked up to it.</span>")

/obj/structure/iv_drip/proc/rip_out()
	visible_message("The needle is ripped out of [src.attached], doesn't that hurt?")
	attached.apply_damage(1, DAMAGE_TYPE_BRUTE, pick(BP_R_ARM, BP_L_ARM), damage_flags=DAMAGE_FLAGS_SHARP)
	attached = null

/obj/structure/iv_drip/proc/hook_up(mob/living/carbon/human/target, mob/user)
	visible_message("\The [usr] hooks \the [target] up to \the [src].")
	attached = target
	queue_icon_update()
	START_PROCESSING(SSobj,src)
