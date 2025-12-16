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
---@alias Result<T, E> Ok<T>|Err<E>
---@generic T, E

---@generic T
---@class Ok<T>
local Ok_mt = {}

Ok_mt.__index = Ok_mt

---@generic T
---@return T
function Ok_mt:unwrap()
	return self[1]
end

---@diagnostic disable-next-line: undefined-doc-param
---@param msg string
---@generic T
---@return T
function Ok_mt:expect(_) return self[1] end

---@generic T, U, E
---@param f fun(v: T): U
---@return Ok<U>|Err<E>
function Ok_mt:map(f)
	local ok, v = pcall(f, self[1])
	if not ok then
		return Err(v)
	end
	return Ok(v)
end

---@generic T, U, E
---@param f fun(v: T): Ok<U>|Err<E>
---@return Ok<U>|Err<E>
---@nodiscard
function Ok_mt:bind(f)
	local ok, r = pcall(f, self[1])
	if not ok then
		return Err(r)
	end
	return r
end

---@generic T
---@param default T
---@return T
---@diagnostic disable-next-line: unused-local
function Ok_mt:unwrap_or(default)
	return self[1]
end

---@generic T, E
---@param _ fun(e: E): T
---@return T
function Ok_mt:unwrap_or_else(_)
	return self[1]
end

---@generic T, E
---@param _ fun(e: E): any
---@return Ok<T>
function Ok_mt:or_else(_)
	return self
end

---@generic T, E
---@param _ fun(e: E): any
---@return Ok<T>
function Ok_mt:map_err(_)
	return self
end

--
-- Err
--

---@generic E
---@class Err<E>
local Err_mt = {}
Err_mt.__index = Err_mt

---@generic E
---@deprecated this will crash
---@return E
function Err_mt:unwrap()
	error(self[1], 2)
end

---@diagnostic disable-next-line: undefined-doc-param
---@param msg string
---@generic T
---@return T
function Err_mt:expect(msg) error(msg) end

---@generic T, E
---@param _ fun(v: T): any
---@return Err<E>
function Err_mt:map(_)
	return self
end

---@generic T, E
---@param _ fun(v: T): Ok<T>|Err<E>
---@return Err<E>
---@nodiscard
function Err_mt:bind(_)
	return self
end

---@generic E, F
---@param f fun(e: E): F
---@return Err<F>
function Err_mt:map_err(f)
	local ok, e = pcall(f, self[1])
	if not ok then
		return Err(e)
	end
	return Err(e)
end

---@generic T
---@param default T
---@return T
function Err_mt:unwrap_or(default)
	return default
end

function Err_mt:unwrap_err()
    return self[1]
end

---@generic T
---@diagnostic disable-next-line: undefined-doc-name
---@param f fun(e: E): T
---@return T
function Err_mt:unwrap_or_else(f)
	local ok, v = pcall(f, self[1])
	if not ok then
		error(v, 2)
	end
	return v
end

---@generic T, E
---@param f fun(e: E): Ok<T>|Err<E>
---@return Ok<T>|Err<E>
function Err_mt:or_else(f)
	local ok, r = pcall(f, self[1])
	if not ok then
		return Err(r)
	end
	return r
end

--
-- constructors
--
---@generic T
---@param v T
---@return Ok<T>
function Ok(v)
	return setmetatable({ v }, Ok_mt)
end

---@generic E
---@param e E
---@return Err<E>
function Err(e)
	return setmetatable({ e }, Err_mt)
end

---@generic E
---@return E
function Err_mt:err()
    return self[1]
end

---@generic T, E
---@deprecated trying to get an error value from ok will crash
function Ok_mt:err()
    error("trying to get an error value from ok")
end

return {
	Ok = Ok,
	Err = Err,
}
