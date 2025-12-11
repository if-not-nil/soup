#!/usr/bin/env luajit

local ffi = require("ffi")
ffi.cdef [[
    typedef struct {
        unsigned int id; // key into a lua table
		unsigned ok;     // 1 = Ok, 0 = Err
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

assert(Ok("good"):unwrap() == "good")
assert(not Err("bad"):is_ok())
