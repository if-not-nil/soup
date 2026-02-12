-- match.lua --
--
-- a match expression
--
-- usage:
-- local m = soup.match()
-- 	:case(6,
-- 		"six" >> cout)
-- 	:case(7,
-- 		"seveen" >> cout)
-- 	:case(function(x) return x % 2 == 0 end,
-- 		"even" >> cout)
-- 	:case(function(x) return x % 2 ~= 0 end,
-- 		"odd" >> cout)
-- 	:otherwise(
-- 		"idk" >> cout << cout.endl)
-- m(6)()
--
-- part of the soup files
-- https://github.com/if-not-nil/soup
return function()
	local t = { cases = {}, predicates = {}, default = nil }
	-- TODO: deep equality checks between tables

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
