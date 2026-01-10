-- struct.lua --
-- part of the soup files
-- https://github.com/if-not-nil/soup
--
-- typesafe structs
--

---@diagnostic disable: undefined-field, cast-local-type

---@class StructField
---@field [1] string field name
---@field [2] string|table field type (as in type() or another struct)

---@class StructInput
---@field [number] StructField|string
---@field meta? table<string, function|any>

---@generic T
---@param fields StructInput
---@return T
return function(fields)
	local types, index = {}, {}
	local methods = {}
	local temp_mt = {}
	local traits = {}

	for i, field in pairs(fields) do
		if i == "impl" then
			traits = field
		elseif type(field) == "table" then
			types[i] = field[2]
			index[field[1]] = i
		elseif type(field) == "function" and type(i) == "string" then
			if i:sub(1, 2) == "__" then
				temp_mt[i] = field -- metamethods
			else
				methods[i] = field -- normal methods
			end
		else
			types[i] = field
			index[field] = i
		end
	end

	-- shared for all structs
	local struct_mt = {
		__index = function(tbl, key)
			if key == "type" then
				return rawget(tbl, 0)
			end
			local i = index[key]
			if i then
				return tbl[i]
			end
			return methods[key]
		end,
		__newindex = function(tbl, key, value)
			local i = index[key]
			if i then
				local t = types[i]
				if type(t) == "string" then
					assert(type(value) == t, ("field %s: expected %s, got %s"):format(key, t, type(value)))
				end
				rawset(tbl, i, value)
			else
				rawset(tbl, key, value)
			end
		end,
		__tostring = function(tbl)
			if #tbl == 1 then
				return tostring(tbl[1])
			end
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
		__len = function()
			return #types
		end,
		table.unpack(temp_mt),
	}

	local struct_def = { types = types, index = index, methods = methods, traits = traits }

	-- dynamic methods!
	---@param menthod_name string
	---@param fn function
	function struct_def:method(menthod_name, fn)
		self.methods[menthod_name] = fn
	end

	-- check impl
	if fields.impl then
		for trait, implementation in pairs(fields.impl) do
			for name, fn in pairs(implementation) do
				methods[name] = fn
			end

			for name, default_fn in pairs(trait) do
				if type(default_fn) == "function" then
					methods[name] = methods[name] or default_fn
				end
			end
		end
	end

	function struct_def:does_implement(trait)
		if self.traits[trait] == nil then
			return false
		end

		for k, v in pairs(trait) do
			if self.traits[trait][k] == nil then
				return false
			end
			if type(k) == "string" and type(v) == "function" then
				local ref = self.methods[k]
				if type(ref) ~= "function" then
					return false
				end

				local s_info = debug.getinfo(ref)
				local t_info = debug.getinfo(v)

				for _, field in ipairs({ "nparams", "isvararg" }) do
					if s_info[field] ~= t_info[field] then
						return false
					end
				end
			end
		end
		return true
	end

	---@type any
	local f = setmetatable(struct_def, {
		---@param self table
		---@param ... any
		---@return T
		__call = function(self, ...)
			local args = { ... }
			local new = (type(args[1]) == "table" and #args == 1) and args[1] or args
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
		end,
	})
	return f
end
