# docker-mingw-qt5
mingw-based build environment based on arch-linux. Contains mingw- versions of Qt5, cmake, Eigen3, boost.
# Usage
Start the docker container:
```bash
sudo docker run -it burningdaylight/docker-mingw-qt5 /bin/bash
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

That's it!
# Dependencies
If you need some other dependencies, you can install them from [AUR][1]. If mingw- version of the needed libarary is not available in AUR, you can add it yourself. The process is really straightforward. You would need to write a [PKBUILD file][2], which is as intuitive as it can get, see [mingw-w64-rapidjson][3], for example.

[1]: https://aur.archlinux.org/packages/?O=0&SeB=nd&K=mingw-w64&outdated=&SB=v&SO=d&PP=250&do_Search=Go
[2]: https://wiki.archlinux.org/index.php/creating_packages
[3]: https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-rapidjson
