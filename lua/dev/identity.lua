package.path = package.path .. ";../?.lua"
local fmt = require("fmt")
local println = fmt.println
do -- structs
	local struct = function(fields)
		local t = fields
		setmetatable(t, {
			__call = function(self, a)
				println(a, self, #a, #self)
				if #a ~= #self then error("length doesnt match") end
				for i, v in ipairs(a) do assert(type(v) == self[i]) end
				return { self, table.unpack(a) }
			end,
		})
		return t
	end
	Line = struct {
		x1 = "number", y1 = "number",
		x2 = "number", y2 = "number"
	}
	Line { 1, 5, 3, 1 }
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
