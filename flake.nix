{
  description = "LibreVMS x86 BIOS microkernel bootstrap";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
    in {
      packages = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          image = pkgs.runCommand "librevms-boot.img" { nativeBuildInputs = [ pkgs.nasm pkgs.llvmPackages.clang-unwrapped pkgs.llvmPackages.lld ]; } ''
            nasm -f elf32 -o boot.o ${./src/bootstrap.asm}
            clang --target=i386-none-elf -march=i386 -m32 -Oz -ffreestanding -fno-pic \
              -fno-stack-protector -fno-unwind-tables -c ${./src/kernel.c} -o kernel.o
            ld.lld -m elf_i386 -T ${./src/layout.ld} --oformat=binary -o "$out" boot.o kernel.o
            test "$(wc -c < "$out")" -eq 512
          '';
        in {
          inherit image;
          default = pkgs.writeShellScriptBin "boot-librevms" ''
            exec ${pkgs.qemu}/bin/qemu-system-x86_64 -machine pc,accel=tcg \
              -display none -monitor none -serial stdio -nic none \
              -drive file=${image},format=raw,if=ide,snapshot=on "$@"
          '';
        });
    };
}
