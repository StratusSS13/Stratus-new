//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/* Tools!
 * Note: Multitools are /obj/item/device
 *
 * Contains:
 * 		Wrench
 * 		Screwdriver
 * 		Wirecutters
 * 		Welding Tool
 * 		Crowbar
 *		Revolver Conversion Kit
 */

//Wrench
/obj/item/weapon/wrench
	name = "wrench"
	desc = "A wrench with common uses. Can be found in your hand."
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 5
	throwforce = 7
	w_class = 2
	materials = list(MAT_METAL=150)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")

//Screwdriver
/obj/item/weapon/screwdriver
	name = "screwdriver"
	desc = "You can be totally screwy with this."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 5
	w_class = 1
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=75)
	attack_verb = list("stabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/screwdriver/New()
	switch(pick("red","blue","purple","brown","green","cyan","yellow"))
		if("red")
			icon_state = "screwdriver2"
			item_state = "screwdriver"
		if("blue")
			icon_state = "screwdriver"
			item_state = "screwdriver_blue"
		if("purple")
			icon_state = "screwdriver3"
			item_state = "screwdriver_purple"
		if("brown")
			icon_state = "screwdriver4"
			item_state = "screwdriver_brown"
		if("green")
			icon_state = "screwdriver5"
			item_state = "screwdriver_green"
		if("cyan")
			icon_state = "screwdriver6"
			item_state = "screwdriver_cyan"
		if("yellow")
			icon_state = "screwdriver7"
			item_state = "screwdriver_yellow"

	if(prob(75))
		src.pixel_y = rand(0, 16)
	return

/obj/item/weapon/screwdriver/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M) || user.a_intent == I_HELP)
		return ..()
	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != "head")
		return ..()
	if((CLUMSY in user.mutations) && prob(50))
		M = user
	return eyestab(M,user)

//Wirecutters
/obj/item/weapon/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon = 'icons/obj/tools.dmi'
	icon_state = "cutters"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 6
	throw_speed = 3
	throw_range = 7
	w_class = 2
	materials = list(MAT_METAL=80)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("pinched", "nipped")
	hitsound = "sound/items/Wirecutter.ogg"
	sharp = 1
	edge = 1

/obj/item/weapon/wirecutters/New(loc, param_color = null)
	..()
	if((!param_color && prob(50)) || param_color == "yellow")
		icon_state = "cutters-y"
		item_state = "cutters_yellow"

/obj/item/weapon/wirecutters/attack(mob/living/carbon/human/H, mob/user)
	if(istype(H) && H.handcuffed)
		if(istype(H.handcuffed, /obj/item/weapon/restraints/handcuffs/cable))
			usr.visible_message("\The [usr] cuts \the [H]'s restraints with \the [src]!",\
			"You cut \the [H]'s restraints with \the [src]!",\
			"You hear cable being cut.")
			H.handcuffed = null
			if(H.buckled && H.buckled.buckle_requires_restraints)
				H.buckled.unbuckle_mob()
			H.update_handcuffed()
			return
	else
		..()

//Welding Tool
/obj/item/weapon/weldingtool
	name = "welding tool"
	icon = 'icons/obj/tools.dmi'
	icon_state = "welder"
	item_state = "welder"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = 2
	materials = list(MAT_METAL=70, MAT_GLASS=30)
	origin_tech = "engineering=1"
	var/welding = 0 	//Whether or not the welding tool is off(0), on(1) or currently welding(2)
	var/status = 1 		//Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower)
	var/max_fuel = 20 	//The max amount of fuel the welder can hold
	var/change_icons = 1
	var/can_off_process = 0
	var/light_intensity = 2 //how powerful the emitted light is when used.

/obj/item/weapon/weldingtool/New()
	..()
	create_reagents(max_fuel)
	reagents.add_reagent("fuel", max_fuel)
	update_icon()

/obj/item/weapon/weldingtool/examine(mob/user)
	if(..(user, 0))
		to_chat(user, "It contains [get_fuel()] unit\s of fuel out of [max_fuel].")

/obj/item/weapon/weldingtool/proc/update_torch()
	overlays.Cut()
	if(welding)
		overlays += "[initial(icon_state)]-on"
		item_state = "[initial(item_state)]1"
	else
		item_state = "[initial(item_state)]"

/obj/item/weapon/weldingtool/update_icon()
	if(change_icons)
		var/ratio = get_fuel() / max_fuel
		ratio = Ceiling(ratio*4) * 25
		if(ratio == 100)
			icon_state = initial(icon_state)
		else
			icon_state = "[initial(icon_state)][ratio]"
	update_torch()

/obj/item/weapon/weldingtool/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		flamethrower_screwdriver(I, user)
	if(istype(I, /obj/item/stack/rods))
		flamethrower_rods(I, user)
	..()

/obj/item/weapon/weldingtool/process()
	switch(welding)
		if(0)
			force = 3
			damtype = "brute"
			update_icon()
			if(!can_off_process)
				processing_objects.Remove(src)
			return
	//Welders left on now use up fuel, but lets not have them run out quite that fast
		if(1)
			force = 15
			damtype = "fire"
			if(prob(5))
				remove_fuel(1)
			update_icon()

	//This is to start fires. process() is only called if the welder is on.
	var/turf/location = loc
	if(ismob(location))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = get_turf(M)
	if(isturf(location))
		location.hotspot_expose(700, 5)

/obj/item/weapon/weldingtool/attack(mob/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.organs_by_name[user.zone_sel.selecting]
		if(!S)
			return

		if(!(S.status & ORGAN_ROBOT) || user.a_intent != I_HELP || S.open == 2)
			return ..()

		if(!isOn())		//why wasn't this being checked already?
			to_chat(user, "<span class='warning'>Turn on [src] before attempting repairs!</span>")
			return 1

		if(S.brute_dam)
			if(S.brute_dam < ROBOLIMB_SELF_REPAIR_CAP)
				if(get_fuel() >= 1)
					if(H == user)
						if(!do_mob(user, H, 10))
							return 1
					if(remove_fuel(1,null))
						playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
						S.heal_damage(15,0,0,1)
						user.visible_message("<span class='alert'>\The [user] patches some dents on \the [M]'s [S.name] with \the [src].</span>")
				else if(S.open != 2)
					to_chat(user, "<span class='warning'>Need more welding fuel!</span>")
					return 1
			else
				to_chat(user, "<span class='danger'>The damage is far too severe to patch over externally.</span>")
			return 1
		else if(S.open != 2)
			to_chat(user, "<span class='notice'>Nothing to fix!</span>")
	else
		return ..()

/obj/item/weapon/weldingtool/afterattack(atom/O, mob/user, proximity)
	if(!proximity)
		return
	if(welding)
		remove_fuel(1)
		var/turf/location = get_turf(user)
		location.hotspot_expose(700, 50, 1)

		if(isliving(O))
			var/mob/living/L = O
			if(L.IgniteMob())
				message_admins("[key_name_admin(user)] set [key_name_admin(L)] on fire")
				log_game("[key_name(user)] set [key_name(L)] on fire")

/obj/item/weapon/weldingtool/attack_self(mob/user)
	toggle(user)
	update_icon()

//Returns the amount of fuel in the welder
/obj/item/weapon/weldingtool/proc/get_fuel()
	return reagents.get_reagent_amount("fuel")

//Removes fuel from the welding tool. If a mob is passed, it will try to flash the mob's eyes. This should probably be renamed to use()
/obj/item/weapon/weldingtool/proc/remove_fuel(amount = 1, mob/living/M = null)
	if(!welding || !check_fuel())
		return 0
	if(get_fuel() >= amount)
		reagents.remove_reagent("fuel", amount)
		check_fuel()
		if(M)
			M.flash_eyes(light_intensity)
		return 1
	else
		if(M)
			to_chat(M, "\blue You need more welding fuel to complete this task.")
		return 0

//Returns whether or not the welding tool is currently on.
/obj/item/weapon/weldingtool/proc/isOn()
	return welding

//Turns off the welder if there is no more fuel (does this really need to be its own proc?)
/obj/item/weapon/weldingtool/proc/check_fuel(mob/user)
	if(get_fuel() <= 0 && welding)
		toggle(user, 1)
		update_icon()
		//mob icon update
		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_r_hand(0)
			M.update_inv_l_hand(0)

		return 0
	return 1

//Toggles the welder off and on
/obj/item/weapon/weldingtool/proc/toggle(mob/user, message = 0)
	if(!status)
		to_chat(user, "<span class='warning'>[src] can't be turned on while unsecured!</span>")
		return
	welding = !welding
	if(welding)
		if(get_fuel() >= 1)
			to_chat(user, "<span class='notice'>You switch [src] on.</span>")
			force = 15
			damtype = "fire"
			hitsound = 'sound/items/welder.ogg'
			update_icon()
			processing_objects |= src
		else
			to_chat(user, "<span class='warning'>You need more fuel!</span>")
			welding = 0
	else
		if(!message)
			to_chat(user, "<span class='notice'>You switch [src] off.</span>")
		else
			visible_message("<span class='warning'>[src] shuts off!</span>")
		force = 3
		damtype = "brute"
		hitsound = "swing_hit"
		update_icon()

/obj/item/weapon/weldingtool/proc/flamethrower_screwdriver(obj/item/I, mob/user)
	if(welding)
		to_chat(user, "<span class='warning'>Turn it off first!</span>")
		return
	status = !status
	if(status)
		to_chat(user, "<span class='notice'>You resecure [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] can now be attached and modified.</span>")
	add_fingerprint(user)

/obj/item/weapon/weldingtool/proc/flamethrower_rods(obj/item/I, mob/user)
	if(!status)
		var/obj/item/stack/rods/R = I
		if(R.use(1))
			var/obj/item/weapon/flamethrower/F = new /obj/item/weapon/flamethrower(user.loc)
			if(!remove_item_from_storage(F))
				user.unEquip(src)
				loc = F
			F.weldtool = src
			add_fingerprint(user)
			to_chat(user, "<span class='notice'>You add a rod to a welder, starting to build a flamethrower.</span>")
			user.put_in_hands(F)
		else
			to_chat(user, "<span class='warning'>You need one rod to start building a flamethrower!</span>")
			return

/obj/item/weapon/weldingtool/largetank
	name = "Industrial Welding Tool"
	desc = "A slightly larger welder with a larger tank."
	icon_state = "indwelder"
	max_fuel = 40
	materials = list(MAT_METAL=70, MAT_GLASS=60)
	origin_tech = "engineering=2"

/obj/item/weapon/weldingtool/largetank/cyborg

/obj/item/weapon/weldingtool/largetank/flamethrower_screwdriver()
	return

/obj/item/weapon/weldingtool/mini
	name = "emergency welding tool"
	desc = "A miniature welder used during emergencies."
	icon_state = "miniwelder"
	max_fuel = 10
	w_class = 1
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	change_icons = 0

/obj/item/weapon/weldingtool/mini/flamethrower_screwdriver()
	return

/obj/item/weapon/weldingtool/hugetank
	name = "Upgraded Welding Tool"
	desc = "An upgraded welder based off the industrial welder."
	icon_state = "upindwelder"
	item_state = "upindwelder"
	max_fuel = 80
	w_class = 3
	materials = list(MAT_METAL=70, MAT_GLASS=120)
	origin_tech = "engineering=3"

/obj/item/weapon/weldingtool/experimental
	name = "Experimental Welding Tool"
	desc = "An experimental welder capable of self-fuel generation and less harmful to the eyes."
	icon_state = "exwelder"
	item_state = "exwelder"
	max_fuel = 40
	w_class = 3
	materials = list(MAT_METAL=70, MAT_GLASS=120)
	origin_tech = "engineering=4;plasmatech=3"
	change_icons = 0
	can_off_process = 1
	light_intensity = 1
	var/last_gen = 0

/obj/item/weapon/weldingtool/experimental/proc/fuel_gen()
	if(!welding && !last_gen)
		last_gen = 1
		reagents.add_reagent("fuel",1)
		spawn(10)
			last_gen = 0

/obj/item/weapon/weldingtool/experimental/process()
	..()
	if(reagents.total_volume < max_fuel)
		fuel_gen()

//Crowbar
/obj/item/weapon/crowbar
	name = "pocket crowbar"
	desc = "A small crowbar. This handy tool is useful for lots of things, such as prying floor tiles or opening unpowered doors."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 5
	throwforce = 7
	item_state = "crowbar"
	w_class = 2
	materials = list(MAT_METAL=50)
	origin_tech = "engineering=1"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")

/obj/item/weapon/crowbar/red
	icon_state = "red_crowbar"
	item_state = "crowbar_red"

/obj/item/weapon/crowbar/large
	name = "crowbar"
	desc = "It's a big crowbar. It doesn't fit in your pockets, because it's big."
	force = 12
	w_class = 3
	throw_speed = 3
	throw_range = 3
	materials = list(MAT_METAL=70)
	icon_state = "crowbar_large"

/obj/item/weapon/conversion_kit
	name = "\improper Revolver Conversion Kit"
	desc = "A professional conversion kit used to convert any knock off revolver into the real deal capable of shooting lethal .357 rounds without the possibility of catastrophic failure"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "kit"
	flags = CONDUCT
	w_class = 2
	origin_tech = "combat=2"
	var/open = 0

/obj/item/weapon/conversion_kit/New()
	..()
	update_icon()

/obj/item/weapon/conversion_kit/update_icon()
	icon_state = "[initial(icon_state)]_[open]"

/obj/item/weapon/conversion_kit/attack_self(mob/user)
	open = !open
	to_chat(user, "\blue You [open?"open" : "close"] the conversion kit.")
	update_icon()
