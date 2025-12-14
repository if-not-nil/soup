package.path = "../?.lua;" .. package.path
local struct = require("dev.struct")

local Traits = {
	printable = {
		tostring = function(self)
			local parts = {}
			for k, v in pairs(self.type.index) do
				table.insert(parts, k .. "=" .. tostring(self[v]))
			end
			return "{" .. table.concat(parts, ", ") .. "}"
		end
	},
	comparable = {
		equals = function(self, other)
			for k, i in pairs(self.type.index) do
				if self[i] ~= other[i] then return false end
			end
			return true
		end
	}
}
