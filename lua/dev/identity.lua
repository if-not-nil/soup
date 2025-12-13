package.path = package.path .. ";../?.lua"
local fmt = require("fmt")
local println = fmt.println

-- structs
-- this implementation is wayy to noisy when printing
local function struct(fields)
	local types, index = {}, {}

	for i, field in ipairs(fields) do
		local name, type = field[1], field[2]
		types[i] = type
		index[name] = i
	end

	return setmetatable({ types = types, index = index }, {
		__call = function(self, new)
			assert(#new == #self.types, "field count mismatch")
			for i, v in ipairs(new) do
				local t = self.types[i]
				if type(t) == "string" then
					assert(type(v) == t, ("expected %s at %d, got %s"):format(t, i, type(v)))
				else
					assert(v[0] == t, ("expected struct at %d"):format(i))
				end
			end
			new[0] = self
			return setmetatable(new, {
				__newindex = function() error("struct is immutable") end,
				__index = function(tbl, key)
					if key == "type" then return tbl[0] end
					return key and tbl[self.index[key]]
				end
			})
		end
	})
end

Point = struct {
	{ "x", "number" },
	{ "y", "number" }
}

Line = struct {
	{ "start", Point },
	{ "end",   Point }
}

local p1 = Point { 22, 33 }
local p2 = Point { 44, 55 }
local l = Line { p1, p2 }

assert(l.type == Line)
