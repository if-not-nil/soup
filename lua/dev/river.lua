-- river.lua --
--
-- little testing framework
--
-- part of the soup files
-- https://github.com/if-not-nil/soup
local M = {}
local fmt = require("fmt")
local println = fmt.println
local color = fmt.Colors.color
local printf = fmt.printf

-- ======================================================
-- helpers
-- ======================================================

---@param file string
---@param n integer
---@return string?
local function get_line(file, n)
	local f <close> = io.open(file, "r")
	if not f then return nil end
	local i = 1
	for line in f:lines() do
		if i == n then
			return line:gsub("^%s*(.-)%s*$", "%1")
		end
		i = i + 1
	end
	return nil
end

---@param stack table
local function print_error_stack(stack)
	printf(
		'test "%s": %s successful, %s failed',
		stack.description,
		color(stack.count - #stack.errors):Green(),
		color(#stack.errors):Red()
	)
	for _, e in ipairs(stack.errors) do
		printf(
			"%s:\n! %s",
			color(e.in_file .. ":" .. e.line_number):Cyan(),
			e.line or e.message
		)
	end
end

-- ======================================================
-- the tester in question
-- ======================================================

---@class TestContext
---@field description string
---@field errors table[]
---@field count integer

---@type TestContext[]
M.ErrorStack = {}

---run a test which you put expects inside of
---@param description string
---@param fn fun(expect: fun(condition:boolean, message?:string))
function M:test(description, fn)
	local ctx = { description = description, count = 0, errors = {} }

	-- local expect closure that captures this context
	local function expect(condition, message)
		ctx.count = ctx.count + 1
		if condition then return end

		local info = debug.getinfo(2, "Sl")
		local line_number = info.currentline
		local in_file = info.short_src
		local line = get_line(in_file, line_number)

		table.insert(ctx.errors, {
			message = message or "expectation failed",
			in_file = in_file,
			line_number = line_number,
			line = line,
		})
	end

	local ok, err = pcall(fn, expect)
	if not ok then
		table.insert(ctx.errors, {
			message = "test threw: " .. tostring(err)
		})
	end

	table.insert(M.ErrorStack, ctx)

	if #ctx.errors > 0 then
		print_error_stack(ctx)
	end
end

do
	M:test("asdfsadf", function(expect)
		expect(2 + 2 == 4)
		expect(2 + 2 ~= 5)
		expect(2 + 2 == 5, "2+2 should be 5")
		expect(2 == 3, "2 should be 3")
	end)
end

return M
