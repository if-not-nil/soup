package.path = "../?.lua;" .. package.path
local println = require("fmt").println
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

	-- shared method table
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
	---@param name string|table string for method, table for trait
	---@param fn function
	function struct_def:impl(name, fn)
		if type(name) == "table" then
			for k, v in pairs(table) do
			end
			return
		end
		println(debug.getinfo(fn))
		self.methods[name] = fn
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
