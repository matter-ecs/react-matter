local function diffTables(left: { [unknown]: unknown }?, right: { [unknown]: unknown }?): boolean
	if left and right then
		if left == right then
			return false
		end

		local size = 0

		for key, value in left do
			if value ~= right[key] then
				return true
			end
			size += 1
		end

		for _ in right do
			size -= 1
		end

		if size ~= 0 then
			return true
		end

		return false
	end

	return true
end

return diffTables
