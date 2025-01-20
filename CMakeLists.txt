cmake_minimum_required(VERSION 3.28)
project(Viridien)


add_compile_options(-O3)

set(CMAKE_CXX_STANDARD 17)

add_executable(Viridien
        Viridien/BSM.cxx)

find_package(OpenMP)
if(OpenMP_CXX_FOUND)
    target_link_libraries(Viridien PUBLIC OpenMP::OpenMP_CXX)
endif()
