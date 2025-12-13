# making lua do what it shouldn't: typesafe structs
> this is part of [the soup files](https://github.com/if-not-nil/soup). check them out, a rusty Result type, a match expression, and pretty print utilities are already on the list. please drop any suggestions you might have in the issues section

lua is a horrible, horrible language. it has one data structure for everything - the table, which i'll be exploiting here. 

my main inspiration is the zig struct syntax
```zig
pub const Database = struct {
    root: Directory,
    pub fn init(alloc: std.mem.Allocator) !Database {
        ...
    }
}; // this is from my project dbfs btw
```

which is just not that realistic to implement at all. but
i'll try hard enough to get motivated by the sunk cost fallacy

so in this one, i'll be implementing structs with no extra features

BUT, later on, the todo list is as follows:
    - [ ] traits: implement them to look like a magic rust translator. some
      easy ones which are already accessible thru metatables are:
        - [ ] `Grid:impl(Traits.debug(), function(self) end)` (you can now print() the grid and tostring() it)
        - [ ] `Email:impl(Traits.from("string"), function(str) end)` (you can now Email.from("asdf@yahoo.com"))
        - [ ] `Point:impl(Traits.sum(Point), function(self, other) end)` (you can now grid1 + grid2)
        - [ ] `Grid:impl(Traits.drop(), function(self) end)` (this will run when it goes out of scope after `local grid <close> = Grid(...)`)
        - [ ] `Grid:impl(Traits.trash(), function(self) end)` (this will run on garbage collection)
    - [ ] methods: exactly how it looks in normal lua, but one function is shared for all objects

# structs

traits in rust only work because

all tables in lua are always passed by reference, never by copy.

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
now this isn't some grand insane discovery, BUT it lets you do something that
most people don't think about when making tagged data structures in lua

usually, they are done like this:
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

this is a very sane approach, which is very readable and is very perfect in the context of a sane codebase

but it definitely is not a fun way to do things

so i settled on this syntax
```lua
local Point <const> = struct { x = "number", y = "number" }
local p1 = Point { 2, 8 } -- for those unfamiliar with lua, parentheses are implicit here.
local p2 = Point { 5, 5 } -- struct and point are called like functions (even though they're tables)
```

and the resulting structs, which look like

```lua
{Point, 2, 8}
{Point, 5, 5}
```

if you try to instantiate a point of 2 and "asdf", it's gonna give you an error,
which is where the safety comes in

**implementation details warning!!!!!**

> we're now at commit 2e5fa: `lua: structs work at a minimum-wage level`. it is not really relevant for the end version

here, `point` is a struct which stores these tables

```lua
local names, -- struct names: x and y 
      types, -- types: number, number
      index  -- indices: { x = 2, y = 1, }
      = {}, {}, {}
```

is the index table really that necessary? probably not. but the limitations forced me to make one

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

structs can also be embedded inside each other

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

but yeah, the implementation actually went down from about 32 lines to 20
(also it doesn't look stupid anymore)

and, since we won't have duck typing, i'll allow for single-field structs to be initialized like this

```lua
Email = struct { "string" }
local email = Email("test@example.com")
assert(email[1] == "test@example.com")
assert(email == "test@example.com") -- sugar in the __tostring metatable
```

but hold on

isn't the biggest argument against duck typing the email struct?
it's always a good idea to make invalid states unrepresentable. ideally, your pipeline would look like this:
- call `local email = Email.parse("test@example.com")`
- that function ensures the user's email isn't "asdf", <function>, or on outlook
- it would return the email struct (wrapped in the [Result struct from the soup files btw](https://github.com/if-not-nil/soup/tree/main/lua#a-result-structure-soupresult))
- you pass that into a function which requires an argument to be of the Email type
- if the soup dream lives on, it would also be done through pipe operators

so, that's what i'll be implementing next. thanks for coming to my ted talk
