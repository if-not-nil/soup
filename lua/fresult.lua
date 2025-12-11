#!/usr/bin/env luajit

local ffi = require("ffi")
ffi.cdef [[
    typedef union {
        double num;
        void* ptr;
        int64_t i64;
        uint64_t u64;
    } ValueUnion;

    typedef struct {
        ValueUnion value;
        uint8_t ok;
        uint8_t type;  // 0=nil, 1=number, 2=string, 3=bool, 4=complex
    } Result;
]]

local TYPE_NIL = 0
local TYPE_NUMBER = 1
local TYPE_STRING = 2
local TYPE_BOOL = 3
local TYPE_COMPLEX = 4 -- tables, userdata, functions, etc.

-- fallback for complex types
local _store = {}
local _next_id = 0

local Result = ffi.metatype("Result", {
	__index = {
		unwrap = function(self)
			if self.ok == 0 then
				-- error path
				local err
				if self.type == 2 then -- string
					err = ffi.string(ffi.cast("char*", self.value.ptr))
				elseif self.type == 4 then -- complex
					err = _store[tonumber(self.value.u64)]
					_store[tonumber(self.value.u64)] = nil
				else
					err = "error"
				end
				error(err, 2)
			end

			-- success path
			if self.type == 0 then -- nil
				return nil
			elseif self.type == 1 then -- number
				return self.value.num
			elseif self.type == 2 then -- string
				return ffi.string(ffi.cast("char*", self.value.ptr))
			elseif self.type == 3 then -- bool
				return self.value.u64 ~= 0
			end
			-- complex
			local val = _store[tonumber(self.value.u64)]
			_store[tonumber(self.value.u64)] = nil
			return val
		end,

		is_ok = function(self)
			return self.ok == 1
		end,
	},

	__tostring = function(self)
		return self.ok == 1
			and "Ok()"
			or "Err()"
	end,

	__gc = function(self)
		if self.type == TYPE_COMPLEX then
			_store[tonumber(self.value.u64)] = nil
		end
	end,
})

local function Ok(v)
	local r = Result()
	r.ok = 1

	local t = type(v)
	if t == "nil" then
		r.type = TYPE_NIL
	elseif t == "number" then
		r.type = TYPE_NUMBER
		r.value.num = v
	elseif t == "string" then
		r.type = TYPE_STRING
		r.value.ptr = ffi.cast("void*", v) -- alright because of interning
	elseif t == "boolean" then
		r.type = TYPE_BOOL
		r.value.u64 = v and 1 or 0
	else -- complex
		r.type = TYPE_COMPLEX
		_next_id = _next_id + 1
		_store[_next_id] = v
		r.value.u64 = _next_id
	end

	return r
end

local function Err(e)
	local r = Result()
	r.ok = 0

	local t = type(e)
	if t == "string" then
		r.type = TYPE_STRING
		r.value.ptr = ffi.cast("void*", e)
	else
		r.type = TYPE_COMPLEX
		_next_id = _next_id + 1
		_store[_next_id] = e
		r.value.u64 = _next_id
	end

	return r
end

assert(Ok(42):unwrap() == 42)
assert(Ok("hello"):unwrap() == "hello")
assert(Ok(true):unwrap() == true)
assert(Ok(nil):unwrap() == nil)
assert(Ok({ 1, 2, 3 }):unwrap()[2] == 2)

local result = Err("something went wrong")
assert(not result:is_ok())
assert(not pcall(function() result:unwrap() end)) -- should error
