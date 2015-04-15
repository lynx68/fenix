# Makefile 
# Fenix Open Source Project by  Davor Siklic
#
# Marinas Gui Extra Libs
MG_EXTRA_LIBS=-lxhb -lhbqtcore -lhbqtgui -lhbqtwebkit -lX11 -lQt5Core -lQt5Gui -lQt5Widgets -lQt5PrintSupport -lhbqtnetwork -lQt5Network -lQt5WebKit -lQt5WebKitWidgets -lQt5Quick -lQt5Qml -lQt5Sql -lQt5Sensors -lQt5Positioning -lQt5OpenGL
#
# Define QTPATH
HB_QTPATH=/opt/clip/Qt5.3.1/5.3/gcc_64
#
# Marinas-gui Path
MG_HBC=/opt/clip/marinas/gui/marinas-gui.hbc
#
# Harbour environment set
export HB_WITH_QT=$(HB_QTPATH)/include
export HB_QT_MAJOR_VER=5
#
# Run using make
#
atl:
	hbi18n -g -obin/fenix.sr_RS.hbl src/locale.po/fenix.sr.po
	hbi18n -g -obin/fenix.cs_CZ.hbl src/locale.po/fenix.cs.po
	hbmk2 src/make.hbp -L$(HB_QTPATH)/lib $(MG_EXTRA_LIBS) -run
#	hbi18n -g -obin/fenix.cs_CZ.hbl src/locale.po/fenix.cs_CZ.po
#  hbi18n -m -osrc/locale.po/fenix.cs_CZ.po bin/.hbmk/linux/gcc/*.pot
#	hbi18n -m -osrc/locale.po/fenix.en_US.po bin/.hbmk/linux/gcc/*.pot
#	hbi18n -m -osrc/locale.po/fenix.de_DE.po bin/.hbmk/linux/gcc/*.pot
#
install:
	sudo install --backup=numbered -g users fenix /usr/local/bin
#
clean:
	rm -rf bin/.hbmk
	rm *.log
	rm *log.htm
#
