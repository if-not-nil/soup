local soup = require("soup")

-- Lisp { lib.print, "match statements!" }
-- require("io")
---
--- match statements
---
local std = soup.misc.writers
local cout = soup.misc.writers.cout()

local m = soup.match()
	:case(6,
		cout >> "six" >> std.endl)
	:case(7,
		cout >> "seveen" >> std.endl)
	:case(function(x) return x % 2 == 0 end,
		cout >> "even" >> cout.endl)
	:case(function(x) return x % 2 ~= 0 end,
		cout >> "odd" >> cout.endl)
	:otherwise("idk")

m(std.cin << "> ")
-- soup.println({
-- 	["6"] = m(6),
-- 	["7"] = m(7),
-- 	["9"] = m(9),
-- 	["17"] = m(10),
-- })
-- or as lisp for no reason

---
--- lisp
---
local Lisp = soup.misc.lisp
local lib = Lisp.lib
Lisp { print, { lib.mul, 6, 10 } }
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
--- result type
---
local Result = soup.result
local result <const> =
	Result.Ok("test.txt")

	:bind(function(filename)
		local file, err = io.open(filename, "r")
		if not file then
			return Result.Err(err)
		end
		return Result.Ok(file)
	end)

	-- bind again
	:bind(function(file)
		local line = file:read("l")
		if not line then
			return Result.Err("file is empty")
		end
		return Result.Ok(line)
	end)

	-- apply transform only if Ok
	:map(function(s)
		return s:gsub("%s+", "")
	end)

	-- error mapping
	:map_err(function(err)
		return "mapped error: " .. tostring(err)
	end)

	-- fallback recovery for Err
	:or_else(function(err)
		print("Recovering from:", err)
		return Result.Ok("DEFAULT_VALUE")
	end)

local final_value = result:unwrap_or_else(function(err)
	print("Final handler caught:", err)
	return "FINAL_FALLBACK"
end)

print("result:", final_value)

