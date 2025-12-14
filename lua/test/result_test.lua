package.path = "../?.lua;" .. package.path
local Result = require("init").result

local function expect_error(f, msg)
    local ok, err = pcall(f)
    assert(not ok, "expected error")
    if msg then
        assert(tostring(err):match(msg), ("expected error matching %q, got %q"):format(msg, err))
    end
end

-- Ok and Err work
local ok = Result.Ok(42)
local err = Result.Err("fail")

assert(ok:unwrap() == 42)
assert(ok:unwrap_or(0) == 42)
assert(err:unwrap_or(0) == 0)
expect_error(function() err:unwrap() end, "fail")

-- map
local ok2 = ok:map(function(x) return x * 2 end)
assert(ok2:unwrap() == 84)

local err2 = err:map(function(x) return x * 2 end)
assert(err2:unwrap_or(0) == 0)

-- map_err
local err3 = err:map_err(function(e) return e .. "!" end)
assert(err3:unwrap_or("") == "fail!")

local ok3 = ok:map_err(function(e) return e .. "!" end)
assert(ok3:unwrap() == 42)

-- bind
local bound = ok:bind(function(x) return Result.Ok(x + 1) end)
assert(bound:unwrap() == 43)

local bound_err = ok:bind(function(_) return Result.Err("oops") end)
assert(bound_err:unwrap_or("") == "oops")

local bind_on_err = err:bind(function(x) return Result.Ok(x + 1) end)
assert(bind_on_err:unwrap_or(0) == 0)

-- or_else
local or_else_res = err:or_else(function(e) return Result.Ok(e .. " recovered") end)
assert(or_else_res:unwrap() == "fail recovered")

local or_else_err = err:or_else(function(e) return Result.Err(e .. " still fail") end)
assert(or_else_err:unwrap_or("") == "fail still fail")

local or_else_on_ok = ok:or_else(function(_) return Result.Err("nope") end)
assert(or_else_on_ok:unwrap() == 42)

-- unwrap_or_else
assert(ok:unwrap_or_else(function(_) return "fallback" end) == 42)
assert(err:unwrap_or_else(function(e) return e .. "!" end) == "fail!")

-- pcall error handling in map/bind/or_else
local f_err = function() error("boom") end
local r1 = ok:map(f_err)
assert(r1:unwrap_or(""):match("boom"))

local r2 = ok:bind(f_err)
assert(r2:unwrap_or(""):match("boom"))

local r3 = err:or_else(f_err)
assert(r3:unwrap_or(""):match("boom"))

print("all Result tests passed")
