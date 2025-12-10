local soup = require("soup")
local Lisp = soup.misc.lisp
local lib = Lisp.lib

Lisp { lib.print, "match statements!" }
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
		{ tonumber,  { lib.input, "yo\n> " } },
		{ 6,       "six" },
		{ 7,       "seven" },
		{ 67,      "six seveeen" },
		{ lib.tbl, { function (x) return x % 2 == 0 end, "seven" } },
		":(" -- default case
	}, "\n" }
};
---
