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

# the useful stuff

## a testing/benchmarking framework (soup.test)

## table pretty printing (soup.unfold)
<img width="159" height="140" src="https://github.com/user-attachments/assets/87e084c8-4acb-4cb3-b598-991bad03871a" />

## a Result structure (soup.monad)

```lua
local Result = soup.result

-- read the first line of the file soup.lua, returning an error if it fails
local line <const> = Result.Ok("soup.lua")
	:bind(function(filename)
		local file, err = io.open(filename, "r")
		if not file then
			return Result.Err(err)
		end
		return Result.Ok(file)
	end)
	:bind(function(file)
		local line = file:read("l")
		if not line then
			return Result.Err("file is empty")
		end
		return Result.Ok(line)
	end)
	:bind(function(line)
		if #line < 4 then
			return Result.Err("line too short")
		end
		local without_spaces = line:gsub("%s+", "")
		return Result.Ok(without_spaces)
	end)
    -- you can uncomment one of the following methods to unwrap
    -- :unwrap()
	-- :unwrap_or_else(function(err)
	-- 	print("Error:", err)
	-- 	soup.printf("error caught: %s", err)
	-- 	return err
	-- end)

-- if its successful
soup.println("got a line: ", line) -- got a line: {
								   --  ok = true,
								   --  value = "--exportingeverythingandflatteningit",
								   --}

-- if its an error
soup.println("got a line: ", line) -- got a line: {
								   --   ok = false,
								   --   error = "line too short",
								   -- }
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
