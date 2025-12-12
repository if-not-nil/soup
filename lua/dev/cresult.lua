#!/usr/bin/env luajit

local ffi = require("ffi")
ffi.cdef [[
    typedef struct {
		unsigned ok;     // 1 = Ok, 0 = Err
        unsigned int id; // key into a lua table
    } Result;
]]
local _store = {}
local _next_id = 0

local function store(value)
	_next_id = _next_id + 1
	_store[_next_id] = value
	return _next_id
end

local Result = ffi.metatype("Result", {
	__index = {
		unwrap = function(self)
			return self.ok == 1
				and _store[self.id]
				or error(_store[self.id])
		end,
		__tostring = function(self)
			return self.ok == 1
				and "Ok()"
				or "Err()"
		end,
		is_ok = function(self) return rawequal(self.ok, 1) end
	},
})
local function Ok(v)
	return Result(1, store(v))
end

local function Err(e)
	return Result(0, store(e))
end

-- assert(Ok(42):unwrap() == 42)
-- assert(Ok("hello"):unwrap() == "hello")
-- assert(Ok(true):unwrap() == true)
-- assert(Ok(nil):unwrap() == nil)
-- assert(Ok({ 1, 2, 3 }):unwrap()[2] == 2)
--
-- local result = Err("something went wrong")
-- assert(not result:is_ok())
-- assert(not pcall(function() result:unwrap() end))  -- should error

local function benchmark(N)
	local start = os.clock()
	for i = 1, N do
		Ok(i):unwrap()
		Ok("hello"..i):unwrap()
		Ok({ a = 1, b = i }):unwrap()
	end
	print(string.format("%d iterations in %.3f seconds", N, os.clock() - start))
	-- print(N .. " iterations in " .. os.clock() - start .. " seconds")
end
benchmark(5e6) -- 5 million
