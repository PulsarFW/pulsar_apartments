local _pzs = {}
local _inPoly = false
local _menu = false

CreateThread(function()
	for k, v in ipairs(GlobalState["Apartments"]) do
		local aptId = string.format("apt-%s", v)
		local apt = GlobalState[string.format("Apartment:%s", v)]

		plsr.Polyzone.Create:Box(aptId, apt.coords, apt.length, apt.width, apt.options, {
			tier = k
		})

		plsr.Blips:Add(aptId, apt.name, apt.coords, 475, 25)
		_pzs[aptId] = {
			name = apt.name,
			id = apt.id,
		}
	end

	plsr.Interaction:RegisterMenu("apt-exit", "Exit Apartment", "door-open", function(data)
		plsr.Interaction:Hide()
		plsr.Apartment:Exit()
	end, function()
		if
			not plsr.State.flags.isDead
			and GlobalState[string.format("%s:Apartment", plsr.State.flags.ID)] ~= nil
		then
			local p = GlobalState[string.format(
				"Apartment:%s",
				plsr.State.flags.inApartment.type
			)]

			local dist = #(
					vector3(plsr.State.flags.position.x, plsr.State.flags.position.y, plsr.State.flags.position.z)
					- vector3(p.interior.spawn.x, p.interior.spawn.y, p.interior.spawn.z)
				)
			return dist <= 2.0
		else
			return false
		end
	end)

	-- Interaction:RegisterMenu("apt-visitors", "Check Visitors", "hand-back-fist", function(data)
	-- 	Interaction:Hide()
	-- 	CheckVisitors()
	-- end, function()
	-- 	if GlobalState[string.format("%s:Apartment", plsr.State.flags.ID)] ~= nil then
	-- 		local p = GlobalState[string.format(
	-- 			"Apartment:%s",
	-- 			GlobalState[string.format(
	-- 				"Apartment:Interior:%s",
	-- 				GlobalState[string.format("%s:Apartment", plsr.State.flags.ID)]
	-- 			)]
	-- 		)]
	-- 		local dist = #(
	-- 				vector3(plsr.State.flags.position.x, plsr.State.flags.position.y, plsr.State.flags.position.z)
	-- 				- vector3(p.interior.spawn.x, p.interior.spawn.y, p.interior.spawn.z)
	-- 			)
	-- 		return dist <= 2.0
	-- 	else
	-- 		return false
	-- 	end
	-- end)
end)


AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["pulsar_core"]:RegisterComponent("Apartment", _APTS)
end)

RegisterNetEvent("Characters:Client:Spawn", function()
	for k, v in ipairs(GlobalState["Apartments"]) do
		local aptId = string.format("apt-%s", v)
		local apt = GlobalState[string.format("Apartment:%s", v)]

		plsr.Blips:Add(aptId, apt.name, apt.coords, 475, 25)
	end
end)

-- function CheckVisitors()
-- 	Callbacks:ServerCallback("Apartment:GetRequests", {}, function(requets)
-- 		if #reqeusts > 0 then
-- 			local menu = {
-- 				label = _pzs[_inPoly].name,
-- 			}
-- 			local its = {}

-- 			for k, v in ipairs(requests) do
-- 				table.insert(its, {
-- 					label = string.format("%s %s", v.First, v.Last),
-- 					description = "Requesting To Enter Apartment",
-- 					data = _inPoly,
-- 				})
-- 				menu[string.format("request-%s", v.SID)] = {
-- 					label = string.format("Allow %s %s?", v.First, v.Last),
-- 					items = {
-- 						{
-- 							label = "Yes",
-- 							description = "Allow Them To Enter",
-- 							event = "Apartment:Client:Enter",
-- 							data = _inPoly,
-- 						},
-- 						{
-- 							label = "Breach Apartment",
-- 							description = "Breach An Apartment",
-- 							event = "Apartment:Client:Enter",
-- 							data = _inPoly,
-- 						},
-- 					},
-- 				}
-- 			end

-- 			menu.items = menu

-- 			ListMenu:Show(menu)
-- 		else
-- 			Notification:Error("You Have No Requesting Visitors")
-- 		end
-- 	end)
-- end

RegisterNetEvent("Apartment:Client:InnerStuff", function(aptId, unit, wakeUp)
	while GlobalState[string.format("%s:Apartment", plsr.State.flags.ID)] == nil do
		Wait(10)
		print("Interior Stuff Waiting, This Shouldn't Spam")
	end

	local p = GlobalState[string.format("Apartment:%s", aptId)]
	TriggerEvent("Interiors:Enter", vector3(p.interior.spawn.x, p.interior.spawn.y, p.interior.spawn.z))

	if wakeUp then
		Citizen.SetTimeout(250, function()
			plsr.Animations.Emotes:WakeUp(p.interior.wakeup)
		end)
	end

	plsr.Targeting.Zones:AddBox(
		string.format("apt-%s-exit", aptId),
		"door-open",
		p.interior.locations.exit.coords,
		p.interior.locations.exit.length,
		p.interior.locations.exit.width,
		p.interior.locations.exit.options,
		{
			{
				icon = "door-open",
				text = "Exit",
				event = "Apartment:Client:ExitEvent",
				data = unit,
			},
		},
		3.0,
		true
	)

	plsr.Targeting.Zones:AddBox(
		string.format("apt-%s-logout", aptId),
		"bed",
		p.interior.locations.logout.coords,
		p.interior.locations.logout.length,
		p.interior.locations.logout.width,
		p.interior.locations.logout.options,
		{
			{
				icon = "bed",
				text = "Switch Characters",
				event = "Apartment:Client:Logout",
				data = unit,
				isEnabled = function(data)
					return unit == plsr.State.character.SID
				end,
			},
		},
		3.0,
		true
	)

	plsr.Targeting.Zones:AddBox(
		string.format("apt-%s-wardrobe", propertyId),
		"shirt",
		p.interior.locations.wardrobe.coords,
		p.interior.locations.wardrobe.length,
		p.interior.locations.wardrobe.width,
		p.interior.locations.wardrobe.options,
		{
			{
				icon = "bars-staggered",
				text = "Wardrobe",
				event = "Apartment:Client:Wardrobe",
				data = unit,
				isEnabled = function(data)
					return unit == plsr.State.character.SID
				end,
			},
		},
		3.0,
		true
	)

	plsr.Targeting.Zones:AddBox(
		string.format("property-%s-stash", propertyId),
		"toolbox",
		p.interior.locations.stash.coords,
		p.interior.locations.stash.length,
		p.interior.locations.stash.width,
		p.interior.locations.stash.options,
		{
			{
				icon = "toolbox",
				text = "Stash",
				event = "Apartment:Client:Stash",
				data = propertyId,
			},
		},
		2.0,
		true
	)

	plsr.Targeting.Zones:Refresh()
	Wait(1000)
	plsr.Sync:Stop(1)
end)

AddEventHandler("Apartment:Client:ExitEvent", function()
	plsr.Apartment:Exit()
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
	if _pzs[id] and string.format("apt-%s", plsr.State.character.Apartment or 1) == id then
		_inPoly = {
			id = id,
			data = data.tier
		}

		-- local str = "{keybind}secondary_action{/keybind} View Options"
		-- if string.format("apt-%s", plsr.State.character.Apartment or 1) == id then
		-- 	str = string.format("{keybind}primary_action{/keybind}: Enter {keybind}secondary_action{/keybind}: Other", _pzs[id].name)
		-- end

		local str = string.format("{keybind}primary_action{/keybind} To Enter %s", _pzs[id].name)

		plsr.Action:Show('apt-enter', str)
	end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if id == _inPoly?.id then
		_inPoly = nil
		plsr.Action:Hide('apt-enter')
	end
end)

AddEventHandler("Keybinds:Client:KeyUp:primary_action", function()
	if
		_inPoly
		and (plsr.State.character.Apartment or 1) == _inPoly.data
		and not plsr.State.flags.isDead and GetVehiclePedIsIn(PlayerPedId()) == 0
	then
		plsr.Apartment:Enter(_inPoly.data, -1)
	end
end)

AddEventHandler("Apartment:Client:Enter", function(data)
	plsr.Apartment:Enter(data)
end)

AddEventHandler("Apartment:Client:RequestEntry", function(data)
	plsr.Input:Show("Request Entry", "Unit Number (Owner State ID)", {
		{
			id = "unit",
			type = "number",
			options = {
				inputProps = {
					maxLength = 4,
				},
			},
		},
	}, "Apartment:Client:DoRequestEntry", _inPoly)
end)

AddEventHandler("Apartment:Client:DoRequestEntry", function(values, data)
	plsr.Callbacks:ServerCallback("Apartment:RequestEntry", {
		inZone = data,
		target = values.unit,
	})
end)

AddEventHandler("Apartment:Client:Stash", function(t, data)
	plsr.Apartment.Extras:Stash()
end)

AddEventHandler("Apartment:Client:Wardrobe", function(t, data)
	plsr.Apartment.Extras:Wardrobe()
end)

AddEventHandler("Apartment:Client:Logout", function(t, data)
	plsr.Apartment.Extras:Logout()
end)

_APTS = {
	Enter = function(self, tier, id)
		plsr.Callbacks:ServerCallback("Apartment:Enter", {
			id = id or -1,
			tier = tier,
		}, function(s)
			if s then
				plsr.Sounds.Play:One("door_open.ogg", 0.15)

				DoScreenFadeOut(1000)
				while not IsScreenFadedOut() do
					Wait(10)
				end

				local p = GlobalState[string.format("Apartment:%s", s)]

				FreezeEntityPosition(PlayerPedId(), true)
				Wait(50)
				SetEntityCoords(
					PlayerPedId(),
					p.interior.spawn.x,
					p.interior.spawn.y,
					p.interior.spawn.z,
					0,
					0,
					0,
					false
				)
				Wait(100)
				SetEntityHeading(PlayerPedId(), p.interior.spawn.h)

				local time = GetGameTimer()
				while (not HasCollisionLoadedAroundEntity(PlayerPedId()) and (GetGameTimer() - time) < 10000) do
					Wait(100)
				end

				FreezeEntityPosition(PlayerPedId(), false)

				DoScreenFadeIn(1000)
				while not IsScreenFadedIn() do
					Wait(10)
				end
			end
		end)
	end,
	Exit = function(self)
		local apartmentId = GlobalState[string.format("%s:Apartment", plsr.State.flags.ID)]
		local p = GlobalState[string.format(
			"Apartment:%s",
			plsr.State.flags.inApartment.type
		)]

		plsr.Callbacks:ServerCallback("Apartment:Exit", {}, function()
			DoScreenFadeOut(1000)
			while not IsScreenFadedOut() do
				Wait(10)
			end

			TriggerEvent("Interiors:Exit")
			plsr.Sync:Start()

			plsr.Sounds.Play:One("door_close.ogg", 0.3)
			Wait(200)

			SetEntityCoords(PlayerPedId(), p.coords.x, p.coords.y, p.coords.z, 0, 0, 0, false)
			Wait(100)
			SetEntityHeading(PlayerPedId(), p.heading)

			for k, v in pairs(p.interior.locations) do
				plsr.Targeting.Zones:RemoveZone(string.format("apt-%s-%s", k, apartmentId))
			end

			plsr.Targeting.Zones:Refresh()

			DoScreenFadeIn(1000)
			while not IsScreenFadedIn() do
				Wait(10)
			end
		end)
	end,
	GetNearApartment = function(self)
		if _inPoly?.id ~= nil and _pzs[_inPoly?.id]?.id ~= nil then
			return GlobalState[string.format("Apartment:%s", _pzs[_inPoly?.id].id)]
		else
			return nil
		end
	end,
	Extras = {
		Stash = function(self)
			plsr.Callbacks:ServerCallback("Apartment:Validate", {
				id = GlobalState[string.format("%s:Apartment", plsr.State.flags.ID)],
				type = "stash",
			})
		end,
		Wardrobe = function(self)
			plsr.Callbacks:ServerCallback("Apartment:Validate", {
				id = GlobalState[string.format("%s:Apartment", plsr.State.flags.ID)],
				type = "wardrobe",
			}, function(state)
				if state then
					plsr.Wardrobe:Show()
				end
			end)
		end,
		Logout = function(self)
			plsr.Callbacks:ServerCallback("Apartment:Validate", {
				id = GlobalState[string.format("%s:Apartment", plsr.State.flags.ID)],
				type = "logout",
			}, function(state)
				if state then
					plsr.Characters:Logout()
				end
			end)
		end,
	},
}
