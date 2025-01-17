/datum/storage_ui/tgui
	var/cached_ui_data

/datum/storage_ui/tgui/ui_host()
	return storage.ui_host()

/datum/storage_ui/tgui/show_to(var/mob/user)
	ui_interact(user)

/datum/storage_ui/tgui/hide_from(var/mob/user)
	ui_interact(user)

/datum/storage_ui/tgui/close_all()
	SStgui.close_uis(src)

/datum/storage_ui/tgui/on_open(var/mob/user)
	ui_interact(user)

/datum/storage_ui/tgui/on_insertion(var/mob/user)
	cached_ui_data = null
	ui_interact(user)

/datum/storage_ui/tgui/on_post_remove(var/mob/user, var/obj/item/W)
	cached_ui_data = null
	ui_interact(user)

/datum/storage_ui/tgui/ui_state(mob/user)
	return ui_physical_state()

/datum/storage_ui/tgui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Storage")
		ui.open()

/datum/storage_ui/tgui/ui_data()
	if(!cached_ui_data)

		var/list/items_by_name_and_type = list()
		for(var/obj/item/W in storage)
			group_by(items_by_name_and_type, "[W.name]\\[W.type]", W)

		var/list/item_list = list()
		for(var/name_and_type in items_by_name_and_type)
			var/list/items = items_by_name_and_type[name_and_type]
			var/obj/item/first_item = items[1]
			item_list[++item_list.len] = list("name" = first_item.name, "type" = any2ref(first_item.type), "amount" = items.len)

		cached_ui_data = list(
			"items" = item_list
		)

	return cached_ui_data

/datum/storage_ui/tgui/ui_act(action, params)
	if(..())
		return TRUE

	if(action == "remove_item")
		var/item_type = locate(params["type"])
		if(remove_item_by_name_and_type(params["name"], item_type))
			return TRUE

/datum/storage_ui/tgui/proc/remove_item_by_name_and_type(var/name, var/item_type)
	if(!istext(name))
		return FALSE
	if(!item_type)
		return FALSE
	for(var/obj/item/W in storage)
		if(W.name == name && W.type == item_type)
			if(storage.remove_from_storage(W))
				return TRUE
	return FALSE
