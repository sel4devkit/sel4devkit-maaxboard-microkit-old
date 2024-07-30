# Introduction

This Package forms part of the seL4 Developer Kit. It provides a fully
coordinated build of MaaXBoard Microkit. Several other Packages associated
with the seL4 Developer Kit depend upon this Package in achieving a
consistent build of the MaaXBoard Microkit.

# Usage

Must be invoked inside the following:
* sel4devkit-maaxboard-microkit-docker-dev-env

Show usage instructions:
```
make
```

Build program:
```
make all
```

# Maintenance

Presents detailed technical aspects relevant to understanding and maintaining
this Package.

## Dependencies

Seeking a consistent build, both Microkit, and its dependency on seL4, are
fixed to specific revisions. The intention is to remain closely aligned with
release "1.3.0". As Microkit and seL4 evolve, it may become appropriate to
revisit these revisions, to benefit from any recent enhancements.

## Compiler Toolchain

Microkit currently assumes use of a specific Compiler Toolchain
(aarch64-linux-gnu). For environmental simplicity alone, we favour the default
Compiler Toolchain associated with our selected docker base image as provided
by Debian. Currently, Microkit does not provide a mechanism to select the
Compiler Toolchain. As a workaround, Microkit is trivially patched to adopt
this Compiler Toolchain (aarch64-linux-gnu).

## Increased Stack Size

Other Packages associated with the seL4 Developer Kit, which make use of
Microkit, require a stack size greater than the Microkit default (4096 bytes).
Currently, Microkit does not provide a configuration mechanism to control the
stack size. As a workaround, Microkit is trivially patched at build time to
increase the stack size (131072 bytes).

Note that the provision of too small stack size can lead to program failures
in unexpected locations, as the correspondence between logical program
behaviour and internal higher stack usage is not always obvious. To reduce the
likelihood of such confusing failures, we choose a stack size slightly larger
than our anticipated needs.

## Consistent Loader Link Address

The current default Loader Link Address for MaaXBoard (0x40480000) clashes
with memory allocation policies associated with a separate VMM facility
(Virtual Machine Manager). Microkit does not provide a configuration mechanism
to control the default Loader Link Address. As a workaround, Microkit is
trivially patched at build time to change the Loader Link Address 
(0x50000000).
