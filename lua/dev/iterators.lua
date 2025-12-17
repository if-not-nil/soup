package.path = "../?.lua;" .. package.path
local fmt = require("fmt")
local println = fmt.println


---@generic V
---@param of table<V>
---@return iter<V>
local function iter(of)
	---@class iter<V>
	local t = { value = of, chain = {} }

	---@generic V
	---@param fn fun(V): V
	function t:map(fn)
		table.insert(self.chain, function(v)
			return fn(v)
		end)
		return self
	end

	---@generic V
	---@param fn fun(V): nil
	function t:for_each(fn)
		table.insert(self.chain, function(v)
			fn(v)
			return v
		end)
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
