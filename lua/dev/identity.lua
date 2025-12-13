package.path = package.path .. ";../?.lua"
local fmt = require("fmt")
local println = fmt.println

do
	-- structs
	-- this implementation is wayy to noisy when printing
	local function struct(fields)
		local names, types, index = {}, {}, {}
		for k, v in pairs(fields) do
			index[k] = #types + 1
			names[#names + 1], types[#types + 1] = k, v
		end

		return setmetatable({ types = types, index = index }, {
			__call = function(self, new)
				assert(#new == #self.types)
				for i = 1, #new do
					local t = self.types[i]
					local v = new[i]

					if type(t) == "string" then
						assert(type(v) == t, ("expected type %s at position %d, got %s"):format(t, i, type(v)))
					else
						-- js assume its a struct and check identity via [0]
						assert(v[0] == t, ("expected struct at position %d"):format(i))
					end
				end

				-- identity lives at index 0
				new[0] = self
				-- this just hijacks indexing lmao
				return setmetatable(new, {
					__index = self.index
				})
			end
		})
	end

	Point = struct { x = "number", y = "number" }
	local p1 = Point { 11, 22 }
	local p2 = Point { 33, 44 }

	println(p1)
	Line = struct { ["start"] = Point, ["end"] = Point }
	local l = Line { p1, p2 }

	assert(l[0] == Line)
	println("p1: ", p1[p1.x], ", ", p1[p1.y])
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
