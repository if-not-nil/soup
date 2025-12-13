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

assert(ok.ok == true)
assert(ok.value == 42)
assert(err.ok == false)
assert(err.error == "fail")

-- unwrap and unwrap_or
assert(ok:unwrap() == 42)
assert(ok:unwrap_or(0) == 42)
assert(err:unwrap_or(0) == 0)
expect_error(function() err:unwrap() end, "fail")

-- map
local ok2 = ok:map(function(x) return x * 2 end)
assert(ok2.ok == true)
assert(ok2.value == 84)

local err2 = err:map(function(x) return x * 2 end)
assert(err2 == err)

-- map_err
local err3 = err:map_err(function(e) return e .. "!" end)
assert(err3.ok == false)
assert(err3.error == "fail!")

local ok3 = ok:map_err(function(e) return e .. "!" end)
assert(ok3 == ok)

-- bind
local bound = ok:bind(function(x) return Result.Ok(x + 1) end)
assert(bound.ok == true and bound.value == 43)

local bound_err = ok:bind(function(_) return Result.Err("oops") end)
assert(bound_err.ok == false and bound_err.error == "oops")

local bind_on_err = err:bind(function(x) return Result.Ok(x + 1) end)
assert(bind_on_err == err)

-- or_else
local or_else_res = err:or_else(function(e) return Result.Ok(e .. " recovered") end)
assert(or_else_res.ok == true)
assert(or_else_res.value == "fail recovered")

local or_else_err = err:or_else(function(e) return Result.Err(e .. " still fail") end)
assert(or_else_err.ok == false)
assert(or_else_err.error == "fail still fail")

local or_else_on_ok = ok:or_else(function(_) return Result.Err("nope") end)
assert(or_else_on_ok == ok)

-- unwrap_or_else
assert(ok:unwrap_or_else(function(_) return "fallback" end) == 42)
assert(err:unwrap_or_else(function(e) return e .. "!" end) == "fail!")

-- pcall error handling in map/bind/or_else
local f_err = function() error("boom") end
local r1 = ok:map(f_err)
assert(r1.ok == false and r1.error:match("boom"))

local r2 = ok:bind(f_err)
assert(r2.ok == false and r2.error:match("boom"))

local r3 = err:or_else(f_err)
assert(r3.ok == false and r3.error:match("boom"))

print("all Result tests passed")
