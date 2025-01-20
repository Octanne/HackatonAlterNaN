cmake_minimum_required(VERSION 3.28)
project(Viridien)

add_compile_options(-O2)

set(CMAKE_CXX_STANDARD 17)

add_executable(Viridien
        Viridien/BSM.cxx)
