local M = {}

-- shared writer
local function make_writer(write_fn)
	local t = {}
	setmetatable(t, {
		__shl = function(self, value)
			if type(value) == "table" and value.__format then
				write_fn(value:__format())
			elseif type(value) == "table" and getmetatable(value) then
				write_fn(tostring(value))
			else
				write_fn(tostring(value))
			end

			return self
		end,

		__call = function(self)
			write_fn "\n"
			return self
		end,
	})
	return t
end

function M.cout()
	local colors = require("std").Colors
	local unfold = require("std").unfold

	local cout = make_writer(io.write)


	-- table pretty-print
	local mt = getmetatable(cout)
	local old_shl = mt.__shl
	mt.__shl = function(self, v)
		if type(v) == "table" and not v.__format and not getmetatable(v) then
			io.write(unfold(v))
			return self
		end
		return old_shl(self, v)
	end

	-- color/style helpers
	for name in pairs(colors.codes) do
		cout[name] = function(str)
			return colors.color(str)[name]()
		end
	end
	for name in pairs(colors.styles) do
		cout[name] = function(str)
			return colors.color(str)[name]()
		end
	end
	cout.endl = '\n'

	return cout
end

-- shared reader object
local function make_reader(read_fn)
	local t = {}
	setmetatable(t, {
		-- TODO: make it mutate tables its given
		__shr = function(self, prompt) -- >>
			if prompt then io.write(prompt) end
			return read_fn()
		end,
	})
	return t
end


M.endl = "\n" -- TODO: make it actually flush

M.cin = make_reader(function()
	return io.read "*l"
end)

M.fmt = {}

function M.fmt.color(str, code)
	return {
		__format = function()
			return string.format("\27[%sm%s\27[0m", code, str)
		end
	}
end

M.fmt.red   = function(str) return M.fmt.color(str, "31") end
M.fmt.green = function(str) return M.fmt.color(str, "32") end
M.fmt.blue  = function(str) return M.fmt.color(str, "34") end

return M
