function RegisterCallbacks()
	plsr.Callbacks:RegisterServerCallback("Apartment:Validate", function(source, data, cb)
		local char = plsr.Fetch:CharacterSource(source)

		local isMyApartment = data.id == GlobalState[string.format("%s:Apartment", source)]

		if data.id then
			if data.type == "wardrobe" and isMyApartment then
				cb(char:GetData("SID") == GlobalState[string.format("%s:Apartment", source)])
			elseif data.type == "logout" and isMyApartment then
				cb(char:GetData("SID") == GlobalState[string.format("%s:Apartment", source)])
			elseif data.type == "stash" and isMyApartment or plsr.Police:IsInBreach(source, "apartment", data.id, true) then
				local invType = _aptData[char:GetData("Apartment") or 1].invEntity or 13
				local isRaid = false
				local invOwner = char:GetData("SID")

				if plsr.Police:IsInBreach(source, "apartment", data.id, true) then
					invOwner = plsr.State:Player(source).inApartment.id
					isRaid = true
				elseif plsr.State:Player(source).inApartment ~= nil and plsr.State:Player(source).inApartment.id ~= char:GetData("SID") then
					return cb(false)
				end

				plsr.Callbacks:ClientCallback(source, "Inventory:Compartment:Open", {
					invType = invType,
					owner = invOwner,
				}, function()
					plsr.Inventory:OpenSecondary(source, invType, invOwner, false, false, isRaid)
				end)

				cb(true)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	plsr.Callbacks:RegisterServerCallback("Apartment:SpawnInside", function(source, data, cb)
		local char = plsr.Fetch:CharacterSource(source)
		cb(plsr.Apartment:Enter(source, char:GetData("Apartment"), -1, true))
	end)

	plsr.Callbacks:RegisterServerCallback("Apartment:Enter", function(source, data, cb)
		cb(plsr.Apartment:Enter(source, data.tier, data.id))
	end)

	plsr.Callbacks:RegisterServerCallback("Apartment:Exit", function(source, data, cb)
		cb(plsr.Apartment:Exit(source))
	end)

	plsr.Callbacks:RegisterServerCallback("Apartment:GetVisitRequests", function(source, data, cb)
		cb(plsr.Apartment.Reqeusts:Get(source))
	end)

	plsr.Callbacks:RegisterServerCallback("Apartment:Visit", function(source, data, cb)
		cb(plsr.Apartment:Enter(source, data.tier, data.id))
	end)
end
