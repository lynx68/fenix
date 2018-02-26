# Makefile 
# Fenix Open Source Project by  Davor Siklic
#
# Marinas Gui Extra Libs
MG_EXTRA_LIBS=-lhbmzip -lxhb -lhbqtcore -lhbqtgui -lhbqtwebkit -lX11 -lQt5Core -lQt5Gui -lQt5Widgets -lQt5PrintSupport -lhbqtnetwork -lQt5Network -lQt5WebKit -lQt5WebKitWidgets -lQt5Quick -lQt5Qml -lQt5Sql -lQt5Sensors -lQt5Positioning -lQt5OpenGL
#MG_EXTRA_LIBS=-lhbmzip -lhbziparc -lhbzebra -lminizip -lhbtip -lhbxdiff -lxdiff -lxhb -lhbqtcore -lhbqtgui -lhbqtwebkit -lX11 -lQt5Core -lQt5Gui -lQt5Widgets -lQt5PrintSupport -lhbqtnetwork -lQt5Network -lQt5WebKit -lQt5WebKitWidgets -lQt5Quick -lQt5Qml -lQt5Sql -lQt5Sensors -lQt5Positioning -lQt5OpenGL
#
# Define QTPATH
#HB_QTPATH=/opt/clip/Qt5.3.1/5.3/gcc
#
# Marinas-gui Path
#MG_HBC=/opt/clip/marinas/gui/marinas-gui.hbc
#
# Harbour environment set
#export HB_WITH_QT=$(HB_QTPATH)/include
#export HB_QT_MAJOR_VER=5
#
# Installation path
INSTALL_PATH = /usr/local
#
# Run using make
#
atl:
	hbmk2 src/make.hbp 
#  -L$(HB_QTPATH)/lib $(MG_EXTRA_LIBS)
#	bin/fenix /usr/local/etc/fenix_msoft.ini
#
locale:
	hbi18n -q -g -obin/fenix.sr_RS.hbl src/locale.po/fenix.sr.po
	hbi18n -q -g -obin/fenix.cs_CZ.hbl src/locale.po/fenix.cs.po
#  hbi18n -m -osrc/locale.po/fenix.cs_CZ.po bin/.hbmk/linux/gcc/*.pot
#	hbi18n -m -osrc/locale.po/fenix.en_US.po bin/.hbmk/linux/gcc/*.pot
#	hbi18n -m -osrc/locale.po/fenix.de_DE.po bin/.hbmk/linux/gcc/*.pot

install:
	make
	make locale
	#sudo install --backup=numbered -g users bin/fenix $(INSTALL_PATH)/bin/nfenix
	sudo install -g users bin/fenix $(INSTALL_PATH)/bin/nfenix
	sudo install -g users bin/fenix.*.hbl $(INSTALL_PATH)/share/fenix/lang
#
clean:
	rm bin/fenix
	rm -rf bin/.hbmk
	rm *.log
	rm *log.htm
#
test:
	make
	bin/fenix
#
# System instalation in /usr/local/...
sys_install:
	#sudo mkdir -p $(INSTALL_PATH)/etc/fenix
	sudo mkdir -p $(INSTALL_PATH)/share/fenix
	#sudo mkdir -p $(INSTALL_PATH)/share/fenix/dat
	sudo mkdir -p $(INSTALL_PATH)/share/fenix/resource
	#sudo mkdir -p $(INSTALL_PATH)/share/fenix/log
	sudo mkdir -p $(INSTALL_PATH)/share/fenix/lang
	sudo cp -r res/* $(INSTALL_PATH)/share/fenix/resource
	sudo cp -r template/* $(INSTALL_PATH)/share/fenix/template
	sudo cp etc/fenix_local.ini $(INSTALL_PATH)/etc/fenix.ini
	##sudo addgroup -q fenix
	sudo chown root.fenix -R $(INSTALL_PATH)/etc/fenix.ini
	sudo chown root.fenix -R $(INSTALL_PATH)/share/fenix
	sudo chmod g+rw -R $(INSTALL_PATH)/etc/fenix.ini
	sudo chmod g+rw -R $(INSTALL_PATH)/share/fenix
	sudo mkdir -p /var/lib/fenix
	sudo mkdir -p /var/lib/fenix/dat	
	sudo mkdir -p /var/lib/fenix/log
	sudo chown root.fenix -R /var/lib/fenix 
	sudo chmod g+rw -R /var/lib/fenix



