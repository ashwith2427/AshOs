const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(
        .{
            .cpu_arch = .aarch64,
            .os_tag = .freestanding,
            .ofmt = .elf,
        },
    );
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "OS.elf",
        .root_source_file = b.path("src/kernel.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.setLinkerScript(b.path("src/kernel.ld"));
    exe.addAssemblyFile(b.path("src/start.S"));

    b.installArtifact(exe);
}
