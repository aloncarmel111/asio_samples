# 
# Copyright (c) 2010-2015 Marat Abrarov (abrarov@gmail.com)
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#

cmake_minimum_required(VERSION 2.8.11)

# Turn on Unicode support for MinGW for main function
if(MINGW)
    set(CMAKE_EXE_LINKER_FLAGS "-municode ${CMAKE_EXE_LINKER_FLAGS}")
endif()
