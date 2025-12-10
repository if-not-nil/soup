# soup/lua
a pure lua library for different stuff i've needed throughout using it

to get started, get a copy of this directory and include soup.lua as soup

# future goals
- [ ] extend monads and the Result table to be more useful, wrap some of the default library in it so that the cloudflare lua incident doesn't happen again
- [ ] iterators (that can be chained)
- [ ] socket and http libraries (either via luajit ffi wrappers or a single c file you have to build yourself)
- [ ] make the lisp useful
	- [ ] return from expressions
    - [ ] a better way to use tables inside of it
	- [ ] macro system
	- [ ] make terse when serialized

# the useful stuff

## table pretty printing (soup.unfold)
<img width="159" height="140" src="https://github.com/user-attachments/assets/87e084c8-4acb-4cb3-b598-991bad03871a" />

## modern-ish monads (soup.monad)

```lua
local monad = soup.monad
local Ok = soup.Ok
local Err = soup.Err

local get_first_line = monad():and_then(function(filename)
	local file, err = io.open(filename, "r")
	if err then return Err(err) end

	return Ok(file)
end):and_then(function(file)
	local line = file:read("l")
	return line -- converted to Ok() implicitly
end):and_then(function(line)
	local without_spaces = string.gsub(line, "%s+", "")
	return Ok(without_spaces)
end):unwrap(function(err)
	print(err)
	soup.printf("error caught: %s", err)
	return Err(err)
end)

soup.println("got a line: ", get_first_line("soup.lua"))
```

## match in O(1) and/or with guards (soup.match)

```lua
local m = soup.match()
	:case(6, "six")
	:case(7, "seveen")
	:case(function(x) return x % 2 == 0 end, "even")
	:case(function(x) return x % 2 ~= 0 end, "odd")
	:otherwise("idk")

soup.println({
	["6"] = m(6),
	["7"] = m(7),
	["9"] = m(9),
	["17"] = m(10),
})
-- or as lisp for no reason
Lisp { lib.print, { m, 6 } }
```

or, if you scroll down futher through match.lua,
```lua
local res = -(match(value)
    | { 6, "six" }
    | { 7, "seven" }
    | { 67, "six seven" }
    | "") -- this is called immediately 
)
```

# the fun stuff
    
## a lisp (very wip) (soup.misc.lisp)
```lua
local Lisp = soup.misc.lisp
local lib = Lisp.lib

Lisp {
	{ print, "hello ", "world\n",
		{ lib.add, { lib.add, 59, 1 }, 7 }, "\n" },
	{ soup.println, { a = "yo" } },
	{ print, "matched and got ", { lib.match,
		{ tonumber, { lib.input, "yo\n> " } },
		{ 6,        "six" },
		{ 7,        "seven" },
		{ 67,       "six seveeen" },
		":(" -- default case
	}, "\n" }
};
```

feel free to make any contributions!
