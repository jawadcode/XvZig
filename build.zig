// Credit to https://wiki.osdev.org/Zig_Bare_Bones

const std = @import("std");

pub fn build(b: *std.Build) void {
    const Target = std.Target;
    var disabled_features = Target.Cpu.Feature.Set.empty;
    var enabled_features = Target.Cpu.Feature.Set.empty;

    disabled_features.addFeature(@intFromEnum(Target.x86.Feature.mmx));
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
    b.installArtifact(kernel);
    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.step);
}
