-- struct.lua
--
-- Point = struct {
-- 	{ "x", "number" },
-- 	{ "y", "number" }
-- }
-- local p1 = Point { 22, 33 }
-- assert(p1[7] == nil)
-- assert(p1.type == Point)
--
-- Line = struct {
-- 	{ "start", Point },
-- 	{ "end",   Point }
-- }
-- local p2 = Point { 44, 55 }
-- local l = Line { p1, p2 }
--
-- Email = struct { "string" }
-- local email = Email("test@example.com")
-- assert(email[1] == "test@example.com")
--
-- assert(l.type == Line)
return function(fields)
	local types, index = {}, {}
	for i, field in ipairs(fields) do
		if type(field) == "table" then
			types[i] = field[2]
			index[field[1]] = i
		else
			types[i] = field
		end
	end

	return setmetatable({ types = types, index = index }, {
		__call = function(self, ...)
			local new = type(...) == "table" and ... or { ... }
			assert(#new == #self.types, ("expected %d fields, got %d"):format(#self.types, #new))

			for i, v in ipairs(new) do
				local t = self.types[i]
				if type(t) == "string" then
					assert(type(v) == t, ("field %d: expected %s, got %s"):format(i, t, type(v)))
				else
					assert(v[0] == t, ("field %d: type mismatch"):format(i))
				end
			end

			new[0] = self
			return setmetatable(new, {
				__newindex = function() error("struct is immutable") end,
				__index = function(tbl, key)
					if key == "type" then return tbl[0] end
					return self.index[key] and tbl[self.index[key]]
				end,
				__eq = function(a, b)
					if #a == 1 and type(b) ~= "table" then
						return a[1] == b
					end
					return rawequal(a, b)
				end,
				__tostring = function(tbl)
					-- makes sense
					if #tbl == 1 then
						return tostring(tbl[1])
					end
					local parts = {}
					for name, i in pairs(self.index) do
						table.insert(parts, ("%s=%s"):format(name, tostring(tbl[i])))
					end
					return "{" .. table.concat(parts, ", ") .. "}"
				end
			})
		end
	})
end
