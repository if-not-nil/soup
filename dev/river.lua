-- river.lua --
--
-- little testing framework
--
-- part of the soup files
-- https://github.com/if-not-nil/soup
local M = {}
package.path = "../?.lua;" .. package.path
local fmt = require("fmt")
local color = fmt.Colors.color
local printf = fmt.printf

---@type integer
M.TotalExpectations = 0
---@type integer
M.SuccessfulExpectations = 0
setmetatable(M, {
	__close = function(self)
		printf(
			"tests ran! %s successful, %s failed",
			color(self.SuccessfulExpectations):Green(),
			color(self.TotalExpectations - self.SuccessfulExpectations):Red()
		)
	end,
})
function M.expect_stats()
	return M.SuccessfulExpectations, M.TotalExpectations
end

--
-- helper parking lot
--

---@param file string
---@param n integer
---@return string?
local function get_line(file, n)
	local f <close> = io.open(file, "r")
	if not f then
		return nil
	end
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
		printf("%s:\n! %s", color(e.in_file .. ":" .. e.line_number):Cyan(), e.line or e.message)
	end
end

--
-- context and thread safety
--

---@class TestContext
---@field description string
---@field errors table[]
---@field count integer

---@type table<thread, TestContext[]>
local ctx_for_thread = {}

---@type TestContext[]
M.ErrorStack = {}

--
-- expect function
--

---@param condition boolean
---@param message? string
function M.expect(condition, message)
	local co = coroutine.running() or "main"
	local stack = ctx_for_thread[co]
	if not stack or #stack == 0 then
		error("expect called outside of test context", 2)
	end

	local ctx = stack[#stack] -- get current test context
	ctx.count = ctx.count + 1
	M.TotalExpectations = M.TotalExpectations + 1

	if condition then
		M.SuccessfulExpectations = M.SuccessfulExpectations + 1
		return
	end

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

---@param fn function()
---@param message? string
function M.expect_err(fn, message)
	local ok, _ = pcall(fn)
	M.expect(not ok, message or "expected function to throw an error")
end

--
-- the runner in question
--

---@param description string
---@param fn fun()
function M:test(description, fn)
	local ctx = { description = description, count = 0, errors = {} }
	local co = coroutine.running() or "main"

	ctx_for_thread[co] = ctx_for_thread[co] or {}
	table.insert(ctx_for_thread[co], ctx) -- push is here

	local ok, err = pcall(fn)
	if not ok then
		table.insert(ctx.errors, {
			message = "test threw: " .. tostring(err),
		})
	end

	table.remove(ctx_for_thread[co]) -- pop is here

	table.insert(M.ErrorStack, ctx)
	if #ctx.errors > 0 then
		print_error_stack(ctx)
	end
end

-- if not nil then
-- 	local expect = M.expect
-- 	M:test("asdfadsf", function()
-- 		expect(2 + 2 == 4)
-- 		M.expect_err(function()
-- 			return "asdf"
-- 		end, "shouldve errored but didtn")
-- 		expect(2 + 2 ~= 5)
-- 		expect(2 + 2 == 5, "2+2 should be 5")
-- 		expect(2 == 3, "2 should be 3")
-- 	end)
-- end

return M
