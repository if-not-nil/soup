local soup = require("soup")
local Lisp = soup.misc.lisp
local lib = Lisp.lib

Lisp { lib.print, "match statements!" }
require("io")
---
--- match statements
---
local m = soup.match()
	:case(6, "six")
	:case(7, "seveen")
	:case(function(x) return x % 2 == 0 end, "even")
	:case(function(x) return x % 2 ~= 0 end, "odd")
	:otherwise("idk")

soup.println({
	["6"] = m(6),
	["7"] = m(7),
	["9"] = m(9),
	["17"] = m(10),
})
-- or as lisp for no reason
Lisp { lib.print, { m, 6 } }

---
--- lisp
---
Lisp {
	{ print, "hello ", "world\n",
		{ lib.add, { lib.add, 59, 1 }, 7 }, "\n" },
	{ soup.println, { a = "yo" } },
	{ print, "matched and got ", { lib.match,
		{ tonumber, { lib.input, "yo\n> " } },
		{ 6,        "six" },
		{ 7,        "seven" },
		{ 67,       "six seveeen" },
		":(" -- default case
	}, "\n" }
};
---
--- monads
---
local monad = soup.monad
local Ok = soup.Ok
local Err = soup.Err

local get_first_line = monad():and_then(function(filename)
	local file, err = io.open(filename, "r")
	if err then return Err(err) end

	return Ok(file)
end):and_then(function(file)
	local line = file:read("l")
	return line -- converted to Ok() implicitly
end):and_then(function(line)
	local without_spaces = string.gsub(line, "%s+", "")
	return Ok(without_spaces)
end):unwrap(function(err)
	print(err)
	soup.printf("error caught: %s", err)
	return Err(err)
end)

soup.println("got a line: ", get_first_line("soup.lua"))
