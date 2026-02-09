; RPD Sky Windows Installer (NSIS Script)
; Build with: makensis.exe windows_installer.nsi

!include "MUI2.nsh"
!include "x64.nsh"

; Application info
!define APPNAME "RPD Sky"
!define APPVERSION "2.0.0"
!define APPEXE "rpd_sky.exe"
!define APPID "com.alteralph.rpdsky"
!define COMPANYNAME "alteralph"
!define PUBLISHERNAME "alteralph"

; Registry keys
!define REG_ROOT "HKLM"
!define REG_APP_PATH "${REG_ROOT}\Software\${COMPANYNAME}\${APPNAME}"
!define REG_UNINSTALL_PATH "${REG_ROOT}\Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}"

; Installation paths
!define INSTALL_DIR "$PROGRAMFILES\${APPNAME}"
!define START_MENU_DIR "$SMPROGRAMS\${APPNAME}"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "icon.ico"
!define MUI_UNICON "icon.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "sidebar.bmp"

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Language
!insertmacro MUI_LANGUAGE "English"

; Installer attributes
Name "${APPNAME} ${APPVERSION}"
OutFile "dist\rpd-sky-${APPVERSION}-installer.exe"
InstallDir "${INSTALL_DIR}"
ShowInstDetails show
ShowUnInstDetails show

; Installer sections
Section "Install"
  SetShellVarContext all
  SetOutPath "${INSTALL_DIR}"
  
  ; Copy application files from build directory
  File /r "build\windows\x64\runner\Release\*.*"
  
  ; Copy icon files to installation directory
  File "icon.png"
  File "icon.ico"
  
  ; Create shortcuts
  CreateDirectory "${START_MENU_DIR}"
  CreateShortCut "${START_MENU_DIR}\${APPNAME}.lnk" "$INSTDIR\${APPEXE}" "" "$INSTDIR\icon.ico" 0 SW_SHOWNORMAL "" "$INSTDIR"
  CreateShortCut "${START_MENU_DIR}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\icon.ico"
  
  ; Create desktop shortcut
  CreateShortCut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\${APPEXE}" "" "$INSTDIR\icon.ico" 0 SW_SHOWNORMAL "" "$INSTDIR"
  
  ; Write registry entries
  SetRegView 64
  WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "InstallPath" "$INSTDIR"
  WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "DisplayName" "${APPNAME}"
  WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "DisplayVersion" "${APPVERSION}"
  WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "Publisher" "${PUBLISHERNAME}"
  WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "DisplayIcon" "$INSTDIR\icon.ico"
  SetRegView default
  
  ; Write uninstaller
  WriteUninstaller "$INSTDIR\uninstall.exe"
  
  SetDetailsPrint textonly
  DetailPrint "Installation Complete!"
SectionEnd

; Uninstaller section
Section "Uninstall"
  SetShellVarContext all
  SetRegView 64
  
  ; Remove shortcuts
  Delete "${START_MENU_DIR}\${APPNAME}.lnk"
  Delete "${START_MENU_DIR}\Uninstall.lnk"
  Delete "$DESKTOP\${APPNAME}.lnk"
  RMDir "${START_MENU_DIR}"
  
  ; Remove application directory
  RMDir /r "$INSTDIR"
  
  ; Remove registry entries
  DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
  
  SetRegView default
SectionEnd

; Helper functions
Function .onInit
  ${If} ${RunningX64}
    ; 64-bit Windows
  ${Else}
    MessageBox MB_OK "This application requires Windows 64-bit."
    Quit
  ${EndIf}
FunctionEnd
