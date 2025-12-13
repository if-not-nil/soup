-- cout.lua --
--
-- funny printer
--
-- cout << 'asdf' << cout.endl
-- 'asdf' >> cout
-- 'asdf' >> cout << cout.endl
--
-- part of the soup files
-- https://github.com/if-not-nil/soup
local M = { endl = {} }

setmetatable(M, {
	__call = function(_, filename)
		local t = { buffer = "", filename = filename }

		setmetatable(t, {
			__shl = function(self, other)
				if tostring(M.endl) == tostring(other) then -- check identity
					return self << "\n"
				end
				self.buffer = self.buffer .. tostring(other)
				return self
			end,
			__call = function(self)
				if self.filename then
					-- lua opens stdout implicitly?????
					local f = assert(io.open(self.filename, "w"))
					f:write(self.buffer)
					f:close()
				else
					io.write(self.buffer)
				end
			end
		})
		return t
	end,
	__shl = function(_, other)
		return M() << other
	end
})

local function make_chain(value)
	return setmetatable({ buffer = tostring(value) }, {
		__shr = function(self, other)
			if type(other) == "table" and getmetatable(other) and getmetatable(other).__shl then
				-- send buffer to cout object
				return other << self.buffer
			else
				-- accumulate string
				self.buffer = self.buffer .. tostring(other)
				return self
			end
		end
	})
end
local string_mt = debug.getmetatable("")
string_mt.__shr = function(str, other)
	return make_chain(str) >> other
end

return M
