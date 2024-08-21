# Introduction

This Package forms part of the seL4 Developer Kit. It provides a fully
coordinated build of MaaXBoard Microkit, at an older version, to satisfy some
legacy dependicies. Some other Packages associated with the seL4 Developer Kit
depend upon this Package in achieving a consistent build of this MaaXBoard
Microkit.

# Usage

Must be invoked inside the following:
* sel4devkit-maaxboard-microkit-docker-dev-env

Show usage instructions:
```
make
```

Remove previously built output, and rebuild:
```
make reset
make get
make all
```

# Maintenance

Presents detailed technical aspects relevant to understanding and maintaining
this Package.

## Retain Previously Built Output

For consistency and understanding, it is generally desirable to be able to
build from source. However, in this instance, the build process can be
particularly time consuming. As a concession, the build output is prepared in
advance, and retained in the Package. Where this previously built output is
present, it shall block a rebuild. If the previously built output be removed
(`make reset`), then a rebuild may be triggered (`make all`).

The retention of build artefacts is ordinarily avoided, and this is reflected
in the configured set of file types to be ignored. As such, following a
rebuild, to examine and retain the resulting content (including build
artefacts), instruct git as follows:

Examine all files, including any that are ordinarily ignored:
```
git status --ignored
```

Force the addition of files, even if they ordinarily ignored:
```
git add --force <Path Files>
```

## Dependencies

Seeking a consistent build, both Microkit, and its dependency on seL4, are
fixed to specific revisions.

## Compiler Toolchain

Microkit currently assumes use of a specific Compiler Toolchain
(aarch64-linux-gnu). For environmental simplicity alone, we favour the default
Compiler Toolchain associated with our selected docker base image as provided
by Debian. Currently, Microkit does not provide a mechanism to select the
Compiler Toolchain. As a workaround, Microkit is trivially patched to adopt
this Compiler Toolchain (aarch64-linux-gnu).

## Increased Stack Size

Other Packages associated with the seL4 Developer Kit, which make use of this
Microkit, require a stack size greater than the Microkit default (4096 bytes).
This Microkit does not provide a configuration mechanism to control the stack
size. As a workaround, Microkit is trivially patched at build time to increase
the stack size (131072 bytes).

Note that the provision of too small stack size can lead to program failures
in unexpected locations, as the correspondence between logical program
behaviour and internal higher stack usage is not always obvious. To reduce the
likelihood of such confusing failures, we choose a stack size Knowingly larger
than our anticipated needs.

## Consistent Loader Link Address

This Microkit has a default Loader Link Address for MaaXBoard (0x40480000)
which clashes with memory allocation policies associated with a separate VMM
facility (Virtual Machine Manager). Microkit does not provide a configuration
mechanism to control the default Loader Link Address. As a workaround, the
Microkit is trivially patched at build time to change the Loader Link Address
(0x50000000).
