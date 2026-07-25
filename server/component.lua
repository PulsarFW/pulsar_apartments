_requests = {}
_requestors = {}

CreateThread(function()
	RegisterCallbacks()
	RegisterMiddleware()
	Startup()
end)

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["pulsar_core"]:RegisterComponent("Apartment", _APTS)
end)

_APTS = {
	Enter = function(self, source, targetType, target, wakeUp)
		local f = false
		local rTarget = target
		if rTarget == -1 then
			local char = plsr.Fetch:CharacterSource(source)
			rTarget = char:GetData("SID")
			f = true
		end

		if not f then
			if _requestors[source] ~= nil then
				for k, v in ipairs(_requests[_requestors[source]]) do
					if v.source == source then
						f = true
					end
				end
			end

			if plsr.Police:IsInBreach(source, "apartment", rTarget) then
				f = true
			end
		end

		if f then

			plsr.State:Player(source).inApartment = {
				type = targetType,
				id = rTarget
			}

			local routeId = plsr.Routing:RequestRouteId(string.format("Apartment:%s", rTarget), false)
			plsr.Pwnzor.Players:TempPosIgnore(source)
			plsr.Routing:AddPlayerToRoute(source, routeId)
			GlobalState[string.format("%s:Apartment", source)] = rTarget
			TriggerClientEvent("Apartment:Client:InnerStuff", source, targetType or 1, rTarget, wakeUp)

			local apartment = GlobalState[string.format("Apartment:%s", targetType or 1)]
			if apartment?.coords then
				plsr.State:Player(source).tpLocation = {
					x = apartment.coords.x,
					y = apartment.coords.y,
					z = apartment.coords.z,
				}
			end

			return targetType
		end

		return false
	end,
	Exit = function(self, source)
		plsr.Routing:RoutePlayerToGlobalRoute(source)
		GlobalState[string.format("%s:Apartment", source)] = nil
		plsr.Pwnzor.Players:TempPosIgnore(source)
		plsr.State:Player(source).inApartment = nil
		plsr.State:Player(source).tpLocation = nil

		return true
	end,
	GetInteriorLocation = function(self, apartment)
		local apartment = GlobalState[string.format("Apartment:%s", apartment or 1)]
		return apartment?.interior?.spawn
	end,
	Requests = {
		Get = function(self, source)
			if GlobalState[string.format("%s:Apartment", source)] ~= nil then
				return _requests[GlobalState[string.format("%s:Apartment", source)]]
			else
				return {}
			end
		end,
		Create = function(self, source, target, inZone)
			if source == target then return end

			local char = plsr.Fetch:CharacterSource(source)
			local tChar = plsr.Fetch:SID(target)

			if tChar ~= nil and string.format("apt-%s", tChar:GetData("Apartment") or 1) == inZone then
				_requests[target] = _requests[target] or {}
				for k, v in ipairs(_requests[target]) do
					if v.source == source then
						return
					end
				end

				_requestors[source] = target
				table.insert(_requests[target], {
					source = source,
					SID = char:GetData("SID"),
					First = char:GetData("First"),
					Last = char:GetData("Last"),
				})
			end
		end,
	},
}
