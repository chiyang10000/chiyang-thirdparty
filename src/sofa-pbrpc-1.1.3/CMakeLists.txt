CMAKE_MINIMUM_REQUIRED(VERSION 3.4)
SET(CMAKE_CXX_STANDARD 11)
SET(CMAKE_VERBOSE_MAKEFILE ON CACHE BOOL OFF)

PROJECT(sofa-pbrpc VERSION 1.1.3)

ADD_DEFINITIONS(-DGOOGLE_ATTRIBUTE_DEPRECATED= -DBOOST_NO_CXX11_SMART_PTR)

IF(APPLE)
    SET(CMAKE_SHARED_LINKER_FLAGS "-undefined dynamic_lookup")
ENDIF(APPLE)

SET(SOFA_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src)

SET(proto_HDRS
    ${SOFA_SOURCE_DIR}/sofa/pbrpc/rpc_meta.pb.h
    ${SOFA_SOURCE_DIR}/sofa/pbrpc/rpc_option.pb.h
    ${SOFA_SOURCE_DIR}/sofa/pbrpc/builtin_service.pb.h
)
SET(proto_SRCS
    ${SOFA_SOURCE_DIR}/sofa/pbrpc/rpc_meta.pb.cc
    ${SOFA_SOURCE_DIR}/sofa/pbrpc/rpc_option.pb.cc
    ${SOFA_SOURCE_DIR}/sofa/pbrpc/builtin_service.pb.cc
)
ADD_CUSTOM_COMMAND(
    OUTPUT ${proto_HDRS} ${proto_SRCS}
    COMMAND echo "run compile_proto.sh"
    COMMAND cd ${SOFA_SOURCE_DIR} && sh ./compile_proto.sh
    COMMENT "compile proto files ...")

FILE(GLOB sofa_pbrpc_HEADERS "${SOFA_SOURCE_DIR}/sofa/pbrpc/*.h")
FILE(GLOB sofa_pbrpc_smartptr_HEADERS "${SOFA_SOURCE_DIR}/sofa/pbrpc/smart_ptr/*.hpp")
FILE(GLOB sofa_pbrpc_smartptr_detail_HEADERS "${SOFA_SOURCE_DIR}/sofa/pbrpc/smart_ptr/detail/*.hpp")
FILE(GLOB_RECURSE sofa_pbrpc_SOURCES "${SOFA_SOURCE_DIR}/*.cc")
LIST(REMOVE_ITEM sofa_pbrpc_SOURCES "${SOFA_SOURCE_DIR}/sofa/pbrpc/tcmalloc_extension_helper.cc")
LIST(APPEND sofa_pbrpc_HEADERS "${proto_HDRS}")

INCLUDE_DIRECTORIES(${SOFA_SOURCE_DIR})
INCLUDE_DIRECTORIES(${CMAKE_PREFIX_PATH}/include)

ADD_LIBRARY(sofa-pbrpc SHARED ${sofa_pbrpc_SOURCES} ${proto_SRCS})
TARGET_LINK_LIBRARIES(sofa-pbrpc -L${CMAKE_PREFIX_PATH}/lib pthread z snappy protobuf)

INSTALL(FILES ${sofa_pbrpc_HEADERS} DESTINATION include/sofa/pbrpc)
INSTALL(FILES ${sofa_pbrpc_smartptr_HEADERS} DESTINATION include/sofa/pbrpc/smart_ptr)
INSTALL(FILES ${sofa_pbrpc_smartptr_detail_HEADERS} DESTINATION include/sofa/pbrpc/smart_ptr/detail)

INSTALL(TARGETS sofa-pbrpc
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)
