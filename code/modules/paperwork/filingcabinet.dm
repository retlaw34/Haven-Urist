/* Filing cabinets!
 * Contains:
 *		Filing Cabinets
 *		Security Record Cabinets
 *		Medical Record Cabinets
 */


/*
 * Filing Cabinets
 */
/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "filingcabinet"
	density = 1
	anchored = 1
	atom_flags = ATOM_FLAG_CLIMBABLE
	obj_flags = OBJ_FLAG_ANCHORABLE
	var/list/can_hold = list(
		/obj/item/weapon/paper,
		/obj/item/weapon/folder,
		/obj/item/weapon/photo,
		/obj/item/weapon/paper_bundle,
		/obj/item/weapon/sample)
	var/secure = 0

/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"

/obj/structure/filingcabinet/wallcabinet
	name = "wall-mounted filing cabinet"
	desc = "A filing cabinet installed into a cavity in the wall to save space. Wow!"
	icon_state = "wallcabinet"
	density = 0
	obj_flags = 0


/obj/structure/filingcabinet/filingcabinet	//not changing the path to avoid unecessary map issues, but please don't name stuff like this in the future -Pete
	icon_state = "tallcabinet"


/obj/structure/filingcabinet/Initialize()
	for(var/obj/item/I in loc)
		if(is_type_in_list(I, can_hold))
			I.forceMove(src)
	. = ..()

/obj/structure/filingcabinet/attackby(obj/item/P as obj, mob/user as mob)
	if(is_type_in_list(P, can_hold))
		if(!user.unEquip(P, src))
			return
		add_fingerprint(user)
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		flick("[initial(icon_state)]-open",src)
		updateUsrDialog()
	else if(istype(P, /obj/item/weapon/screwdriver))
		if(secure)
			to_chat(user, "<span class='warning'>You can't see anywhere to unscrew that!</span>")
			return
		else
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You disassemble \the [src].</span>")
			var/obj/item/stack/material/steel/S =  new /obj/item/stack/material/steel(src.loc)
			S.amount = 2
			for(var/obj/item/b in contents)
				b.loc = (get_turf(src))
			qdel(src)
	else
		..()

/obj/structure/filingcabinet/attack_hand(mob/user as mob)
	if(contents.len <= 0)
		to_chat(user, "<span class='notice'>\The [src] is empty.</span>")
		return

	user.set_machine(src)
	var/dat = list("<center><table>")
	for(var/obj/item/P in src)
		dat += "<tr><td><a href='?src=[REF(src)];retrieve=[REF(P)]'>[P.name]</a></td></tr>"
	dat += "</table></center>"
	show_browser(user, "<html><head><title>[name]</title></head><body>[jointext(dat,null)]</body></html>", "window=filingcabinet;size=350x300")

/obj/structure/filingcabinet/attack_tk(mob/user)
	if(anchored)
		attack_self_tk(user)
	else
		..()

/obj/structure/filingcabinet/attack_self_tk(mob/user)
	if(contents.len)
		if(prob(40 + contents.len * 5))
			var/obj/item/I = pick(contents)
			I.loc = loc
			if(prob(25))
				step_rand(I)
			to_chat(user, "<span class='notice'>You pull \a [I] out of [src] at random.</span>")
			return
	to_chat(user, "<span class='notice'>You find nothing in [src].</span>")

/obj/structure/filingcabinet/Topic(href, href_list)
	if(href_list["retrieve"])
		show_browser(usr, "", "window=filingcabinet") // Close the menu

		//var/retrieveindex = text2num(href_list["retrieve"])
		var/obj/item/P = locate(href_list["retrieve"])//contents[retrieveindex]
		if(istype(P) && (P.loc == src) && src.Adjacent(usr))
			usr.put_in_hands(P)
			updateUsrDialog()
			flick("[initial(icon_state)]-open",src)
