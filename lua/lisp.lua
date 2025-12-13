-- lisp.lua --
--
-- a bad lisp interpreter
--
-- part of the soup files
-- https://github.com/if-not-nil/soup
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
