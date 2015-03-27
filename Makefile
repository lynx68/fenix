MG_EXTRA_LIBS=-lxhb -lhbqtcore -lhbqtgui -lhbqtwebkit -lX11 -lQt5Core -lQt5Gui -lQt5Widgets -lQt5PrintSupport -lhbqtnetwork -lQt5Network -lQt5WebKit -lQt5WebKitWidgets -lQt5Quick -lQt5Qml -lQt5Sql -lQt5Sensors -lQt5Positioning -lQt5OpenGL
HB_QTPATH=/opt/clip/Qt5.3.1/5.3/gcc_64
export HB_WITH_QT=$(HB_QTPATH)/include
export HB_QT_MAJOR_VER=5
#export LD_LIBRARY_PATH=$(HB_QTPATH)
# Sample Makefile
# Run using make
atl:
	hbmk2 -C src make.hbp -L$(HB_QTPATH)/lib $(MG_EXTRA_LIBS) -trace -run

install:
	sudo install --backup=numbered -g users fenix /usr/local/bin

clean:
	rm -rf .hbmk
	rm *.log
	rm *log.htm

