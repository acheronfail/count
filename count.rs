use std::env;

fn main() {
    let mut i = 0;
    let target = env::args().nth(1).unwrap().parse::<i32>().unwrap();
    while i < target {
        i = (i + 1) | 1;
    }

    println!("{}", i);
}
