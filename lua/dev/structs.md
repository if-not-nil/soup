# can c structs and rust traits be implemented with pure lua?

lua is a horrible, horrible language. it has one data structure for everything, which, god forbid, lets you 

# identity checking

all tables in lua are always passed by reference, nevery by copy.

they are also, on accident, usually the biggest and the smallest data structures possible.

so this opens up this neat little trick:
```lua
local l = {}
for _ = 1, 2 do
    print({})
end
for _ = 1, 2 do
    print(l)
end
```
```yaml
first one:
    table: ...50c0
    table: ...5100
second one:
    table: ...10c0
    table: ...10c0
...
```
now this isnt some grand insane discovery, BUT it lets you do something that
most people miss out on when making tagged things in lua

usually, they are done like this
```lua
local t = {
    type = "point",
    value = {1,2}
}
-- or
local t = {
    type = "line",
    value = {1,2,3,4}
}
```

this is a very sane approach that is very readable and is perfect in any sane codebase

but it's definitely not a fun way to do things

> we're now at commit 2e5fa: `lua: structs work at a minimum-wage level`
so i've decided to come up with this method
```lua
Point = struct { x = "number", y = "number" }
local p1 = Point { 2, 8 } -- for those unfamiliar with lua, parentheses are implicit here.
local p2 = Point { 5, 5 } -- struct and point are called like functions (even though they're tables)
```

and the resulting structs looks like

```lua
{Point, 2, 8}
{Point, 5, 5}
```

so, how is it different from the sane way?

first of all, a constructor is made automatically. it checks all the types when creating a struct
and you don't have to add the `if type(tbl[1]) == "string"`

structs can also be embedded inside eachother

```lua
local l = Line {
    Point { 11, 22 },
    Point { 33, 44 }
}

assert(l[0] == Line)
```
