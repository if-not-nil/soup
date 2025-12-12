local M = {}

function M.bench(fn, N)
	local start = os.clock()
	for _ in ipairs(N) do
		fn(N)
	end
	return os.clock() - start
end

return M
