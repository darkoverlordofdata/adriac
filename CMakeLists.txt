cmake_minimum_required ( VERSION 3.1 )
###################################################################################
#
#   Build adriac
#
###################################################################################
project ( adriac VERSION 0.1.1 )

#
# enable features
#
include ( CMakeToolsHelpers OPTIONAL )
list ( APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)
find_package (PkgConfig)
find_package (Vala REQUIRED)

#
#   libraries - sources & packages
#
if (EXISTS ${CMAKE_SOURCE_DIR}/data )
    add_subdirectory (data)
    list ( APPEND RESOURCES ${resources_gresource_xml_C_FILE} )
endif ()

#
#   generated code configuration
#
configure_file ( 
    ${CMAKE_SOURCE_DIR}/src/Config.vala.base 
    ${CMAKE_BINARY_DIR}/src/Config.vala 
)
file (RELATIVE_PATH CONFIG_VALA ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR}/src/Config.vala)

#
#   application source
#
list ( APPEND VALA_SOURCES ${CONFIG_VALA} )
list ( APPEND VALA_SOURCES src/adriac.vala )
list ( APPEND VALA_SOURCES src/helpers.vala )
list ( APPEND VALA_SOURCES src/parser.gs )
list ( APPEND VALA_SOURCES src/tokenizer.gs )
#
#   dependencies
#
list ( APPEND PACKAGES gio-2.0 )
list ( APPEND PACKAGES gee-0.8 )
list ( APPEND PACKAGES glib-2.0 )
list ( APPEND PACKAGES gobject-2.0 )

pkg_check_modules (DEPS REQUIRED ${PACKAGES})
add_definitions ( ${DEPS_CFLAGS} )
link_libraries ( ${DEPS_LIBRARIES} )
link_directories ( ${DEPS_LIBRARY_DIRS} )

#
#   compiler options
#
list ( APPEND VALAC_OPTIONS --disable-warnings)
list ( APPEND VALAC_OPTIONS --vapidir=${CMAKE_SOURCE_DIR}/src/vapis)


set ( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w" )

include_directories(AFTER ${INCLUDES})
#
#   compile vala code
#
include (ValaVersion)
ensure_vala_version (0.34 MINIMUM)
include (ValaPrecompile)
vala_precompile (
    VALA_C ${PROJECT_NAME}
        ${VALA_SOURCES}
    PACKAGES
        ${PACKAGES}
    CUSTOM_VAPIS
        ${CUSTOM_VAPIS}
    OPTIONS
        ${VALAC_OPTIONS}
    )

#
#   compile ccode & link executable
#
add_executable ( ${PROJECT_NAME} ${VALA_C} ${C_SOURCES} ${RESOURCES} )
target_link_libraries ( ${PROJECT_NAME} m )
install (TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)


# (generated from template: default. Do not modify. )
