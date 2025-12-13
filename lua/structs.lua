-- struct.lua
--
-- Point = struct {
-- 	{ "x", "number" },
-- 	{ "y", "number" }
-- }
--
-- Line = struct {
-- 	{ "start", Point },
-- 	{ "end",   Point }
-- }
-- Email = struct { "string" }
--
-- local p1 = Point { 22, 33 }
-- assert(p1[7] == nil)
-- assert(p1.type == Point)
-- local p2 = Point { 44, 55 }
-- local l = Line { p1, p2 }
--
-- local email = Email("test@example.com")
-- assert(email[1] == "test@example.com")
--
-- assert(l.type == Line)
return function(fields)
	local types, index = {}, {}
	for i, field in ipairs(fields) do
		if type(field) == "table" then
			local name, type = field[1], field[2]
			types[i] = type
			index[name] = i
		else
			types[i] = field
		end
	end
	return setmetatable({ types = types, index = index }, {
		__call = function(self, ...)
			local new = type(...) == "table" and ... or { ... }
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
				end,
			})
		end
	})
end

-- package.path = package.path .. ";../?.lua"
-- local fmt = require("fmt")
-- local println = fmt.println

