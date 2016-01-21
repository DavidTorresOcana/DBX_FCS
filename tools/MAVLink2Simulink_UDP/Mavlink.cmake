set(definition common.xml)
set(MAVGEN ${CMAKE_CURRENT_LIST_DIR}/mavlink/pymavlink/generator/mavgen.py)
set(defAbsPath ${CMAKE_CURRENT_LIST_DIR}/mavlink/message_definitions/v1.0/${definition})

find_package(PythonInterp 2 REQUIRED)

ADD_CUSTOM_COMMAND(
   OUTPUT ${definition}-stamp
   COMMAND ${PYTHON_EXECUTABLE} ${MAVGEN} --lang=C --wire-protocol=1.0 --output=${CMAKE_CURRENT_LIST_DIR}/include/mavlink ${defAbsPath} 
   COMMAND touch ${definition}-stamp
   DEPENDS ${defAbsPath}
)

add_custom_target(mavlink_headers ALL DEPENDS ${definition}-stamp)
