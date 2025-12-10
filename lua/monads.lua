local M = {}

-- type Result
local Ok = function(value)
	return { ok = true, value = value }
end

local Err = function(err)
	return { ok = false, error = err }
end

local methods = {}

function methods:and_then(fn)
	assert(type(fn) == "function", "and_then expects a function")
	table.insert(self.chain, fn)
	return self
end

function methods:unwrap(fn)
	assert(type(fn) == "function", "unwrap expects a function")
	self.unwrap_fn = fn
	return self
end

function methods:checker(fn)
	assert(type(fn) == "function", "checker expects a function")
	self.checker_fn = fn
	return self
end

---@param ... any?
function methods:exec(...)
	local res = Ok(...)

	for _, f in ipairs(self.chain) do
		if not res.ok then
			if self.unwrap_fn then
				return self.unwrap_fn(res.error)
			else
				return res
			end
		end

		-- call fn with previous value
		-- local success, pres = pcall(f, res.value)
		-- if not success then return self.unwrap_fn(pres) end
		res = f(res.value)

		-- implicitly ok everything
		if res == nil or res.ok == nil then
			res = Ok(res)
		end

		-- apply checker if any
		if self.checker_fn then
			local ok, err = pcall(self.checker_fn, res)
			if not ok then
				res = Err(err)
			end
		end

		-- auto-wrap plain values as Ok
		if type(res) ~= "table" or res.ok == nil then
			res = Ok(res)
		end
	end

	-- final result
	if not res.ok and self.unwrap_fn then
		return self.unwrap_fn(res.error)
	end

	return res.ok and res.value or res
end

---@param ... any?
function methods:__call(...)
	return self:exec(...)
end

-- exports
M.Ok = Ok
M.Err = Err
M.monad = function()
	return setmetatable({
		chain = {},
		unwrap_fn = nil,
		checker_fn = nil
	}, { __index = methods, __call = methods.__call })
end

return M
