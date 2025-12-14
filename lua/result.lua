-- result.lua --
--
-- a rusty result union
--
-- part of the soup files
-- https://github.com/if-not-nil/soup
local setmetatable = setmetatable
local error = error
local pcall = pcall

--
-- Ok
--
local Ok_mt = {}
Ok_mt.__index = Ok_mt

function Ok_mt.unwrap(self)
	return self[1]
end

function Ok_mt.map(self, f)
	local ok, v = pcall(f, self[1])
	if not ok then
		return Err(v)
	end
	return Ok(v)
end

function Ok_mt.bind(self, f)
	local ok, r = pcall(f, self[1])
	if not ok then
		return Err(r)
	end
	return r
end

function Ok_mt.unwrap_or(self, _)
	return self[1]
end

function Ok_mt.unwrap_or_else(self, _)
	return self[1]
end

function Ok_mt.or_else(self, _)
	return self
end

--
-- Err
--
local Err_mt = {}
Err_mt.__index = Err_mt

function Err_mt.unwrap(self)
	error(self[1], 2)
end

function Err_mt.map(self, _)
	return self
end

function Err_mt.bind(self, _)
	return self
end

function Err_mt.map_err(self, f)
	local ok, e = pcall(f, self[1])
	if not ok then
		return Err(e)
	end
	return Err(e)
end

function Err_mt.unwrap_or(_, d)
	return d
end

function Err_mt.unwrap_or_else(self, f)
	local ok, v = pcall(f, self[1])
	if not ok then
		error(v, 2)
	end
	return v
end

function Err_mt.or_else(self, f)
	local ok, r = pcall(f, self[1])
	if not ok then
		return Err(r)
	end
	return r
end

--
-- constructors
--
function Ok(v)
	return setmetatable({ v }, Ok_mt)
end

function Err(e)
	return setmetatable({ e }, Err_mt)
end

return {
	Ok = Ok,
	Err = Err,
}
