cmake_minimum_required(VERSION 2.8)

# Here generate and include the mavlink headers needed for the block
include(${CMAKE_CURRENT_LIST_DIR}/Mavlink.cmake)

# Set these two paths to the corresponding location in your system
set(Boost_INCLUDE_DIR /usr/include)
set(Boost_LIBRARY_DIR /usr/lib)

find_package(Boost COMPONENTS system thread REQUIRED)
include_directories(${Boost_INCLUDE_DIR} ${CMAKE_CURRENT_LIST_DIR}/include)
link_directories(${Boost_LIBRARY_DIR})

add_library(udp_mavlink udp_mavlink_rec.cpp)
add_dependencies(udp_mavlink mavlink_headers)
target_link_libraries( udp_mavlink ${Boost_LIBRARIES} )

set(CMAKE_CXX_FLAGS "-fPIC")

# This would be the place of the mex exe
add_executable(UDPrec main.cpp)
target_link_libraries( UDPrec udp_mavlink )
