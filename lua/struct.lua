-- struct.lua --
-- part of the soup files
-- https://github.com/if-not-nil/soup
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
--  advanced usage:
--     ---@class vec2
--     ---@field x number
--     ---@field y number
--     ---@field mag fun(self: vec2): number
--     ---@field normalize fun(self: vec2): vec2
--     ---@field dot fun(self: vec2, other: vec2): number
--     ---@field unpack fun(self: vec2): number, number
--
--     ---@type fun(x?: number, y?: number): vec2
--     Vec2 = struct({
--     	{ "x", "number" },
--     	{ "y", "number" },
--     		__add = function(a, b)
--     			return Vec2(a.x + b.x, a.y + b.y)
--     		end,
--
--     		__sub = function(a, b)
--     			return Vec2(a.x - b.x, a.y - b.y)
--     		end,
--
--     		__mul = function(a, b)
--     			if type(b) == "number" then
--     				return Vec2(a.x * b, a.y * b)
--     			end
--     			return Vec2(a.x * b.x, a.y * b.y)
--     		end,
--
--     		mag = function(self)
--     			return math.sqrt(self.x ^ 2 + self.y ^ 2)
--     		end,
--
--     		normalize = function(self)
--     			local m = self:mag()
--     			return m > 0 and self * (1 / m) or Vec2(0, 0)
--     		end,
--
--     		dot = function(self, other)
--     			return self.x * other.x + self.y * other.y
--     		end,
--
--     		unpack = function(self)
--     			return self.x, self.y
--     		end,
--     })

---@diagnostic disable: undefined-field, cast-local-type

---@class StructField
---@field [1] string field name
---@field [2] string|table field type (as in type() or another struct)

---@class StructInput
---@field [number] StructField|string
---@field meta? table<string, function|any>

---@generic T
---@param fields StructInput
---@return T | fun(...): T
return function(fields)
	local types, index = {}, {}
	local methods = {}
	local temp_mt = {}

	for i, field in pairs(fields) do
		if type(field) == "table" then
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

	local struct_def = { types = types, index = index, methods = methods }

	-- dynamic methods!
	---@param menthod_name string
	---@param fn function
	function struct_def:method(menthod_name, fn)
		self.methods[menthod_name] = fn
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
