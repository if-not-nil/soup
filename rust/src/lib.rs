use std::{
    fmt::{Debug, Display},
    os::fd::AsRawFd,
};

///
/// really cool helpers
///

/// measure the time it takes to exec an expression
/// expr -> expr(), Time
#[macro_export]
macro_rules! measure {
    ($e:expr) => {{
        let now = std::time::Instant::now();
        ($e, now.elapsed())
    }};
}

///
/// death helpers
///

macro_rules! make_colors {
    ($name:ident { $($variant:ident = $code:expr),* $(,)? }) => {
        pub enum $name {
            $($variant),*
        }

        impl $name {
            pub fn code(&self) -> &str {
                match self {
                    $(Self::$variant => $code),*
                }
            }
        }
    };
}

make_colors!(Color {
    Red = "1;31",
    Blue = "1;34",
    Green = "1;32",
    Bold = "1;1",
});

pub fn err_pretty(message: impl Display) -> String {
    paint(message, Color::Red) // bold red
}

pub fn num_blue(message: impl Display) -> String {
    paint(message, Color::Blue) // bold blue
}

pub fn paint(message: impl std::fmt::Display, color: Color) -> String {
    format!("\x1b[{}m{}\x1b[0m", color.code(), message)
}

pub fn die_pretty(message: impl Display) -> ! {
    panic!("\x1b[1;31m{}\x1b[0;0m", message);
    // eprintln!("\x1b[1;31m{}\x1b[0;0m", message);
    // std::process::exit(1)
}
pub trait PrettyUnwrap<T> {
    fn or_die(self) -> T;
    fn ponder(self, msg: impl Display) -> T;
}
impl<T, E: Display> PrettyUnwrap<T> for Result<T, E> {
    fn or_die(self) -> T {
        match self {
            Ok(v) => v,
            Err(e) => die_pretty(e),
        }
    }

    fn ponder(self, msg: impl Display) -> T {
        match self {
            Ok(v) => v,
            Err(e) => die_pretty(format!("{}: {}", msg, e)),
        }
    }
}
impl<T> PrettyUnwrap<T> for Option<T> {
    fn or_die(self) -> T {
        match self {
            Some(v) => v,
            None => die_pretty("unwrapped on None()"),
        }
    }

    fn ponder(self, msg: impl Display) -> T {
        match self {
            Some(v) => v,
            None => die_pretty(msg),
        }
    }
}

pub fn aoc_test<F, T>(file: &str, solver: F, n: usize)
where
    F: Fn(Vec<String>) -> T,
    T: Display,
{
    let (input, expected_opt) = file_or_die(file);
    let expected = expected_opt.or_die();
    let actual = solver(input).to_string();

    assert_eq!(
        actual,
        if n == 1 { expected.0 } else { expected.1 },
        "solution did not match expected output"
    );
}

pub fn run_and_print<F, T>(
    label: &str,
    input: &[String],
    expected_opt: &Option<(String, String)>,
    solver: F,
) where
    F: Fn(Vec<String>) -> T,
    T: Display,
{
    let (result, time) = measure!(solver(input.to_vec()));
    println!("| {label} -> {} (took {time:.2?})", num_blue(&result));

    if let Some((expected1, expected2)) = expected_opt {
        let expected = if label.to_lowercase().contains('1') {
            expected1
        } else {
            expected2
        };

        if result.to_string() != *expected {
            println!("| {} {}", err_pretty("   wanted"), num_blue(expected),);
        }
    }
}

///
/// read helpers
///

/// quick way to get everything
pub fn stdin_or_die() -> String {
    // if there's a will, there's a way
    #[cfg(unix)]
    {
        unsafe extern "C" {
            fn isatty(fd: i32) -> i32;
        }
        unsafe {
            if isatty(std::io::stdin().as_raw_fd()) != 0 {
                die_pretty(format!(
                    "you're in a tty! you have to pipe your input into this program\n  $ cat ./input.in | {}",
                    std::env::args().collect::<Vec<_>>().join(" ")
                ));
            }
        }
    }

    std::io::read_to_string(std::io::stdin()).unwrap_or_else(|err| {
        eprintln!("something bad happened: {err}");
        std::process::exit(1);
    })
}

/// advent of code expects to get one line from a big file so thats what im on
/// the first line for it to know what u expect should be `expected: 1 and 2`
/// filename -> (input lines, (expected, expected))
pub fn file_or_die(
    filename: impl AsRef<std::path::Path>,
) -> (Vec<String>, Option<(String, String)>) {
    let lines: Vec<String> = std::fs::read_to_string(&filename)
        .unwrap_or_else(|err| {
            eprintln!("Failed to read file {}: {err}", filename.as_ref().display());
            std::process::exit(1);
        })
        .lines()
        .map(|line| line.to_string())
        .collect();

    if lines.is_empty() {
        eprintln!("file {} is empty!", filename.as_ref().display());
        std::process::exit(1);
    }

    let first_line = lines[0].trim();
    if let Some(content) = first_line.strip_prefix("expected: ") {
        let (one, two) = content
            .split_once(" and ")
            .map(|(a, b)| (a.trim().to_string(), b.trim().to_string()))
            .unwrap_or_else(|| die_pretty(format!("invalid expected format: {content}")));

        (lines[1..].to_vec(), Some((one, two)))
    } else {
        (lines, None)
    }
}

/// 1d vector interpreted as a grid
#[derive(Clone)]
pub struct Grid<T> {
    inner: Vec<T>,
    pub width: usize,
    pub height: usize,
}

impl<T> Grid<T> {
    pub fn from_iter(it: impl Iterator<Item = T>, width: usize) -> Self {
        let inner: Vec<T> = it.collect();
        let height = inner.len() / width;
        Self {
            inner,
            width,
            height,
        }
    }

    pub fn at(&self, x: usize, y: usize) -> &T {
        &self.inner[y * self.width + x]
    }

    pub fn all(&self) -> &Vec<T> {
        &self.inner
    }
}

impl From<String> for Grid<char> {
    fn from(value: String) -> Self {
        let width = value.find('\n').unwrap_or(value.len());
        Grid::from_iter(value.chars().filter(|&c| c != '\n'), width)
    }
}

impl<T: Debug> Debug for Grid<T> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        for row in self.inner.chunks(self.width) {
            for element in row {
                Debug::fmt(element, f)?;
            }
            writeln!(f)?;
        }
        Ok(())
    }
}

impl<T: Display> Display for Grid<T> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        for row in self.inner.chunks(self.width) {
            for element in row {
                Display::fmt(element, f)?;
            }
            writeln!(f)?;
        }
        Ok(())
    }
}

/// directions so that u dont get lost in parsing (1, -1) with your eyes
#[derive(Clone, Copy)]
pub enum Direction {
    Down,
    DownLeft,
    DownRight,
    Up,
    UpLeft,
    UpRight,
    Left,
    Right,
}

pub trait One: Sized + std::ops::Mul<Self, Output = Self> {
    fn one() -> Self;
}

macro_rules! impl_one {
    ($($t:ty),+) => {
        $(impl One for $t {
            fn one() -> Self { 1 }
        })+
    };
    ($($t:ty: $e:expr),+) => {
        $(impl One for $t {
            fn one() -> Self { $e }
        })+
    };
}
impl_one!(usize, i32, isize);

impl Direction {
    /// apply to a tuple
    /// may overflow
    pub fn apply_t<T>(&self, (a, b): (T, T)) -> (T, T)
    where
        T: std::ops::Sub<Output = T> + std::ops::Add<Output = T> + One + Copy,
    {
        let one = T::one();
        match self {
            Direction::Down => (a, b + one),
            Direction::DownLeft => (a - one, b + one),
            Direction::DownRight => (a + one, b + one),
            Direction::Up => (a, b - one),
            Direction::UpLeft => (a - one, b - one),
            Direction::UpRight => (a + one, b - one),
            Direction::Left => (a - one, b),
            Direction::Right => (a + one, b),
        }
    }
    /// apply to two numbers
    /// may overflow
    pub fn apply<T>(&self, a: T, b: T) -> (T, T)
    where
        T: std::ops::Sub<Output = T> + std::ops::Add<Output = T> + One + Copy,
    {
        let one = T::one();
        match self {
            Direction::Down => (a, b + one),
            Direction::DownLeft => (a - one, b + one),
            Direction::DownRight => (a + one, b + one),
            Direction::Up => (a, b - one),
            Direction::UpLeft => (a - one, b - one),
            Direction::UpRight => (a + one, b - one),
            Direction::Left => (a - one, b),
            Direction::Right => (a + one, b),
        }
    }
}
