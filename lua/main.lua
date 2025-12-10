local soup = require("soup")

-- Lisp { lib.print, "match statements!" }
-- require("io")
---
--- match statements
---
-- local m = soup.match()
-- 	:case(6, "six")
-- 	:case(7, "seveen")
-- 	:case(function(x) return x % 2 == 0 end, "even")
-- 	:case(function(x) return x % 2 ~= 0 end, "odd")
-- 	:otherwise("idk")
--
-- soup.println({
-- 	["6"] = m(6),
-- 	["7"] = m(7),
-- 	["9"] = m(9),
-- 	["17"] = m(10),
-- })
-- -- or as lisp for no reason
-- Lisp { lib.print, { m, 6 } }

---
--- lisp
---
-- local Lisp = soup.misc.lisp
-- local lib = Lisp.lib
-- Lisp {
-- 	{ print, "hello ", "world\n",
-- 		{ lib.add, { lib.add, 59, 1 }, 7 }, "\n" },
-- 	{ soup.println, { a = "yo" } },
-- 	{ print, "matched and got ", { lib.match,
-- 		{ tonumber, { lib.input, "yo\n> " } },
-- 		{ 6,        "six" },
-- 		{ 7,        "seven" },
-- 		{ 67,       "six seveeen" },
-- 		":(" -- default case
-- 	}, "\n" }
-- };
---
--- result type
---
local Result = soup.result

-- read the first line of the file soup.lua, returning an error if it fails
local line <const> = Result.Ok("soup.lua")
	:bind(function(filename)
		local file, err = io.open(filename, "r")
		if not file then
			return Result.Err(err)
		end
		return Result.Ok(file)
	end)
	:bind(function(file)
		local line = file:read("l")
		if not line then
			return Result.Err("file is empty")
		end
		return Result.Ok(line)
	end)
	:bind(function(line)
		if #line < 4 then
			return Result.Err("line too short")
		end
		local without_spaces = line:gsub("%s+", "")
		return Result.Ok(without_spaces)
	end)
    -- you can uncomment one of the following methods to unwrap
    -- :unwrap()
	-- :unwrap_or_else(function(err)
	-- 	print("Error:", err)
	-- 	soup.printf("error caught: %s", err)
	-- 	return err
	-- end)

-- if its successful
soup.println("got a line: ", line) -- got a line: {
								   --  ok = true,
								   --  value = "--exportingeverythingandflatteningit",
								   --}

-- if its an error
soup.println("got a line: ", line) -- got a line: {
								   --   ok = false,
								   --   error = "line too short",
								   -- }
