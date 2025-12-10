return function()
	local t = { cases = {}, predicates = {}, default = nil }

	function t:case(key, result)
		if (type(key) == "function")
			or (type(key) == table and key["__call"]) then
			self.predicates[key] = result
			return self
		end
		self.cases[key] = result
		return self
	end

	function t:otherwise(result)
		self.default = result
		return self
	end

	function t:match(value)
		if self.cases[value] then return self.cases[value] end

		for k, v in pairs(self.predicates) do
			if k(value) then return v end
		end
		return self.default
	end

	setmetatable(t, {
		__call = function(self, with)
			return self:match(with)
		end,
	})

	return t
end

-- this one is for the following syntax
-- local res = -(match(value)
-- 	| { 6, "six" }
-- 	| { 7, "seven" }
-- 	| { 67, "six seven" }
-- 	| ""
-- )
--
-- return function()
-- 	local t = { predicate = nil, cases = {} }
-- 	setmetatable(t, {
-- 		__bor = function(self, value)
-- 			if type(value) == "string" then
-- 				self.default = value
-- 				return self
-- 			elseif not type(value) == "table" then
-- 				print("invalid syntax")
-- 				return nil
-- 			end
-- 			self.cases[value[1]] = value[2]
-- 			return self
-- 		end,
-- 		__call = function(self, value)
-- 			self["predicate"] = value
-- 			return self
-- 		end,
-- 		__unm = function(self)
-- 			return self:eval()
-- 		end,
-- 	})
-- 	t.eval = function(self)
-- 		-- print("evaluating")
-- 		for k, v in pairs(self.cases) do
-- 			-- print(self.predicate, k, v)
-- 			if self.predicate == k then
-- 				return v
-- 			end
-- 		end
-- 		return self.default
-- 	end
-- 	return t
-- end
