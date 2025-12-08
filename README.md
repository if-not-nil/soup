# the soup files
i have a ton of code i reuse entirely too much, so i've collected them here, each in their respective folder

- [what it does](#what-it-does)
- [usage (c)](#usage-c)
- [usage (rust)](#usage-rust)

## what it does
### c
- dynamic array macros
### rust
- a grid datastructure
- pretty print utilities
- general advent of code utils

## usage (c)
you're supposed to directly use the header file
```wget https://raw.githubusercontent.com/if-not-nil/soup/refs/heads/main/c/soup.h```
and then import it

## usage (rust)
cargo, surprisingly, doesn't require the crate to be at the root of the
repository. that means, you can just run
```sh
cargo add soup --git https://github.com/if-not-nil/soup
```

or add it directly to your `cargo.toml`
```toml
[dependencies]
soup = { git = "https://github.com/if-not-nil/soup" }
```
