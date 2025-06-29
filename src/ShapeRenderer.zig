const gl = @import("gl");

const zm = @import("zm");

const Vertex = @import("Vertex.zig");

const shader = @import("shader.zig");

const color = @import("color.zig");

const max_triangles = 4096;
const max_vertices = max_triangles * 3;
const max_indices = max_vertices * 12;

const ShapeRenderer = @This();

vao: u32,
vbo: u32,
ebo: u32,
shader_program: u32,

vertices: [max_vertices]Vertex,
num_vertices: u32,
indices: [max_indices]u32,
num_indices: u32,

proj: zm.Mat4f,
u_proj: i32,
view: zm.Mat4f,
u_view: i32,

pub fn create() !ShapeRenderer {
    var vao: u32 = undefined;
    gl.GenVertexArrays(1, (&vao)[0..1]);
    gl.BindVertexArray(vao);

    var vbo: u32 = undefined;
    gl.GenBuffers(1, (&vbo)[0..1]);
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo);

    var ebo: u32 = undefined;
    gl.GenBuffers(1, (&ebo)[0..1]);
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);

    gl.BufferData(gl.ARRAY_BUFFER, @sizeOf(Vertex) * max_vertices, null, gl.DYNAMIC_DRAW);
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, @sizeOf(u32) * max_indices, null, gl.DYNAMIC_DRAW);

    gl.EnableVertexAttribArray(0);
    gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, @sizeOf(Vertex), @offsetOf(Vertex, "pos"));
    gl.EnableVertexAttribArray(1);
    gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, @sizeOf(Vertex), @offsetOf(Vertex, "uv"));
    gl.EnableVertexAttribArray(2);
    gl.VertexAttribPointer(2, 4, gl.FLOAT, gl.FALSE, @sizeOf(Vertex), @offsetOf(Vertex, "color"));

    const shader_program = shader.loadDefaultProgram();

    const proj = zm.Mat4f.orthographic(0, 640, 360, 0, -1, 1);
    const u_proj = gl.GetUniformLocation(shader_program, "u_proj");

    const view = zm.Mat4f.translation(0, 0, 0);
    const u_view = gl.GetUniformLocation(shader_program, "u_view");

    return .{
        .vao = vao,
        .vbo = vbo,
        .ebo = ebo,
        .shader_program = shader_program,
        .vertices = undefined,
        .num_vertices = 0,
        .indices = undefined,
        .num_indices = 0,
        .proj = proj,
        .u_proj = u_proj,
        .view = view,
        .u_view = u_view,
    };
}

pub fn destroy(self: *ShapeRenderer) void {
    gl.DeleteVertexArrays(1, (&self.vao)[0..1]);
    gl.DeleteBuffers(1, (&self.vbo)[0..1]);
    gl.DeleteBuffers(1, (&self.ebo)[0..1]);
    gl.DeleteProgram(self.shader_program);
}

pub fn begin(self: *ShapeRenderer) void {
    self.num_vertices = 0;
    self.num_indices = 0;
}

pub fn end(self: *ShapeRenderer) void {
    gl.BindVertexArray(self.vao);
    gl.BindBuffer(gl.ARRAY_BUFFER, self.vbo);
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.ebo);
    gl.UseProgram(self.shader_program);

    gl.BufferSubData(gl.ARRAY_BUFFER, 0, @sizeOf(Vertex) * self.num_vertices, &self.vertices[0]);
    gl.BufferSubData(gl.ELEMENT_ARRAY_BUFFER, 0, @sizeOf(u32) * self.num_indices, &self.indices[0]);

    gl.UniformMatrix4fv(self.u_proj, 1, gl.TRUE, &self.proj.data[0]);
    gl.UniformMatrix4fv(self.u_view, 1, gl.TRUE, &self.view.data[0]);

    gl.DrawElements(gl.TRIANGLES, @intCast(self.num_indices), gl.UNSIGNED_INT, 0);

    gl.BindVertexArray(0);
    gl.BindBuffer(gl.ARRAY_BUFFER, 0);
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
    gl.UseProgram(0);
}

pub fn pushVertex(self: *ShapeRenderer, pos: zm.Vec2f, uv: zm.Vec2f, tint: zm.Vec4f) void {
    self.vertices[self.num_vertices].pos = pos;
    self.vertices[self.num_vertices].uv = uv;
    self.vertices[self.num_vertices].color = tint;
    self.num_vertices += 1;
}

pub fn pushIndex(self: *ShapeRenderer, v1: u32, v2: u32, v3: u32) void {
    self.indices[self.num_indices] = v1;
    self.num_indices += 1;
    self.indices[self.num_indices] = v2;
    self.num_indices += 1;
    self.indices[self.num_indices] = v3;
    self.num_indices += 1;
}

pub fn drawTriangle(
    self: *ShapeRenderer,
    p1: zm.Vec2f,
    p2: zm.Vec2f,
    p3: zm.Vec2f,
    tint: color.Rgba,
) void {
    const base = self.num_vertices;
    const tint_norm = color.toVec4f(tint);

    self.pushVertex(p1, zm.Vec2f{ 0, 0 }, tint_norm);
    self.pushVertex(p2, zm.Vec2f{ 0, 1 }, tint_norm);
    self.pushVertex(p3, zm.Vec2f{ 1, 0 }, tint_norm);

    self.pushIndex(base + 0, base + 1, base + 2);
}
