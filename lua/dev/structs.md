# making actual structs in lua

lua is a horrible, horrible language. it has one data structure for everything -
the table, which i'll be exploiting here 

my main inspirations is the zig struct syntax
```zig
pub const Database = struct {
    root: Directory,
    pub fn init(alloc: std.mem.Allocator) !Database {
        ...
    }
}; // this is from my project dbfs btw
```

which are nothing alike. and also just not realistic to implement at all. but
i'll try hard enough to get motivated by the sunk cost fallacy

# structs

traits in rust only work because

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

if you try and make a point of 2 and "asdf", it's gonna give you an error, which was the initial idea here

**implementation details warning!!!!!**

point here is a struct which stores those tables

```lua
local names, -- struct names: x and y 
      types, -- types: number, number
      index  -- indices: { x = 2, y = 1, }
      = {}, {}, {}
```

is the index table really necessary? i don't really know

but what's even worse is this line
```lua
table.sort(names) -- alphabetical
```
the named field order is kinda random in lua. when you try and index {x=nil, y=nil}, it might give you either x or y first.
another way to fix this would be making the user do
```lua
Point = struct { {"x", "number"}, {"y", "number"} }
```
which is ugly

so, putting all the sacrifices together lets me make a nice little oneliner
```lua
__index = function(tbl, key) return key and tbl[self.index[key]] end
```
and now we can get `point.x` and `point.y`, which asks the underlying type to tell it where x and y are

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

but what happens if you try to get `line.start.x`?

remember how i struggled with getting a point's fields to always be in order? that still doesn't work.

no matter how much you sort them, it'll still be unpredictable

but it's not like i cared about it looking nice or anything. i'm not even that mad

```lua
Point = struct {
    { "x", "number" },
    { "y", "number" }
}

Line = struct {
    { "start", Point },
    { "end",   Point }
}
```

so we have this syntax now

time to rewrite the whole module to look ugly now

but yeah, the implementation actually went down from about 32 lines to 20 (and it also doesn't look stupid)

and, since we won't have duck typing, i'll allow for single-field structs to be initialized like this

```lua
Email = struct { "string" }
```
