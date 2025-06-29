const std = @import("std");

const glfw = @import("glfw");

const gl = @import("gl");

var procs: gl.ProcTable = undefined;

var window: *glfw.Window = undefined;

const Options = struct {
    width: i32,
    height: i32,
    title: [:0]const u8,
    init: *const fn () anyerror!void,
    deinit: *const fn () void,
    tick: *const fn (dt: f32) void,
    draw: *const fn () void,
};

pub fn run(opts: Options) !void {
    try glfw.init();

    glfw.windowHint(.context_version_major, 3);
    glfw.windowHint(.context_version_minor, 3);
    glfw.windowHint(.opengl_profile, .opengl_core_profile);

    window = try glfw.Window.create(opts.width, opts.height, opts.title, null);
    defer window.destroy();

    glfw.makeContextCurrent(window);

    if (!procs.init(glfw.getProcAddress)) return error.GLInitFailed;

    gl.makeProcTableCurrent(&procs);
    defer gl.makeProcTableCurrent(null);

    gl.Viewport(0, 0, opts.width, opts.height);

    try opts.init();
    defer opts.deinit();

    var last_time: f32 = @as(f32, @floatCast(glfw.getTime()));
    while (!window.shouldClose()) {
        const curr_time = @as(f32, @floatCast(glfw.getTime()));
        const dt = curr_time - last_time;
        last_time = curr_time;

        glfw.pollEvents();
        opts.tick(dt);

        gl.ClearColor(1, 0, 0, 1);
        gl.Clear(gl.COLOR_BUFFER_BIT);
        opts.draw();

        window.swapBuffers();
    }
}
