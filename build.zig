const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const nova = b.addModule("nova", .{
        .root_source_file = b.path("src/nova.zig"),
        .target = target,
        .optimize = optimize,
    });

    const gl_mod = @import("zigglgen").generateBindingsModule(b, .{
        .api = .gl,
        .version = .@"3.3",
        .profile = .core,
    });
    nova.addImport("gl", gl_mod);

    const zm_dep = b.dependency("zm", .{
        .target = target,
        .optimize = optimize,
    });
    nova.addImport("zm", zm_dep.module("zm"));

    const zglfw_dep = b.dependency("zglfw", .{
        .target = target,
        .optimize = optimize,
    });
    nova.addImport("glfw", zglfw_dep.module("root"));

    // desktop only for now
    if (target.result.os.tag != .emscripten)
        nova.linkLibrary(zglfw_dep.artifact("glfw"));
}
