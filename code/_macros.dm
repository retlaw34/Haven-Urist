#define PUBLIC_GAME_MODE SSticker.master_mode

#define Clamp(value, low, high) 	(value <= low ? low : (value >= high ? high : value))
#define CLAMP01(x) 		(Clamp(x, 0, 1))

#define get_turf(A) get_step(A,0)

#define isAI(A) istype(A, /mob/living/silicon/ai)

#define isalien(A) istype(A, /mob/living/carbon/alien)

#define isanimal(A) istype(A, /mob/living/simple_animal)

#define isairlock(A) istype(A, /obj/machinery/door/airlock)

#define isatom(A) istype(A, /atom)

#define isbrain(A) istype(A, /mob/living/carbon/brain)

#define iscarbon(A) istype(A, /mob/living/carbon)

#define iscolorablegloves(A) (istype(A, /obj/item/clothing/gloves/color)||istype(A, /obj/item/clothing/gloves/insulated)||istype(A, /obj/item/clothing/gloves/thick))

#define isclient(A) istype(A, /client)

#define iscorgi(A) istype(A, /mob/living/simple_animal/corgi)

#define is_drone(A) istype(A, /mob/living/silicon/robot/drone)

#define isEye(A) istype(A, /mob/observer/eye)

#define ishuman(A) istype(A, /mob/living/carbon/human)

#define isitem(A) istype(A, /obj/item)

#define islist(A) istype(A, /list)

#define isliving(A) istype(A, /mob/living)

#define ismouse(A) istype(A, /mob/living/simple_animal/mouse)

#define ismovable(A) istype(A, /atom/movable)

#define isnewplayer(A) istype(A, /mob/new_player)

#define isobj(A) istype(A, /obj)

#define isghost(A) istype(A, /mob/observer/ghost)

#define isobserver(A) istype(A, /mob/observer)

#define isorgan(A) istype(A, /obj/item/organ/external)

#define isstack(A) istype(A, /obj/item/stack)

#define isspace(A) istype(A, /area/space)

#define isplanet(A) istype(A, /area/planet)

#define ispAI(A) istype(A, /mob/living/silicon/pai)

#define isrobot(A) istype(A, /mob/living/silicon/robot)

#define issilicon(A) istype(A, /mob/living/silicon)

#define isslime(A) istype(A, /mob/living/carbon/slime)

#define isunderwear(A) istype(A, /obj/item/underwear)

#define isvirtualmob(A) istype(A, /mob/observer/virtual)

#define isweakref(A) istype(A, /weakref)

#define attack_animation(A) if(istype(A)) A.do_attack_animation(src)

#define isopenspace(A) istype(A, /turf/simulated/open)

#define isWrench(A) istype(A, /obj/item/weapon/wrench)

#define isWelder(A) istype(A, /obj/item/weapon/weldingtool)

#define isCoil(A) istype(A, /obj/item/stack/cable_coil)

#define isWirecutter(A) istype(A, /obj/item/weapon/wirecutters)

#define isScrewdriver(A) istype(A, /obj/item/weapon/screwdriver)

#define isMultitool(A) istype(A, /obj/item/device/multitool)

#define isCrowbar(A) istype(A, /obj/item/weapon/crowbar)

#define sequential_id(key) uniqueness_repository.Generate(/datum/uniqueness_generator/id_sequential, key)

#define random_id(key,min_id,max_id) uniqueness_repository.Generate(/datum/uniqueness_generator/id_random, key, min_id, max_id)

#define to_chat(target, message)                            target << message
#define to_world(message)                                   to_chat(world, message)
#define to_world_log(message)                               to_chat(world.log, message)
#define sound_to(target, sound)                             target << sound
#define to_file(file_entry, source_var)                     file_entry << source_var
#define from_file(file_entry, target_var)                   file_entry >> target_var
#define show_browser(target, browser_content, browser_name) target << browse(browser_content, browser_name)
#define close_browser(target, browser_name)                 target << browse(null, browser_name)
#define show_image(target, image)                           target << image
#define send_rsc(target, rsc_content, rsc_name)             target << browse_rsc(rsc_content, rsc_name)
#define send_file(target, file)                             target << run(file)
#define open_link(target, url)                              target << link(url)

#define MAP_IMAGE_PATH "html/images/[GLOB.using_map.path]/"

#define map_image_file_name(z_level) "[GLOB.using_map.path]-[z_level].png"

#define RANDOM_BLOOD_TYPE pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

#define any2ref(x) REF(x)

#define ARGS_DEBUG log_debug("[__FILE__] - [__LINE__]") ; for(var/arg in args) { log_debug("\t[log_info_line(arg)]") }

// Helper macros to aid in optimizing lazy instantiation of lists.
// All of these are null-safe, you can use them without knowing if the list var is initialized yet

//Picks from the list, with some safeties, and returns the "default" arg if it fails
#define DEFAULT_PICK(L, default) ((istype(L, /list) && L:len) ? pick(L) : default)
// Ensures L is initailized after this point
#define LAZY_INIT(L) if (!L) L = list()
// Sets a L back to null iff it is empty
#define UNSET_EMPTY(L) if (L && !L.len) L = null
// Reads the length of L, returning 0 if null
#define LAZY_LENGTH(L) (length(L))
// Safely checks if I is in L
#define LAZY_IS_IN(L, I) (L && (I in L))
// Null-safe L.Cut()
#define LAZY_CLEAR(L) if(L) L.Cut()
// Removes I from list L, and sets I to null if it is now empty
#define LAZY_REMOVE(L, I) if(L) { L -= I; if(!L.len) { L = null; } }
// Adds I to L, initalizing L if necessary
#define LAZY_ADD(L, I) if(!L) { L = list(); } L += I;
// Insert I into L at position X, initalizing L if necessary
#define LAZY_INSERT(L, I, X) if(!L) { L = list(); } L.Insert(X, I);
// Adds I to L, initalizing L if necessary, if I is not already in L
#define LAZY_ADD_UNIQUE(L, I) if(!L) { L = list(); } L |= I;
// Sets L[A] to I, initalizing L if necessary
#define LAZY_SET(L, A, I) if(!L) { L = list(); } L[A] = I;
// Reads I from L safely - numerical lists only.
#define LAZY_ACCESS(L, I) (!!L && ((I > 0 && I <= L.len) && L[I]) || null)
// Reads K from L safely - associative lists only.
#define LAZY_ACCESS_ASSOC(L, K) ((!!LAZY_IS_IN(L, K) && L[K]) || null)
// Reads L or an empty list if L is not a list.  Note: Does NOT assign, L may be an expression.
#define SANITIZE_LIST(L) ( islist(L) ? L : list() )

// Insert an object A into a sorted list using cmp_proc (/code/_helpers/cmp.dm) for comparison.
#define ADD_SORTED(list, A, cmp_proc) if(!list.len) {list.Add(A)} else {list.Insert(FindElementIndex(A, list, cmp_proc), A)}

//Currently used in SDQL2 stuff
/proc/send_output(target, msg, control)
	target << output(msg, control)

/proc/send_link(target, url)
	open_link(target, url)

// Spawns multiple objects of the same type
#define cast_new(type, num, args...) if((num) == 1) { new type(args) } else { for(var/i=0;i<(num),i++) { new type(args) } }

#define FLAGS_EQUALS(flag, flags) ((flag & (flags)) == (flags))

#define JOINTEXT(X) jointext(X, null)

#define SPAN_NOTICE(X) "<span class='notice'>[X]</span>"

#define SPAN_WARNING(X) "<span class='warning'>[X]</span>"
