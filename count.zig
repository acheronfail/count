const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var target = try std.fmt.parseInt(u32, args[1], 10);
    var i: u32 = 0;

    while (i < target) : (i = (i + 1) % 2000000000) {}

    std.debug.print("{}\n", .{i});
}
