# soup/lua
this is a pure lua library for different stuff i've needed throughout using it

# the fun stuff
    
## a lisp (VERY wip)
```lua
Lisp {
	{ lib.print, "hello ", "world\n",
		{ lib.add, { lib.add, 59, 1 }, 7 }, "\n" },
	{ lib.print, { lib.match,
		{ lib.as, { lib.input, "yo\n> " }, "number" },
		{ 6,      "six" },
		{ 7,      "seven" },
		{ 67,     "six seveeen" },
		":(" -- default case
	}, "\n" }
}
```

# the useful stuff

## modern-ish monads

```lua
local std = require "std"
local monad, Ok, Err = (function(m)
    return m.monad, m.Ok, m.Err
end)(require "monads")

monad():and_then(function()
    return Ok("should be alright")
end):and_then(function(last)
    print(last) -- prints "should be alright"
    return "ok again" -- converted to Ok() implicitly
end):and_then(function(last)
    print(last)
    return Err("idk dawg")
end):unwrap(function(err)
    print(err)
    std.printf("error caught: %s", err)
end):exec()
```

## match in O(1) (unless you're using a predicate)

```lua
local m = match()
    :case(6, "six")
    :case(7, "seven")
    :case(67, "six seven")
    :case(function(x) return x % 2 == 0 end, "even")
    :case(function(x) return x % 2 ~= 0 end, "odd") -- you can add anything that can be called but it'd be a little too verbose for a demonstration
    :otherwise("idk")
 -- (6) -- this will execute it immediately
 -- :match(6) -- this too

std.println("6: ", m(6)) -- 6: six
std.println("7: ", m(7)) -- 7: seven
std.println("8: ", m(8)) -- 8: even
std.println("9: ", m(9)) -- 9: odd
std.println("67: ", m(67)) -- 67: six seven
```

or, if you scroll down futher through match.lua,
```lua
local res = -(match(value)
    | { 6, "six" }
    | { 7, "seven" }
    | { 67, "six seven" }
    | "") -- this is called immediately 
)```
