#!/bin/sh

mkdir build && cd build

# Workaround for https://github.com/IntelRealSense/librealsense/issues/8250#issuecomment-768309524
if [[ "${target_platform}" == osx-* ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_THREAD_LIBS_INIT=-lpthread -DCMAKE_HAVE_THREADS_LIBRARY=1 -DCMAKE_USE_WIN32_THREADS_INIT=0 -DCMAKE_USE_PTHREADS_INIT=1 -DTHREADS_PREFER_PTHREAD_FLAG=ON"
fi

cmake ${CMAKE_ARGS} -GNinja \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_SHARED_LIBS=ON \
      -DENABLE_CCACHE=OFF \
      -DBUILD_WITH_OPENMP=OFF \
      -DFORCE_RSUSB_BACKEND=ON \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_UNIT_TESTS=OFF \
      -DCHECK_FOR_UPDATES=OFF \
      $SRC_DIR

cmake --build . --config Release 
cmake --install . --config Release 
