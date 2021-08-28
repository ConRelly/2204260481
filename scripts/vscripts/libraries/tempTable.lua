if not tempTable then
	tempTable = {}
	tempTable.table = {}
end

function tempTable:GetEmptyKey()
	local i = 1
	while self.table[i] ~= nil do
		i = i + 1
	end
	return i
end

function tempTable:AddValue(value)
	local i = self:GetEmptyKey()
	self.table[i] = value
	return i
end

function tempTable:RetValue(key)
	local ret = self.table[key]
	self.table[key] = nil
	return ret
end

function tempTable:GetValue(key)
	return self.table[key]
end

function tempTable:Print()
	for k, v in pairs(self.table) do
		print(k, v)
	end
end

return tempTable