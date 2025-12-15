# iterators

iterators in lua exist, but are not cleanly chainable like in other languages

## syntax

```lua
local alpha_c = into_iter("twenty123")
    :count() -- Iter<_> -> number

local lowercase_only = into_iter("AABBccdd")
    :filter(function(c) return ) -- string -> Iter<string>
    :filter(function(c) return c ) -- Iter<_> -> number
```
