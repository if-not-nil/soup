-- local writers = require("writers")
-- local std = require("std")
-- local cout = writers.cout()

-- _ =
-- 	cout << std.Colors.color("error: "):Red():Bold() << "skill issues" << cout.endl

local std = require "std"
local monad, Ok, Err = (function(m)
	return m.monad, m.Ok, m.Err
end)(require "monads")

monad():and_then(function()
	return Ok("should be alright")
end):and_then(function(last)
	_ = last          -- was "should be alright"
	return "ok again" -- converted to Ok() implicitly
end):and_then(function(last)
	_ = last		  -- was "ok again"
	return Err("idk dawg")
end)
	:unwrap(function(err) -- runs on errors only
		print("unwrapper:", err)
		-- std.printf("error caught: %s", err)
	end)
	:checker(function(err) -- runs on every operator
		std.println("checker: ", err)
	end):exec()
