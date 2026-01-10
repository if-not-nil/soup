package.path = "../?.lua;" .. package.path
local struct = require("struct")
local println = require("fmt").println

local function expect_error(f, msg)
	local ok, err = pcall(f)
	assert(not ok, "expected error, got success")
	if msg then
		assert(tostring(err):match(msg), ("expected error matching %q, got %q"):format(msg, err))
	end
end

-- struct with named fields
local Point <const> = struct({
	{ "x", "number" },
	{ "y", "number" },
})

-- local Format = {
-- 	methods = {
-- 		format = {
-- 			nparams = 2, -- self, writer
-- 			isvararg = false
-- 		}
-- 	}
-- }
-- local Trait <const> = function(spec)
-- 	local t = spec.fields and {spec.fields} or {}
--
--
-- 	return {
-- 		fields, methods
-- 	}
-- end
--
-- local Format = {
-- 	{"function", nparams = 1, isvararg = false},
-- 	{"field", x = "string"}
-- }
--
--
-- local ToString = {
-- 	fields = {},
-- 	methods = {
-- 		to_string = {
-- 			isvararg = false,
-- 			nparams = 1, -- self
-- 		}
-- 	},
-- 	auto_impl = {
-- 		[Format] = function(self, writer)
-- 		end
-- 	}
-- }
--
-- local HasPosition = {
-- 	fields = { { "x", "number" }, { "y", "number" } }
-- }
--
-- local Movable = {
-- 	fields = { "x", "y" },
-- 	methods = {
-- 		move = "function"
-- 	}
-- }

Point:method("magnitude", function(self)
	return math.sqrt(self.x ^ 2 + self.y ^ 2)
end)

local p = Point(3, 4)
assert(p:magnitude() == 5)

local p1 = Point({ 22, 33 })

assert(p1[1] == 22)
assert(p1[2] == 33)
assert(p1.x == 22)
p1.x = 2
assert(p1.x == 2)
p1.x = 22
assert(p1.x == 22)
assert(p1.y == 33)
assert(p1[7] == nil)
assert(p1.type == Point)

-- wrong arity
expect_error(function()
	Point({ 1 })
end, "expected 2 fields")

expect_error(function()
	Point({ 1, 2, 3 })
end, "expected 2 fields")

-- wrong primitive type
expect_error(function()
	Point({ "nope", 2 })
end, "expected number")

-- nested structs
local Line = struct({
	{ "start", Point },
	{ "end", Point },
})

local p2 = Point({ 44, 55 })
local l = Line({ p1, p2 })

assert(l.start == p1)
assert(l["end"] == p2)
assert(l.type == Line)

-- nested type mismatch
expect_error(function()
	Line({ p1, { 1, 2 } })
end, "type mismatch")

-- single-field struct

local Email = struct({ "string" })

local e1 = Email("test@example.com")
local e2 = Email({ "test@example.com" })

assert(e1[1] == "test@example.com")
assert(e1.type == Email)
assert(e1 ~= e2)

-- tostring behavior
assert(tostring(e1) == "test@example.com")
assert(not (tostring(e1) == "other@example.com"))

local s = tostring(p1)
assert(s:match("x=22"))
assert(s:match("y=33"))

-- index lookup only exposes declared fields
assert(p1.z == nil)
assert(p1.foo == nil)

-- ensure index table doesn't leak
assert(p1.index == nil)
assert(p1.types == nil)

-- equality for multi-field structs is strict identity
local p1_clone = Point({ 22, 33 })
assert(p1 ~= p1_clone)
assert(p1 == p1)

-- zero-field struct
local Unit = struct({})
local u = Unit({})
assert(u.type == Unit)
assert(#u == 0)

print("all struct tests passed")
