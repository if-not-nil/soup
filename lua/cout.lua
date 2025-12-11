local M = {}

setmetatable(M, {
	__call = function()
		local t = { buffer = "" }

		setmetatable(t, {
			__shl = function(self, other)
				self.buffer = self.buffer .. tostring(other)
				return self
			end,
			__call = function(self)
				io.write(self.buffer)
			end
		})
		return t
	end,
	__shl = function(_, other)
		return M() << other
	end
})

-- setmetatable(M.cout, {
-- 	__shl = function(self, other)
-- 		return M.cout() << other
-- 	end
-- })
return M
