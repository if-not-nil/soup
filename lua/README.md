# soup/lua
> making lua do what it shouldn't

## usage
clone the `soup/` directory somewhere on your `package.path`

```lua
local soup = require("soup")
```

## toc
- [the useful stuff](#the-useful-stuff)
  - [soup.struct: type-safe structs](#soupstruct-type-safe-structs)
  - [soup.unfold: table pretty printing](#soupunfold-table-pretty-printing)
  - [soup.result: a Result structure](#soupresult-a-result-structure)
  - [soup.match: reusable match with guards](#soupmatch-reusable-match-with-guards)
- [the fun stuff (don't use)](#the-fun-stuff-dont-use)
  - [soup.lisp: a lisp (wip)](#souplisp-a-lisp-wip)
  - [soup.cout: stream style printing](#soupcout-stream-style-printing)
- [contributing](#contributing)

## the ./dev/ directory
this is where i experiment with stuff and keep examples. currently trying to do
tagged unions, packing unique data into the smallest space possible and doing
rust's traits and list comprehension

# future goals
- [x] extend monads and the Result table to be more useful
    - [ ] wrap some of the default library in it so that the cloudflare lua incident doesn't happen again
- [ ] iterators (that can be chained)
- [ ] socket and http libraries (either via luajit ffi wrappers or a single c file you have to build yourself)
- [ ] methods and traits on structs
- [x] typesafe-ish structs
    - [ ] methods
    - [ ] traits

# the useful stuff

## soup.struct: type-safe structs
```lua
Point = struct {
	{ "x", "number" },
	{ "y", "number" }
}

Line = struct {
	{ "start", Point },
	{ "end",   Point }
}
Email = struct { "string" }

local p1 = Point { 22, 33 }
assert(p1[7] == nil)
assert(p1.type == Point)
local p2 = Point { 44, 55 }
local l = Line { p1, p2 }

local email = Email("test@example.com")
assert(email[1] == "test@example.com")

assert(l.type == Line)
```
note that slot the type information is stored in slot 0

## soup.unfold: table pretty printing 
<img width="159" height="140" src="https://github.com/user-attachments/assets/87e084c8-4acb-4cb3-b598-991bad03871a" />

## soup.result: a Result structure 

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
**semantics**

- `bind(f)` expects `f :: value -> Result`
- exceptions inside `bind` / `map` are caught and converted to `Err`
- `unwrap()` throws
- `unwrap_or` never throws

## soup.match: reusable match with guards
**semantics**

- literal key matches are O(1)
- predicate cases are checked linearly
- first matching predicate wins

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

# the fun stuff (don't use)
    
## soup.lisp: a lisp (wip)
```lua
local Lisp = soup.lisp
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

## soup.cout: stream style printing
```lua
local cout = soup.cout
cout.infest_strings() -- to `"asdf" << cout`
cout << "hi" << cout.endl
"hi" >> cout.endl >> cout 
"hi" >> cout << cout.endl 
```

# contributing
feel free to make any contributions!

- if you made something cool but it's not ready yet, put it in `./dev/`
- keep dependencies minimal
