package.path = package.path .. ";../?.lua"
local fmt = require("fmt")
local println = fmt.println

do
	-- structs
	-- this implementation is wayy to noisy when printing
	local function struct(fields)
		local names, types, index = {}, {}, {}
		for k in pairs(fields) do
			table.insert(names, k)
		end
		table.sort(names) -- alphabetical
		for i, name in ipairs(names) do
			types[i] = fields[name]
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
					__index = function(tbl, key) return key and tbl[self.index[key]] end
				})
			end
		})
	end

	Point = struct { x = "number", y = "number" }
	local p1 = Point { 11, 22 }
	println("p1: x", p1.x, ", y", p1.y)
	println("p1: ", p1)

	-- local p2 = Point { 33, 44 }
	-- println(p1)
	-- Line = struct {
	-- 	["start"] = Point,
	-- 	["end"] = Point
	-- }
	-- local l = Line {
	-- 	Point { 11, 22 },
	-- 	Point { 33, 44 }
	-- }

	-- assert(l[0] == Line)
end
-- local println = fmt.println
-- -- tag identity
-- do
-- 	local Line = {}
-- 	local Point = {}
--
-- 	local l1 = { Line, 1, 1, 2, 2 }
-- 	local p1 = { Point, 1, 2 }
--
-- 	-- check tag identity and uniqueness
-- 	assert(l1[1] == Line)
-- 	assert(l1[1] ~= Point)
-- 	coroutine.resume(coroutine.create(function()
-- 		assert(l1[1] == Line)
-- 		assert(l1[1] ~= Point)
-- 	end))
-- end

-- tag and structure identity
-- do
-- 	for _ = 1, 2 do
-- 		print({})
-- 	end
-- 	local Line = { "number", "number", "number", "number" }
-- 	setmetatable(Line, {
-- 		__call = function(self, ...)
-- 			do -- asserts
-- 				local a = table.pack(...)
-- 				if #a ~= #self then error("length doesnt match") end
-- 				for i, v in ipairs(a) do assert(type(v) == self[i]) end
-- 			end
--
-- 			return { self, ... }
-- 		end
-- 	})
-- 	local line = Line(1, 2, 3, 4)
-- 	-- println(line)
-- 	local Point = { "number", "number" }
--
-- 	-- stored are only references
-- 	local l1 = { Line, 1, 1, 2, 2 }
-- 	local p1 = { Point, 1, 2 }
--
-- 	-- check tag identity and uniqueness
-- 	assert(l1[1] == Line)
-- 	assert(l1[1] ~= Point)
-- 	coroutine.resume(coroutine.create(function()
-- 		assert(l1[1] == Line)
-- 		assert(l1[1] ~= Point)
-- 	end))
-- end
