local Result = {}
Result.__index = Result

function Result.Ok(v)
	return setmetatable({ ok = true, value = v }, Result)
end

function Result.Err(e)
	return setmetatable({ ok = false, error = e }, Result)
end

function Result:bind(f)
	if self.ok then
		local ok, r = pcall(f, self.value)
		if not ok then
			return Result.Err(r)
		end
		return r
	else
		return self
	end
end

function Result:map(f)
	if self.ok then
		local ok, v = pcall(f, self.value)
		if not ok then
			return Result.Err(v)
		end
		return Result.Ok(v)
	else
		return self
	end
end

function Result:map_err(f)
	if not self.ok then
		local ok, e = pcall(f, self.error)
		if not ok then
			return Result.Err(e)
		end
		return Result.Err(e)
	else
		return self
	end
end

function Result:unwrap_or(default)
	return self.ok and self.value or default
end

function Result:unwrap()
	if self.ok then
		return self.value
	else
		error(self.error, 2)
	end
end

function Result:unwrap_or_else(f)
	if self.ok then
		return self.value
	end
	local ok, v = pcall(f, self.error)
	if not ok then
		error(v, 2)
	end
	return v
end

function Result:or_else(f)
	if self.ok then
		return self
	end
	local ok, r = pcall(f, self.error)
	if not ok then
		return Result.Err(r)
	end
	return r
end

local function benchmark(N)
	local Ok = Result.Ok
	local start = os.clock()
	for i = 1, N do
		Ok(i):unwrap()
		Ok("hello"..i):unwrap()
		Ok({ a = 1, b = i }):unwrap()
	end
	print(string.format("%d iterations in %.3f seconds", N, os.clock() - start))
end
benchmark(5e6) -- 5 million
return Result
