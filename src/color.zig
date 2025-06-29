const std = @import("std");
const zm = @import("zm");

pub const Rgba = zm.vec.Vec(4, u8);

pub fn toVec4f(self: Rgba) zm.Vec4f {
    return .{
        @as(f32, @floatFromInt(self[0])) / 255.0,
        @as(f32, @floatFromInt(self[1])) / 255.0,
        @as(f32, @floatFromInt(self[2])) / 255.0,
        @as(f32, @floatFromInt(self[3])) / 255.0,
    };
}

pub const nova_blue = Rgba{ 144, 240, 240, 255 };
pub const white = Rgba{ 255, 255, 255, 255 };
