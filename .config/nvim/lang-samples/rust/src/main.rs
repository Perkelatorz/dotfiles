fn main() {
    println!("{}", greet("nvim"));
}

fn greet(name: &str) -> String {
    format!("Hello, {name}!")
}
