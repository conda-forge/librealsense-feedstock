#!/bin/sh

mkdir build && cd build

# Workaround for https://github.com/IntelRealSense/librealsense/issues/8250#issuecomment-768309524
if [[ "${target_platform}" == "osx-arm64" || "${target_platform}" == "linux-ppc64le" ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_THREAD_LIBS_INIT=-lpthread -DCMAKE_HAVE_THREADS_LIBRARY=1 -DCMAKE_USE_WIN32_THREADS_INIT=0 -DCMAKE_USE_PTHREADS_INIT=1 -DTHREADS_PREFER_PTHREAD_FLAG=ON"
fi

# Enable CUDA support
if [[ ! -z "${cuda_compiler_version+x}" && "${cuda_compiler_version}" == "11.*" ]]
then
    if [[ -z "${CUDA_HOME+x}" ]]
    then
        echo "==> cuda_compiler_version=${cuda_compiler_version}, extract manually CUDA_HOME variable"
        CUDA_GDB_EXECUTABLE=$(which cuda-gdb || exit 0)
        if [[ -n "$CUDA_GDB_EXECUTABLE" ]]
        then
            CUDA_HOME=$(dirname $(dirname $CUDA_GDB_EXECUTABLE))
        else
            echo "Cannot determine CUDA_HOME: cuda-gdb not in PATH"
            return 1
        fi
    fi
    CMAKE_ARGS="${CMAKE_ARGS} -DBUILD_WITH_CUDA=ON -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME} -DCMAKE_LIBRARY_PATH=${CUDA_HOME}/lib64/stubs -DCMAKE_CUDA_ARCHITECTURES=all"
elif [[ ! -z "${cuda_compiler_version+x}" && "${cuda_compiler_version}" != "None" ]]
then
    echo "==> cuda_compiler_version=${cuda_compiler_version}, use CMake's CUDA support"
    CMAKE_ARGS="${CMAKE_ARGS} -DBUILD_WITH_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=all"
else
    echo "==> cuda_compiler_version=${cuda_compiler_version}, disable CUDA support"
    CMAKE_ARGS="${CMAKE_ARGS} -DBUILD_WITH_CUDA=OFF"
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
      -DBUILD_PYTHON_BINDINGS:bool=true \
      -DPYTHON_EXECUTABLE="$PREFIX/bin/python" \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_UNIT_TESTS=OFF \
      -DCHECK_FOR_UPDATES=OFF \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      $SRC_DIR

cmake --build . --config Release 
cmake --install . --config Release

# Copy pyrealsense files to site-packages
mv $PREFIX/OFF/* $SP_DIR/
