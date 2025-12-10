-- a small wip lisp
--
-- Lisp {
-- 	{ lib.print, "hello ", "world\n",
-- 		{ lib.add, { lib.add, 59, 1 }, 7 }, "\n" },
-- 	{ std.println, {  a = "yo"  } },
-- 	{ lib.print, { lib.match,
-- 		{ lib.as, { lib.input, "yo\n> " }, "number" },
-- 		{ 6,      "six" },
-- 		{ 7,      "seven" },
-- 		{ 67,     "six seveeen" },
-- 		":(" -- default case
-- 	}, "\n" }
-- }
--
-- local std = require("std")
local M = {}
M.lib = {
	print = function(...) print(...) end,
	input = function(prompt)
		if prompt then io.write(prompt) end
		return io.read("l")
	end,
	add = function(a, b) return a + b end,
	sub = function(a, b) return a - b end,
	mul = function(a, b) return a * b end,
	div = function(a, b) return a / b end,
	as = function(a, type)
		if type == "number" then
			return tonumber(a)
		elseif type == "string" then
			return tostring(a)
		end
	end,

	match = function(value, ...)
		local patterns = { ... }
		for _, p in ipairs(patterns) do
			if type(p) ~= "table" then
				return p -- default case
			end
			local pat, result = table.unpack(p)
			if pat == "default" then
				return result
			elseif type(pat) == "function" then
				if p(value) == true then return result end
			elseif pat == value then
				return result
			end
		end
		return nil
	end,
	tbl = function(tbl)
		setmetatable(tbl, { __is_really_table = true })
		return tbl
	end
}
local function eval_list(list)
	if type(list) ~= "table" then
		return list -- atoms
	end

	local func = list[1]

	if type(func) == "table" then
		func = eval_list(func)
	end

	if type(func) == "function" then
		local args = {}
		for i = 2, #list do
			args[i - 1] = eval_list(list[i])
		end
		return func(table.unpack(args))
	else
		local result = {}
		for i = 1, #list do
			result[i] = eval_list(list[i])
		end
		return result
	end
end

function M.Expression()
	local t = { expression = {} }
	setmetatable(t, {
		__call = function(self, toplevel)
			self.expression = toplevel
			if (toplevel[1] ~= nil) and type(toplevel[1]) == "function" then
				return eval_list(toplevel)
			end
			for _, d in ipairs(self.expression) do
				eval_list(d)
			end
		end
	})
	return t
end

setmetatable(M, { __call = function(self, t) M.Expression()(t) end })

return M
