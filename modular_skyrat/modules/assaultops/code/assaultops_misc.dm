//TURRETS>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/obj/machinery/porta_turret/assaultops
	use_power = IDLE_POWER_USE
	req_access = list(ACCESS_SYNDICATE)
	faction = list(ROLE_SYNDICATE)
	mode = TURRET_STUN
	max_integrity = 200
	base_icon_state = "syndie"
	stun_projectile = /obj/projectile/energy/electrode
	stun_projectile_sound = 'sound/weapons/taser.ogg'
	lethal_projectile = /obj/projectile/beam/laser/heavylaser
	lethal_projectile_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/machinery/porta_turret/assaultops/assess_perp(mob/living/carbon/human/perp)
	return 10

/obj/machinery/porta_turret/assaultops/shuttle
	scan_range = 9
	lethal_projectile = /obj/projectile/bullet/p50/penetrator/shuttle
	lethal_projectile_sound = 'modular_skyrat/modules/aesthetics/guns/sound/sniperrifle.ogg'
	stun_projectile = /obj/projectile/energy/electrode
	stun_projectile_sound = 'sound/weapons/taser.ogg'
	max_integrity = 600
	armor = list(MELEE = 50, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 80, BIO = 0, RAD = 0, FIRE = 90, ACID = 90)

/obj/machinery/porta_turret/assaultops/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES)

/obj/machinery/porta_turret/assaultops/setup(obj/item/gun/turret_gun)
	return

/obj/machinery/porta_turret/syndicate/assess_perp(mob/living/carbon/human/perp)
	return 10 //Syndicate turrets shoot everything not in their faction

//VENDING MACHINES>>>>>>>>>>>>>>>>>>>>>>>>>
/obj/machinery/vending/assaultops_ammo
	name = "\improper Syndicate Ammo Station"
	desc = "An ammo vending machine which holds a variety of different ammo mags."
	icon_state = "liberationstation"
	vend_reply = "Item dispensed."
	scan_id = FALSE
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF
	onstation = FALSE
	light_mask = "liberation-light-mask"
	default_price = 0
	var/filled = FALSE


/obj/machinery/vending/assaultops_ammo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		fill_ammo(user)
		ui = new(user, src, "Vending")
		ui.open()


/obj/machinery/vending/assaultops_ammo/proc/fill_ammo(mob/user)
	if(last_shopper == user && filled)
		return
	else
		filled = FALSE

	if(!ishuman(user))
		return FALSE

	if(!is_assault_operative(user))
		return FALSE

	//Remove all current items from the vending machine
	products.Cut()
	product_records.Cut()

	var/mob/living/carbon/human/H = user

	//Find all the ammo we should display
	for(var/i in H.contents)
		if(istype(i, /obj/item/gun/ballistic))
			var/obj/item/gun/ballistic/G = i
			if(!G.internal_magazine)
				products.Add(G.mag_type)
		if(istype(i, /obj/item/storage))
			var/obj/item/storage/S = i
			for(var/C in S.contents)
				if(istype(C, /obj/item/gun/ballistic))
					var/obj/item/gun/ballistic/G = C
					if(!G.internal_magazine)
						products.Add(G.mag_type)

	//Add our items to the list of products
	build_inventory(products, product_records, FALSE)

	filled = TRUE

/obj/machinery/vending/assaultops_ammo/build_inventory(list/productlist, list/recordlist, start_empty = FALSE)
	default_price = 0
	extra_price = 0
	for(var/typepath in productlist)
		var/amount = 4
		var/atom/temp = typepath
		var/datum/data/vending_product/R = new /datum/data/vending_product()

		GLOB.vending_products[typepath] = 1
		R.name = initial(temp.name)
		R.product_path = typepath
		if(!start_empty)
			R.amount = amount
		R.max_amount = amount
		R.custom_price = 0
		R.custom_premium_price = 0
		R.age_restricted = FALSE
		recordlist += R

