const console = @import("./console.zig");

export fn kmain() callconv(.C) void {
    console.initialize();
    console.puts("Hello Zig Kernel!");

    while (true) {
        asm volatile ("hlt");
    }
}
