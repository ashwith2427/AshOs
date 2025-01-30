const std = @import("std");
const console = @import("console.zig");
const Colors = console.Colors;

const ALIGN: u32 = 1 << 0;
const MEMINFO: u32 = 1 << 1;
const FLAGS: u32 = ALIGN | MEMINFO;
const MB1_MAGIC: u32 = 0x0;

const MultibootHeader = extern struct {
    magic: u32 align(4) = MB1_MAGIC,
    flags: u32 align(4),
    checksum: u32 align(4),
};

export var multiboot align(4) linksection(".multiboot") = MultibootHeader{
    .flags = FLAGS,
    .checksum = @as(u32, (-(@as(i64, FLAGS) + @as(i64, MB1_MAGIC))) & 0xFFFFFFFF),
};

export fn _start() noreturn {
    @call(std.builtin.CallModifier.always_inline, main, .{});
    while (true) {}
}

fn current_exception_level() u64 {
    var m: u64 = 0;
    asm volatile (
        \\mrs %[m], CurrentEL
        :
        : [m] "r" (&m),
    );
    return m;
}

pub fn main() void {
    console.setColors(Colors.White, Colors.Black);
    console.clear();
    console.putString("Hello, world\n");
    // std.heap.page_allocator;

    // console.putNumber(current_exception_level());
}
