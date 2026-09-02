cmake_minimum_required(VERSION 3.24)

project(AROS VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(GNUInstallDirs)
include(CTest)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core DBus Gui Network Qml Quick QuickControls2)
find_library(PAM_LIBRARY pam REQUIRED)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(ar-app
    src/main.cpp
    src/systembridge.cpp
    src/systembridge.h
    src/searchprovider.cpp
    src/searchprovider.h
    src/notificationserver.cpp
    src/notificationserver.h
    src/authcontroller.cpp
    src/authcontroller.h
)

qt_add_executable(ar-system-helper
    src/systemhelper.cpp
)
target_link_libraries(ar-system-helper PRIVATE Qt6::Core)

qt_add_qml_module(ar-app
    URI AROS
    VERSION 1.0
    QML_FILES
        qml/components/Theme.qml
        qml/components/GlassPanel.qml
        qml/components/ARButton.qml
        qml/components/ARIcon.qml
        qml/components/ToggleSwitch.qml
        qml/components/SettingCard.qml
        qml/components/ARWindow.qml
        qml/components/NavItem.qml
        qml/shell/Shell.qml
        qml/apps/FilesApp.qml
        qml/apps/SettingsApp.qml
        qml/apps/SoftwareApp.qml
        qml/apps/UpdaterApp.qml
        qml/apps/AboutApp.qml
        qml/apps/OobeApp.qml
        qml/apps/LockApp.qml
    RESOURCES
        assets/icons/ar-logo.svg
        assets/icons/ar-logo-white.svg
        assets/wallpapers/ar-ribbon.svg
        assets/wallpapers/ar-night.svg
)

target_compile_definitions(ar-app PRIVATE
    AR_OS_VERSION="${PROJECT_VERSION}"
    QT_NO_CAST_FROM_ASCII
    QT_NO_CAST_TO_ASCII
)

target_link_libraries(ar-app PRIVATE
    Qt6::Core
    Qt6::DBus
    Qt6::Gui
    Qt6::Network
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    ${PAM_LIBRARY}
)

install(TARGETS ar-app ar-system-helper RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(PROGRAMS
    scripts/launchers/ar-shell
    scripts/launchers/ar-files
    scripts/launchers/ar-settings
    scripts/launchers/ar-terminal
    scripts/launchers/ar-software
    scripts/launchers/ar-updater
    scripts/launchers/ar-about
    scripts/launchers/ar-oobe
    scripts/launchers/ar-lock
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)
install(PROGRAMS scripts/ar-session scripts/ar-session-child
    DESTINATION ${CMAKE_INSTALL_LIBEXECDIR}/ar-os)
install(FILES assets/wallpapers/ar-ribbon.svg assets/wallpapers/ar-night.svg
    DESTINATION ${CMAKE_INSTALL_DATADIR}/backgrounds/ar-os)
install(FILES assets/icons/ar-logo.svg assets/icons/ar-logo-white.svg
    DESTINATION ${CMAKE_INSTALL_DATADIR}/ar-os/icons)
install(DIRECTORY config/kwin/arshell
    DESTINATION ${CMAKE_INSTALL_DATADIR}/kwin/scripts)
install(DIRECTORY config/sddm/ar-os
    DESTINATION ${CMAKE_INSTALL_DATADIR}/sddm/themes)
install(DIRECTORY config/plymouth/ar-os
    DESTINATION ${CMAKE_INSTALL_DATADIR}/plymouth/themes)
install(DIRECTORY config/calamares/
    DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/calamares)
install(FILES config/ar-os.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/wayland-sessions)
install(FILES config/systemd/user/ar-oobe.service
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/systemd/user)
install(FILES config/kwin/kwinrc
    DESTINATION ${CMAKE_INSTALL_DATADIR}/ar-os/defaults)
install(FILES config/konsole/AR-Terminal.profile
    DESTINATION ${CMAKE_INSTALL_DATADIR}/konsole)
install(DIRECTORY config/applications/
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)

if(BUILD_TESTING)
    find_package(Qt6 6.5 COMPONENTS Test QUIET)
    if(Qt6Test_FOUND)
        qt_add_executable(ar-core-tests
            tests/test_core.cpp
            src/systembridge.cpp
            src/systembridge.h
            src/searchprovider.cpp
            src/searchprovider.h
        )
        target_compile_definitions(ar-core-tests PRIVATE AR_OS_VERSION="${PROJECT_VERSION}")
        target_link_libraries(ar-core-tests PRIVATE
            Qt6::Core Qt6::DBus Qt6::Gui Qt6::Network Qt6::Test)
        add_test(NAME ar-core-tests COMMAND ar-core-tests)
    endif()
endif()
