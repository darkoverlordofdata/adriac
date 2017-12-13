#!/usr/bin/env sh

mkdir -p build
cd build
cmake -D CMAKE_C_COMPILER=/usr/bin/clang -D CMAKE_CXX_COMPILER=/usr/bin/clang++ ..
