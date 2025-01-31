const std = @import("std");
const PAGE_SHIFT: u8 = 12;
const TABLE_SHIFT: u8 = 9;
const SECTION_SHIFT: u8 = PAGE_SHIFT + TABLE_SHIFT;
const SECTION_SIZE = 1 << SECTION_SHIFT;
const PAGE_SIZE = 1 << PAGE_SHIFT;
const LOW_MEMORY = 2 * SECTION_SIZE;

extern var bss_begin: u8;
extern var bss_end: u8;

export fn _start() callconv(.Naked) noreturn {
    var mpidr_el1: u64 = 0;
    asm volatile ("mrs %[out], mpidr_el1"
        : [out] "=r" (mpidr_el1),
    );
    if (mpidr_el1 & 0xFF) {
        while (true) {}
    }
    mem_zero();
    asm volatile ("mov sp, %[out]"
        : [out] "=r" (LOW_MEMORY),
    );
    @call(std.builtin.CallModifier.always_inline, main, .{});
}

fn mem_zero() void {
    var x1: u64 = 0;
    asm volatile ("adr x0, %[out]"
        : [out] "=r" (bss_begin),
    );
    asm volatile ("adr x1, %[out]"
        : [out] "=r" (bss_end),
    );
    asm volatile ("sub x1, x1, x0");
    asm volatile ("str xzr, [x0], #8");
    asm volatile ("subs x1, x1, #8");
    asm volatile ("mrs %[out], x1"
        : [out] "=r" (x1),
    );
    if (x1 > 0) {
        mem_zero();
    }
}

pub fn main() void {}
