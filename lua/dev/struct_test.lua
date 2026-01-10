package.path = "../?.lua;" .. package.path

local river <close> = require("river")
local expect = river.expect
local expect_err = river.expect_err

local struct = require("struct")

-- struct with named fields
local Point = struct({
	{ "x", "number" },
	{ "y", "number" },
})

Point:method("magnitude", function(self)
	return math.sqrt(self.x ^ 2 + self.y ^ 2)
end)

river:test("construction and methods", function()
	local p = Point(3, 4)
	expect(p:magnitude() == 5, "magnitude should be 5 for (3,4)")
end)

river:test("table constructor and field access", function()
	local p1 = Point({ 22, 33 })

	expect(p1[1] == 22)
	expect(p1[2] == 33)
	expect(p1.x == 22)

	p1.x = 2
	expect(p1.x == 2)

	p1.x = 22
	expect(p1.x == 22)
	expect(p1.y == 33)

	expect(p1[7] == nil)
	expect(p1.type == Point)
end)

river:test("arity checking", function()
	expect_err(function()
		Point({ 1 })
	end, "expected arity error")

	expect_err(function()
		Point({ 1, 2, 3 })
	end, "expected arity error")
end)

river:test("primitive type checking", function()
	expect_err(function()
		Point({ "none", 2 })
	end, "expected type error")
end)

river:test("nested structs", function()
	local Line = struct({
		{ "start", Point },
		{ "end", Point },
	})

	local p1, p2 = Point({ 22, 33 }), Point({ 44, 55 })
	local l = Line({ p1, p2 })

	expect(l.start == p1)
	expect(l["end"] == p2)
	expect(l.type == Line)
end)

river:test("nested struct type mismatch", function()
	local Line = struct({
		{ "start", Point },
		{ "end", Point },
	})

	local p1 = Point({ 22, 33 })

	expect_err(function()
		Line({ p1, { 1, 2 } })
	end, "expected nested type mismatch")
end)

river:test("single-field struct behavior", function()
	local Email = struct({ "string" })

	local e1 = Email("test@example.com")
	local e2 = Email({ "test@example.com" })

	expect(e1[1] == "test@example.com")
	expect(e1.type == Email)
	expect(e1 ~= e2, "distinct instances should not be equal")
end)

river:test("tostring behavior", function()
	local Email = struct({ "string" })
	local e = Email("test@example.com")

	expect(tostring(e) == "test@example.com")

	local p = Point({ 22, 33 })
	local s = tostring(p)

	expect(s:match("x=22") ~= nil)
	expect(s:match("y=33") ~= nil)
end)

river:test("index safety", function()
	local p = Point({ 22, 33 })

	expect(p.z == nil)
	expect(p.foo == nil)

	expect(p.index == nil)
	expect(p.types == nil)
end)

river:test("equality semantics", function()
	local p1 = Point({ 22, 33 })
	local p2 = Point({ 22, 33 })

	expect(p1 ~= p2, "distinct structs should not be equal")
	expect(p1 == p1, "struct should equal itself")
end)

river:test("zero-field struct", function()
	local Unit = struct({})
	local u = Unit({})

	expect(u.type == Unit)
	expect(#u == 0)
end)
