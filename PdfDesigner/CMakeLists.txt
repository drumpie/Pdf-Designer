cmake_minimum_required(VERSION 3.16)
project(appPdfDesigner LANGUAGES CXX)

project(PdfDesigner VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

find_package(Qt6 REQUIRED COMPONENTS Pdf)
# target_link_libraries(mytarget Qt6::Pdf)

if(NOT DEFINED INSTALL_EXAMPLESDIR)
    set(INSTALL_EXAMPLESDIR "PdfDesigner")
endif()

set(INSTALL_EXAMPLEDIR "${CMAKE_INSTALL_BINDIR}/PdfDesigner")

find_package(Qt6 REQUIRED COMPONENTS Gui Qml OPTIONAL_COMPONENTS Svg)
if(NOT TARGET Qt::Svg)
    message(WARNING "QtSvg is required as runtime dependency for qtpdfquick examples.")
endif()

qt_standard_project_setup(REQUIRES 6.8)

# Class'ları buraya da tanımla
qt_add_executable(appPdfDesigner
    main.cpp
    # ${app_icon_resource_windows}
)

qt_add_resources(appPdfDesigner "Main.qml"
    PREFIX
        "/media"
    FILES
        ${main_media_files}
)

qt_add_qml_module(appPdfDesigner
    URI PdfDesigner
    VERSION 1.0
    QML_FILES
        Main.qml
        RESOURCES qml.qrc
        RESOURCES
        QML_FILES
        RESOURCES media/open-folder.png
        RESOURCES media/search.svg
)
# set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/media/pdf.ico")
    # qt_add_executable(photosurfaceexample main.cpp ${app_icon_resource_windows})

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appPdfDesigner PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appPdfDesigner
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

set (main_media_files
    "media/arrowLeft.svg"
    "media/openFile.svg"
    "media/options.svg"
    "media/zoomIn.svg"
    "media/zoomOut.svg"
    "media/search.svg"
    "media/send.svg"
    "Main.qml"
    "Prolab1.pdf"
)

target_link_libraries(appPdfDesigner
    PRIVATE Qt6::Quick
)
target_link_libraries(appPdfDesigner
    PUBLIC
    Qt::Gui
    Qt::Qml
)

include(GNUInstallDirs)
install(TARGETS appPdfDesigner
    BUNDLE DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
