const std = @import("std");

const glfw = @import("glfw");

const gl = @import("gl");

pub const app = @import("App.zig");

pub const ShapeRenderer = @import("ShapeRenderer.zig");

pub const color = @import("color.zig");

pub fn hello() void {
    std.debug.print("Hello from {s}!\n", .{"nova"});
}

pub fn clear(clear_color: color.Rgba) void {
    _ = clear_color;
    gl.ClearColor(1, 0, 0, 1);
    gl.Clear(gl.COLOR_BUFFER_BIT);
}
