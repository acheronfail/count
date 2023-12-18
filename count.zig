const std = @import("std");

pub fn main() !void {
    var i: u32 = 0;
    while (i < 1_000_000_000) : (i += 1) {}
    std.debug.print("{}\n", .{i});
}
