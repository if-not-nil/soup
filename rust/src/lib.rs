use std::{
    fmt::{Debug, Display},
    os::fd::AsRawFd,
};

///
/// really cool helpers
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
                use std::env::args;

                eprintln!(
                    "you're in a tty! you have to pipe your input into this program\n  $ cat ./input.in | {}",
                    args().collect::<Vec<_>>().join(" ")
                );
                std::process::exit(1);
            }
        }
    }

    std::io::read_to_string(std::io::stdin()).unwrap_or_else(|err| {
        eprintln!("something bad happened: {err}");
        std::process::exit(1);
    })
}

/// measure the time it takes to exec an expression
/// expr -> expr(), Time
#[macro_export]
macro_rules! measure {
    ($e:expr) => {{
        let now = std::time::Instant::now();
        ($e, now.elapsed())
    }};
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
