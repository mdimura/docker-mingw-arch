MinGW-arch
=================
mingw-based build environment based on arch-linux. The image provides easy and CI/CD friendly cross-compilation for windows target. mingw- versions of Qt5, cmake, Eigen3, boost are included. Dosens of [other libraries][1] are available from the package manager.

Table of Contents
----------------------

1. [Usage](#Usage)
2. [Dependencies](#Dependencies)
3. [Supported tags](#Supported-tags)

Usage
----------------------
Start the docker container:
```bash
sudo docker run -it burningdaylight/mingw-arch:qt /bin/bash
```
Compile your application (QNapi is used as an example here):
```bash
git clone --recursive 'https://github.com/QNapi/qnapi.git'
cd qnapi/
x86_64-w64-mingw32-qmake-qt5
make
```
Or for CMake:
```bash
x86_64-w64-mingw32-cmake ..
```
To __deploy__ the program, you will need to copy the dlls from `/usr/{x86_64-w64-mingw32,i686-w64-mingw32}/{bin,lib/qt/plugins/{imageformats,iconengines,platforms}}` (for x64 and x32 builds respectively) to the directory with the .exe file. The list of necessary dlls may vary. If a dll is missing, Windows will usually show an error popup window with the name of the missing dll, when you try to start the program.

That's it!

Dependencies
----------------------
If you need some other dependencies, you can install them from [AUR][1]. 
```bash
yay -S --noconfirm mingw-w64-rapidjson
```
If mingw- version of the needed libarary is not available in AUR, you can add it yourself. The process is really straightforward. You would need to write a [PKBUILD file][2], which is as intuitive as it can get, see [mingw-w64-rapidjson][3], for example.

Supported tags
----------------------
- `base` minimal cross-compilation environment which includes `yay` to install additional libraries from AUR and a small set of mingw-w64- packages: `cmake`, `gcc`, `zlib`
- `latest`, `qt` full-blown cross-compilation environment, which includes `Qt5`, `boost`, `openssl`, etc.

[1]: https://aur.archlinux.org/packages/?O=0&SeB=nd&K=mingw-w64&outdated=&SB=v&SO=d&PP=250&do_Search=Go
[2]: https://wiki.archlinux.org/index.php/creating_packages
[3]: https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-rapidjson
