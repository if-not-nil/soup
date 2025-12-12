local M = {}

---@param ... any
M.println = function(...)
	local args = { ... }
	for _, v in ipairs(args) do
		if type(v) == "table" then
			io.write(M.unfold(v))
		elseif type(v) == "nil" then
			io.write("nil")
		else
			io.write(tostring(v))
		end
	end
	io.write('\n')
	io.flush()
end

---@param format string|number
---@param ... any
M.printf = function(format, ...)
	local args = { ... }
	for i, v in ipairs(args) do
		if type(v) == "table" then
			args[i] = M.unfold(v)
		end
	end
	print(string.format(format, table.unpack(args)))
end

M.Colors = {}

do
	M.Colors.codes = {
		Black = "30",
		Red = "31",
		Green = "32",
		Yellow = "33",
		Blue = "34",
		Magenta = "35",
		Cyan = "36",
		White = "37",
		Brown = "43",
	}

	M.Colors.styles = {
		Bold = "1",
		Italic = "3",
		Underline = "4"
	}

	local function wrap(str, codes)
		if #codes == 0 then return str end
		return string.format("\27[%sm%s\27[0m", table.concat(codes, ";"), str)
	end

	local StyledString = {}
	StyledString.__index = function(self, key)
		local code = M.Colors.codes[key] or M.Colors.styles[key]
		if code then
			return function()
				table.insert(self.codes, code)
				return self
			end
		else
			return rawget(StyledString, key)
		end
	end

	function StyledString:__tostring()
		return wrap(self.str, self.codes)
	end

	---@param str string
	function M.Colors.color(str)
		local obj = setmetatable({ str = str, codes = {} }, StyledString)
		return obj
	end
end


-- for use in unfold
local function colorize(value, kind)
	local Colors = M.Colors
	if kind == "key" then
		return tostring(Colors.color(value):Red():Bold())
	elseif kind == "number" then
		return tostring(Colors.color(value):Cyan())
	elseif kind == "string" then
		return tostring(Colors.color('"' .. value .. '"'):Green())
	elseif kind == "comma" then
		return tostring(Colors.color(value):Brown())
	else
		return tostring(value)
	end
end

---inspect.lua has more features than this, but this function is definitely good enough and not 9kb
---@param tbl table
---@param indent? number
function M.unfold(tbl, indent)
	-- BUG: just array with no non-numeric keys have the closing bracket on a new line
	-- TODO: print the metatables for whatever u pass in
	if type(tbl) ~= "table" then
		if type(tbl) == "number" then
			return colorize(tbl, "number")
		elseif type(tbl) == "string" then
			return colorize(tbl, "string")
		else
			return tostring(tbl)
		end
	end

	indent = indent or 0
	local prefix = string.rep("  ", indent)
	local ret = "{"

	-- separate numeric and string keys
	local nums, strs = {}, {}
	for k in pairs(tbl) do
		if type(k) == "number" then
			table.insert(nums, k)
		else
			table.insert(strs, k)
		end
	end

	table.sort(nums)
	table.sort(strs, function(a, b) return tostring(a) < tostring(b) end)

	-- inline numeric values
	if #nums > 0 then
		local inline = {}
		for _, k in ipairs(nums) do
			local v = tbl[k]
			table.insert(inline, type(v) == "table" and M.unfold(v, indent + 1) or colorize(v, type(v)))
		end
		ret = ret .. " " .. table.concat(inline, ", ") .. ','
	end

	-- each key-value pair on its own line
	for _, k in ipairs(strs) do
		local v = tbl[k]
		local keyStr = colorize(tostring(k), "key")
		local valueStr = type(v) == "table" and M.unfold(v, indent + 1)
			or colorize(v, type(v))
		ret = string.format("%s\n%s%s = %s,", ret, string.rep("  ", indent + 1), keyStr, valueStr)
	end

	-- final line
	ret = string.format("%s\n%s}", ret, prefix)
	return ret
end

return M
