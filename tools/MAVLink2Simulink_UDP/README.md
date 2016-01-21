Details
=======


This block will take UDP messages from a user-specified port that contain Mavlink messages, decode those messages and give them as an output to the block. Currently only some small subset of messages are handled with this block. The messages that can be decoded as of now are mavlink debug vectors, and support is provided out-of-the-box for the following types:

    mavlink_msg_debug_vect_send(MAVLINK_COMM_X, "gyro", time, x, y, z);
    mavlink_msg_debug_vect_send(MAVLINK_COMM_X, "accel", time, x, y, z);
    mavlink_msg_debug_vect_send(MAVLINK_COMM_X, "magn", time, x, y, z);
    mavlink_msg_debug_vect_send(MAVLINK_COMM_X, "vispos", time, x, y, z);
    mavlink_msg_debug_vect_send(MAVLINK_COMM_X, "visatt", time, x, y, z);

So you should send one of the above if you intend to have the messages available in the Simulink block. The reason behind this is that it is non-trivial to modify the Simulink blocks from the C++ S-Function at execution time, so it is in any case impossible to provide an automatic interface as the one in QGroundcontrol and this scheme reduces the complexity of adding more custom messages without having to support every type of mavlink message. 

Installation
============

If you are on Windows 7 - 64 bits, precomipled binaries are supplied as well as the Visual Studio 2010 project files to compile the library easily. 

Mavlink headers are needed for the compilation of the block. A stripped-down version is included, however, if the latest messages wished to be used, a subgit is provided. If you want to use these latest headers you need to generate them. To do so, from the console:

    git submodule init
    git submodule update
    mkdir build && cd build
    cmake ..
    make

The block uses boost libraries for UDP communication and multi-threading. To compile the S-Function block in Linux, you will need to use the provided boost libraries with your MATLAB distribution. To do that a matlab script is provided, just run:

    >> autocompile

on the root folder mav2simulink. Another option is to just call the default boost libraries from the system and use the udp_library generated in the "make" command above (which also generate the full Mavlink headers):

    >> mex -Iinclude -lboost_thread -lboost_system -Lbuild -ludp_mavlink mav2simulink.cpp

This gave me problems when linking with the mex-compiled wrapper, since the versions linux and MATLAB libstdc++ are incompatible. 

Adding a new Message
===================

Here we assume we would like to send a custom message from a 3-Axis range sensor. The sensor reads the [x, y, z] values of range at time t. To send the message compatible with this block the message need to be specified as:

    mavlink_msg_debug_vect_send(MAVLINK_COMM_X, "range", time, x, y, z);

Where time is a uint64_t stamp and [x, y,i z] are floats and "range" is an arbitrary string message identifier. On the receiver side, the message would be automatically registered as available in the current buffer exposed to the S-Function wrapper. To access the new sensor data from Simulink, two things need to be modified: 

- The MAVLink_block.mdl: In Simulink, unlock the model, and in the parameter tab add a checkbox parameter with Promt as range , for instance, and same name for its variable. 

![ScreenShot](https://raw.github.com/FedeCamposeco/mav2simulink/master/add_parameter.png)

In the initialization tab, augment the msg_vector and msg_strings to include your parameter, so change from:

    msg_vector  = [int32(accel) int32(gyro) int32(magn) int32(vispos) int32(visatt)];
    msg_strings = {'accel', 'gyro', 'magn', 'vispos', 'visatt'};

to

    msg_vector  = [int32(accel) int32(gyro) int32(magn) int32(vispos) int32(visatt) int32(range)];
    msg_strings = {'accel', 'gyro', 'magn', 'vispos', 'visatt', 'range'};
 

- The mav2simulink.cpp: Look for the array of strings at the begginign of the file called keys. Add an element to the array, so change from: 


    static  std::string keys[5] = {"accel", "gyro", "magn", "vispos", "visatt"};
    
to

    static  std::string keys[5] = {"accel", "gyro", "magn", "vispos", "visatt", "range"};

It is important that this name matches two things: the name of the sent Mavlink message AND the position in the msg_vector of the same sensor in the Simulink initialization tab. 

