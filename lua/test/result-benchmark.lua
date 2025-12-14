package.path = "../?.lua;" .. package.path
local Result = require("result")

local function bench(name, N, f)
	collectgarbage()
	collectgarbage()

	local t0 = os.clock()
	for _ = 1, N do f() end
	local dt = os.clock() - t0

	print(string.format("%-25s  %.3f s", name, dt))
end

local N = 1000000 -- 0.8s on the normal impl

bench("empty loop", N, function() end)

bench("Ok() only", N, function()
	Result.Ok("hi")
end)

local r = Result.Ok("hi")
bench("unwrap() only", N, function()
	r:unwrap()
end)

bench("Ok():unwrap()", N, function()
	Result.Ok("hi"):unwrap()
end)

-- best-case luajit scenario
local function f(x) return x end
bench("Ok():map():unwrap()", N, function()
	Result.Ok("hi"):map(f):unwrap()
end)

local function g(x) return Result.Ok(x) end
bench("Ok():bind():unwrap()", N, function()
	Result.Ok("hi"):bind(g):unwrap()
end)

local e = Result.Err("nope")
bench("Err:unwrap_or()", N, function()
	e:unwrap_or("hi")
end)

bench("plain lua value", N, function()
	local x = "hi"
	return x
end)

bench("table only", N, function()
	return { "hi" }
end)
