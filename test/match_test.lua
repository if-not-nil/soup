package.path = "../?.lua;" .. package.path
local match = require("init").match

-- simple
do
	local m = match()
		:case(1, "one")
		:case(2, "two")
		:otherwise("unknown")

	assert(m(1) == "one")
	assert(m(2) == "two")
	assert(m(42) == "unknown")
end

-- function predicate
do
	local m = match()
		:case(function(x) return x and x % 2 == 0 end, "even")
		:case(function(x) return x and x % 2 ~= 0 end, "odd")
		:otherwise("none")

	assert(m(4) == "even")
	assert(m(5) == "odd")
	assert(m(nil) == "none")
end

-- mixed primitive and function predicates
do
	local m = match()
		:case(6, "six")
		:case(7, "seven")
		:case(function(x) return type(x) == "number" and x % 2 == 0 end, "even")
		:case(function(x) return type(x) == "number" and x % 2 ~= 0 end, "odd")
		:otherwise("idk")

	assert(m(6) == "six")
	assert(m(7) == "seven")
	assert(m(8) == "even")
	assert(m(9) == "odd")
	assert(m("hello") == "idk")
end

-- edge cases
do
	-- no default
	local m = match():case(1, "one")
	assert(m(1) == "one")
	assert(m(2) == nil)

	-- only one predicate and it returns false
	local m2 = match():case(function(_) return false end, "never")
	assert(m2(42) == nil)
end

print("all match tests passed")
