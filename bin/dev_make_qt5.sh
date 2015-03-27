#!/bin/bash
#
# Automatic download and compile whole harbour development including hbqt and 
# marinas gui
# used for QT version 5.3.1
#
# Harbour Path
HB_ROOT=/opt/clip/harbour
# hbqt path 
HBQT_ROOT=$HB_ROOT/addons
# harbour bin path
HB_BIN=$HB_ROOT/bin/linux/gcc
#
# export HB_QTPATH="/usr/bin/"
#
# System instale qt library version 5
#export HB_WITH_QT="/usr/include/qt5"
#export HB_QTPATH="/usr/x86_64-linux-gnu/bin/"
#
# User defined QT instaled pah 
#export HB_QTPATH="/opt/clip/Qt5.4/5.4/gcc_64/"
export QTPATH="/opt/clip/Qt5.4/5.4/gcc_64/"
#export HB_QTPATH="/opt/clip/Qt5.3.1/5.3/gcc_64/"
export HB_WITH_QT=$HB_QTPATH/include
#
export HB_QT_MAJOR_VER=5
#
#
MG_ROOT=/opt/clip/marinas
export MG_HARBOUR_PATH=$HB_ROOT
#export MG_MINGW_PATH=/usr
export MG_QT_PATH=$HB_QTPATH

export MG_EXTRA_LIBS="-lhbmzip -lhbziparc -lhbzebra -lminizip -lhbtip -lhbxdiff -lxdiff -lxhb -lhbqtcore -lhbqtgui -lhbqtwebkit -lX11 -lQt5Core -lQt5Gui -lQt5Widgets -lQt5PrintSupport -lhbqtnetwork -lQt5Network -lQt5WebKit -lQt5WebKitWidgets -lQt5Quick -lQt5Qml -lQt5Sql -lQt5Sensors -lQt5Positioning -lQt5OpenGL"

export PATH=$HB_BIN:$HB_QTPATH/bin:$PATH

#export HB_QT_BUILD_STATIC=yes
#export PATH=$PATH:$MG_HARBOUR_PATH/bin:$MG_MINGW_PATH/bin:$MG_QT_PATH/bin
#export PATH=$PATH:$HB_BIN

#echo $PATH
# Download/update latest harbour
echo $HB_ROOT

if [ -d $HB_ROOT ]; then
	git -C $HB_ROOT pull
else
	git clone https://github.com/harbour/core.git $HB_ROOT
fi
#
# Download hbqt
#if [ -d $HBQT_ROOT ]; then
#	svn update $HBQT_ROOT
#else
#	svn co http://svn.code.sf.net/p/qtcontribs/code/trunk $HBQT_ROOT
#fi
#
# Download marinas-gui
if [ -d $MG_ROOT ]; then
	svn update $MG_ROOT
else
	svn co  http://svn.code.sf.net/p/marinas-gui/code/v3 $MG_ROOT
fi
#
# Make harbour
make -C $HB_ROOT
#
# Make hbqt
#$HB_BIN/hbmk2 $HBQT_ROOT/qtcontribs.hbp -cflag=-fPIC
#
# Copy all *.ch files to harbour include directory 
find $HBQT_ROOT -name "*.ch" -type f -exec cp {} $HB_ROOT/include \;
#
# make marinas-gui
$HB_BIN/hbmk2 $MG_ROOT/gui/source/marinas-gui.hbp
#
# make marinas-gui demo
$HB_BIN/hbmk2 $MG_ROOT/gui/samples/maindemo.hbp -L$MG_QT_PATH/lib -I$MG_QT_PATH/include $MG_EXTRA_LIBS
#

