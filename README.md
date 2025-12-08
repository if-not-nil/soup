# the soup files
i have a ton of code i reuse entirely too much, so i've collected them here, each in their respective folder

    - [what it does](#what-it-does)
    - [usage (c)](#usage-c)
- [usage (rust)](#usage-rust)

## what it does
### c
```c
"dynamic array macros";
    soup_arr(int);              // for a generic type, as soup_int_arr
    void int_arrays() {
        soup_int_arr arr = soup_int_arr_init(1);
        soup_int_arr_push(&arr, 9);
        soup_int_arr_print(&arr);
        printf("before shrink: size %lu\n", arr.capacity);
        soup_int_arr_shrink(&arr);
        printf("after shrink: size %lu\n", arr.capacity);
        return 0;
    }
    "named arrays";
    soup_arr_named(char, string);
    void strings() {
        string arr = string_init(8);
        string_push(&arr, 'a');
        printf("%s\n", arr.items);
        string_append(&arr, "hello world", 12);
        string_push(&arr, 'b');
        string_push(&arr, '\0');
        string_pop(&arr, 2);
        string_ensure_terminated(&arr);
        free(arr.items);
    }

```
### rust
```rust
"measure elapsed time";
    let (res, elapsed) = soup::measure!(long_operation()); // elapsed macro
    println!("elapsed: {}", soup::paint(elapsed, Color::Blue));

"quickly get some input without handling any errors";
    let input = stdin_or_die(); // also provides some guidance for users if they do it wrong
    let input_file = file_or_die("./input.in");
```

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
