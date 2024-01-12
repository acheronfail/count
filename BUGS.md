# Bugs

**Need to confirm if `rss` is calculated correctly:**

For any programs that fork or use multiple threads, I don't think the current `gdb` script is working as expected.
Take `julia` for example: if you run `julia ./count.jl 100000000` and look at its RSS in `htop`, it exceeds 240MB easily, but our `gdb` implementation only shows ~1.5MB. After inspecting, it appears that `julia` uses several threads to run, and this is where the majority of that space is getting taken up.
