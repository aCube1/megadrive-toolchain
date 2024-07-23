# Megadrive toolchain for CMake

## Installation:

1. Clone repository:
	```sh
		$ git clone git@github.com:aCube1/megadrive-toolchain.git
	```
2. Copy `md.ld`, `boot` and `cmake` to the root of your project.
3. (Optional) Change the `boot/header.c` to suit your project.
4. Add the toolchain to the build using the `--toolchain` flag.
5. Set the `SGDK_PATH` variable to the path of the `SGDK` library.

## Functions:

- `megadrive_create_rom(<target>)`: Create the ROM, strip the `ELF` header,
  build and link the SGDK on the final binary file.
- `megadrive_include_resources(<target> <filepath>)`: Invoke the `RESCOMP` to
  generate the resource assembly and header files from `.res` file.

---
### Notes:
I'm not a CMake expert, I just did this toolchain to help me in future
projects on the Megadrive.</br>
Your contribution to fix/improve this project will be appreciated.

- [SGDK project](https://github.com/Stephane-D/SGDK)
- [Coppeti's Megadrive overview](https://www.copetti.org/writings/consoles/mega-drive-genesis)
