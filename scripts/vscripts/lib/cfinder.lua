-- This component provides a memoized function for getting the C constant for Dota-style
-- pseudo-random distribution for any arbitrary target probability
-- Code based on code found here: https://gaming.stackexchange.com/questions/161430/calculating-the-constant-c-in-dota-2-pseudo-random-distribution

PrdCFinder = PrdCFinder or {}
PrdCFinder.cache = PrdCFinder.cache or {}

-- Gets the average probability of procs using a given PRD C constant
-- Mostly useful as a helper function for GetCForP
function PrdCFinder.GetPForC(c)
  local pProcByN = 0
  local expectedN = 0

  local maxN = math.ceil(1 / c)

  for n = 1, maxN do
    local pProcOnN = math.min(1, n * c) * (1 - pProcByN)
    pProcByN = pProcByN + pProcOnN
    expectedN = expectedN + pProcOnN * n
  end

  return 1 / expectedN
end

function PrdCFinder:GetCForP(p)
  if self.cache[p] then
    return self.cache[p]
  end

  local cUpper = p
  local cLower = 0
  local prevP = p

  while true do
    local cMid = (cUpper + cLower) / 2
    local currentP = self.GetPForC(cMid)

    -- Search has converged to maximum accuracy when calculated p does not change between iterations
    if currentP == prevP then
      self.cache[p] = cMid
      return cMid
    end

    if currentP > p then
      cUpper = cMid
    else
      cLower = cMid
    end

    prevP = currentP
  end
end
--[[function AOHGameMode:OnPlayerDeasth(keys)
	local time = GameRules:GetGameTime() / 60
	if keys.text == "-Snakes in eyes" and not Cheats:IsEnabled() and time > 30 and not self._physdanage and not GameRules:IsGamePaused() then
		Notifications:TopToAll({text="#dota_npc_does_ab", style={color="red"}, duration=7})
		self._physdanage = true
		self:_RenewStats()
	end
	if keys.text == "-by a Truck" and not Cheats:IsEnabled() and time > 30 and not self._physdanage and not GameRules:IsGamePaused() then
		Notifications:TopToAll({text="#dota_npc_does_bc", style={color="red"}, duration=5})
		self._physdanage = true
	end	
end]]