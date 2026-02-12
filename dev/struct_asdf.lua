package.path = "../?.lua;" .. package.path
local struct = require("struct")
local fmt = require("fmt")

local Traits = {
	mul = {
		-- ???
	},
	printable = {
		tostring = function(self)
			local parts = {}
			for k, v in pairs(self.type.index) do
				table.insert(parts, k .. "=" .. tostring(self[v]))
			end
			return "{" .. table.concat(parts, ", ") .. "}"
		end,
	},
	comparable = {
		equals = function(self, other)
			for k, i in pairs(self.type.index) do
				if self[i] ~= other[i] then
					return false
				end
			end
			return true
		end,
	},
	zero = {
		zero = function() end,
	},
}

---@class vec2
---@field x number
---@field y number
---@field mag fun(self: vec2): number
---@field normalize fun(self: vec2): vec2
---@field dot fun(self: vec2, other: vec2): number
---@field unpack fun(self: vec2): number, number

---@type fun(x?: number, y?: number): vec2
Vec2 = struct({
	{ "x", "number" },
	{ "y", "number" },
	impl = {
		[Traits.zero] = {
			zero = function()
				return Vec2(0, 0)
			end,
		},
		[Traits.mul] = {
			__mul = function(self, other)
				-- ???
			end,
		},
	},
	__add = function(a, b)
		return Vec2(a.x + b.x, a.y + b.y)
	end,

	__sub = function(a, b)
		return Vec2(a.x - b.x, a.y - b.y)
	end,

	mag = function(self)
		return math.sqrt(self.x ^ 2 + self.y ^ 2)
	end,

	normalize = function(self)
		local m = self:mag()
		return m > 0 and self * (1 / m) or Vec2(0, 0)
	end,

	dot = function(self, other)
		return self.x * other.x + self.y * other.y
	end,

	unpack = function(self)
		return self.x, self.y
	end,

	equals = function(self, a)
		return true
	end,
})

---@diagnostic disable-next-line: undefined-field
print(Vec2:does_implement(Traits.zero))
print(Vec2(2, 2) * 2)
