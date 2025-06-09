// Credit to https://wiki.osdev.org/Zig_Bare_Bones

const std = @import("std");
const LazyPath = std.Build.LazyPath;

pub fn build(b: *std.Build) void {
    const Target = std.Target;
    var disabled_features = Target.Cpu.Feature.Set.empty;
    var enabled_features = Target.Cpu.Feature.Set.empty;

    disabled_features.addFeature(@intFromEnum(Target.x86.Feature.sse));
    disabled_features.addFeature(@intFromEnum(Target.x86.Feature.sse2));
    disabled_features.addFeature(@intFromEnum(Target.x86.Feature.avx));
    disabled_features.addFeature(@intFromEnum(Target.x86.Feature.avx2));

    enabled_features.addFeature(@intFromEnum(Target.x86.Feature.soft_float));

    const target_query = Target.Query{
        .cpu_arch = Target.Cpu.Arch.x86,
        .os_tag = Target.Os.Tag.freestanding,
        .abi = Target.Abi.none,
        .cpu_features_sub = disabled_features,
        .cpu_features_add = enabled_features,
    };

    const optimise = b.standardOptimizeOption(.{});
    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(target_query),
        .optimize = optimise,
        .code_model = .kernel,
    });

    kernel.setLinkerScript(b.path("linker.ld"));

    const nasm_files = [_][]const u8{"src/kstart.nasm"};
    for (nasm_files) |file| {
        const file_name = std.fs.path.basename(file);
        const file_stem = std.fs.path.stem(file_name);
        const obj_file_name = b.fmt("{s}.o", .{file_stem});
        const nasm = b.addSystemCommand(&.{"nasm"});
        nasm.addFileArg(b.path(file));
        nasm.addArgs(&.{ "-f", "elf32", "-o" });
        const obj_file_path = nasm.addOutputFileArg(obj_file_name);

        kernel.addObjectFile(obj_file_path);
    }

    b.installArtifact(kernel);
    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.step);

    const run_step = b.step("run", "Boot into the kernel with qemu");
    const run_cmd = b.addSystemCommand(&.{ "qemu-system-i386", "-kernel" });
    run_cmd.step.dependOn(kernel_step);
    run_cmd.addFileArg(kernel.getEmittedBin());
    // Pass `args` in `zig build run -- <args>` to qemu
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    run_step.dependOn(&run_cmd.step);
}
