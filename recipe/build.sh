#!/bin/bash

# https://github.com/conda-forge/gsl-feedstock/issues/34#issuecomment-449305702
if [[ "$target_platform" == win* ]]; then
    export LIBS="-lcblas"
    export CPPFLAGS="$CPPFLAGS -DGSL_DLL"
    export CXXFLAGS="$CXXFLAGS -DGSL_DLL"
    export CFLAGS="$CFLAGS -DGSL_DLL"
    ./configure --prefix=${PREFIX} \
                --disable-static || (cat config.log && exit 1)
else
    export LIBS="-lcblas -lm"
    ./configure --prefix=${PREFIX}  \
                --host=${HOST} || (cat config.log && exit 1)
fi


[[ "$target_platform" == "win-64" ]] && patch_libtool

make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

ls -al "$PREFIX"/lib
ls -al "$PREFIX"/bin

rm "$PREFIX"/lib/libgslcblas.*
CBLAS_IMPL=$(readlink $PREFIX/lib/libcblas${SHLIB_EXT})
cp "$PREFIX/lib/${CBLAS_IMPL}" "$PREFIX/lib/libgslcblas${SHLIB_EXT}"

if [[ "$target_platform" == osx* ]]; then
    ln -s "libcblas.3.dylib" "$PREFIX/lib/libgslcblas.0.dylib"
    rm "$PREFIX/lib/libcblas.3.dylib"
    touch "$PREFIX/lib/libcblas.3.dylib"
elif [[ "$target_platform" == linux* ]]; then
    ln -s "libcblas.so.3" "$PREFIX/lib/libgslcblas.so.0"
    rm "$PREFIX/lib/libcblas.so.3"
    touch "$PREFIX/lib/libcblas.so.3"
fi
