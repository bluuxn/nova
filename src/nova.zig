const std = @import("std");

const glfw = @import("glfw");

const gl = @import("gl");

pub fn hello() void {
    std.debug.print("Hello from {s}!\n", .{"nova"});
}

pub const App = @import("App.zig");
