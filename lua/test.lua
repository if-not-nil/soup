local M = {}

function M.bench(fn, N)
	local start = os.clock()
	for _ in ipairs(N) do
		fn(N)
	end
	return os.clock() - start
end

local println = require("fmt").println
function M.test(name, fn)
	local res, asdf, xcvz = pcall(fn)
	println(res, "-", asdf, "-", xcvz)
end

M.test("is asdf", function()
	error("asdf")
end)

return M
