const std = @import("std");

const gl = @import("gl");

pub fn loadFromMemory(source: []const u8, shader_type: u32) u32 {
    const shader = gl.CreateShader(shader_type);

    gl.ShaderSource(shader, 1, &.{source.ptr}, &.{@as(i32, @intCast(source.len))});
    gl.CompileShader(shader);

    var compile_succes: i32 = undefined;
    gl.GetShaderiv(shader, gl.COMPILE_STATUS, &compile_succes);
    if (compile_succes == gl.FALSE) {
        var message: [1024]u8 = undefined;
        var len: i32 = undefined;
        gl.GetShaderInfoLog(shader, 1024, &len, &message);
        std.debug.print("{s}\n", .{message[0..@intCast(len)]});
    }

    return shader;
}

pub fn loadFromFile(
    allocator: std.mem.Allocator,
    file: std.fs.File,
    shader_type: u32,
) !u32 {
    const source_len = file.getEndPos();
    const source = try file.readToEndAlloc(allocator, source_len);
    return loadFromMemory(source[0..source_len], shader_type);
}

pub fn loadFromFilePath(
    allocator: std.mem.Allocator,
    file_path: []const u8,
    shader_type: u32,
) !u32 {
    var file = std.fs.cwd().openFile(file_path, .{});
    defer file.close();
    return loadFromFile(allocator, file, shader_type);
}

const DEFAULT_VERT =
    \\#version 330 core
    \\layout (location = 0) in vec2 a_pos;
    \\layout (location = 1) in vec2 a_uv;
    \\layout (location = 2) in vec4 a_color;
    \\out vec2 v_uv;
    \\out vec4 v_color;
    \\uniform mat4 u_proj;
    \\uniform mat4 u_view;
    \\void main() {
    \\gl_Position = u_proj * u_view * vec4(a_pos, 0, 1);
    \\v_uv = a_uv;
    \\v_color = a_color;
    \\}
;

const DEFAULT_FRAG =
    \\#version 330 core
    \\in vec2 v_uv;
    \\in vec4 v_color;
    \\out vec4 f_color;
    \\void main() {
    \\f_color = v_color;
    \\}
;

var default_program: u32 = 0;

pub fn loadDefaultProgram() u32 {
    if (default_program == 0) {
        const vert_shader = loadFromMemory(DEFAULT_VERT, gl.VERTEX_SHADER);
        const frag_shader = loadFromMemory(DEFAULT_FRAG, gl.FRAGMENT_SHADER);

        default_program = gl.CreateProgram();

        gl.AttachShader(default_program, vert_shader);
        gl.AttachShader(default_program, frag_shader);

        gl.LinkProgram(default_program);

        gl.DetachShader(default_program, vert_shader);
        gl.DetachShader(default_program, frag_shader);

        gl.DeleteShader(vert_shader);
        gl.DeleteShader(frag_shader);

        return default_program;
    }

    return default_program;
}
