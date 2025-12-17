-- struct.lua --
--
-- typesafe structs
--
-- usage:
--     Point = struct {
--     	{ "x", "number" },
--     	{ "y", "number" }
--     }
--     local p1 = Point { 22, 33 }
--     assert(p1[7] == nil)
--     assert(p1.type == Point)
--    
--     Line = struct {
--     	{ "start", Point },
--     	{ "end",   Point }
--     }
--     local p2 = Point { 44, 55 }
--     local l = Line { p1, p2 }
--    
--     Email = struct { "string" }
--     local email = Email("test@example.com")
--     assert(email[1] == "test@example.com")
--    
--     assert(l.type == Line)
--
-- part of the soup files
-- https://github.com/if-not-nil/soup
---@diagnostic disable: undefined-field, cast-local-type

---@generic T
---@param fields table
---@return T
return function(fields)
	local types, index = {}, {}
	for i, field in ipairs(fields) do
		if type(field) == "table" then
			types[i] = field[2]
			index[field[1]] = i
		else
			types[i] = field
			index[field] = i
		end
	end

	local methods = {}

	-- shared for all structs
	local struct_mt = {
		__index = function(tbl, key)
			if key == "type" then return rawget(tbl, 0) end
			local i = index[key]
			if i then return tbl[i] end
			return methods[key]
		end,
		__tostring = function(tbl)
			if #tbl == 1 then return tostring(tbl[1]) end
			local parts = {}
			for k, i in pairs(index) do
				table.insert(parts, ("%s=%s"):format(k, tostring(tbl[i])))
			end
			return "{" .. table.concat(parts, ", ") .. "}"
		end,
		__eq = function(a, b)
			if #a == 1 and type(b) ~= "table" then
				return a[1] == b
			end
			return rawequal(a, b)
		end,
		__len = function() return #types end,
	}

	local struct_def = { types = types, index = index, methods = methods }

	-- dynamic methods!
	---@param menthod_name string
	---@param fn function
	function struct_def:method(menthod_name, fn)
		self.methods[menthod_name] = fn
	end

	return setmetatable(struct_def, {
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
			return setmetatable(new, struct_mt)
		end
	})
end
