package.path = "../?.lua;" .. package.path
local fmt = require("fmt")
local println = fmt.println

---@generic V
---@param of table<V>|string
---@return iter<V>
local function iter(of)
	if type(of) == "string" then
		local sep = "%s"
		local t = {}
		for str in string.gmatch(of, "([^" .. sep .. "]+)") do
			table.insert(t, str)
		end
		of = t
	end

	---@class iter<V>
	local t = { value = of, chain = {} }

	---@generic V
	---@param fn fun(V): V
	function t:map(fn)
		-- table.insert(self.chain, function(v)
		-- 	return fn(v)
		-- end)
		for k, v in ipairs(self.value) do
			fn(v)
		end
		return self
	end

	---@generic V
	---@param fn fun(V): nil
	function t:for_each(fn)
		for k, v in ipairs(self.value) do
			self.value[k] = fn(v)
		end
		-- table.insert(self.chain, function(v)
		-- 	fn(v)
		-- 	return v
		-- end)
		return self
	end

	---@generic V
	---@return table<V>
	function t:exec()
		for k, _ in ipairs(self.value) do
			local v = self.value[k]
			for _, fn in ipairs(self.chain) do
				v = fn(v)
			end
			self.value[k] = v
		end
		return self.value
	end

	return t
end

local it = iter({ 1, 5, 3, 4, 6, 3, 4 })
	:map(function(v)
		return v * 2
	end)
	:for_each(function(v)
		println(v)
	end)
	:exec()

println(it)

local function bench(fn, N)
	local start = os.clock()
	for _ = 0, N do
		fn()
	end
	return os.clock() - start
end

local exec_time = bench(function()
	-- local a = { 1, 5, 3, 4, 6, 3, 4 }
	-- for k, v in ipairs(a) do
	-- 	a[k] = v * 2;
	-- 	_ = v
	-- end
	_ = iter({ 1, 5, 3, 4, 6, 3, 4 })
		:map(function(v)
			return v * 2
		end)
		-- :for_each(function(v)
		-- 	v = 0
		-- end)
		-- :exec()
end, 5000000)
println(exec_time)
