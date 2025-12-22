const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const target = try std.fmt.parseInt(u32, args[1], 10);
    var i: u32 = 0;

    while (i < target) : (i = (i + 1) | 1) {}

    var stdout = std.fs.File.stdout().writerStreaming(&.{});
    try stdout.interface.print("{}\n", .{i});
}
