# soup.rs
```rust
"measure elapsed time";
    let (res, elapsed) = soup::measure!(long_operation()); // elapsed macro
    println!("elapsed: {}", soup::paint(elapsed, Color::Blue));

"quickly get some input without handling any errors";
    let input = stdin_or_die(); // also provides some guidance for users if they do it wrong
    let input_file = file_or_die("./input.in");
```

## usage
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

# contributing

feel free to make any issues or pull requests. can be a fix, a suggestion, a comment, a discussion, a request, or anything else you want to add to this

just make sure the title is `[language] rest of the title`
