#!/bin/bash
# some variables have to be given like:
# $SRCROOT, $BUILD_DIR, $CONFIGURATION in this order

SRCROOT="/Users/mbergmann/Development/MySources/iKnowAndManage-bzr/trunk";
BUILD_DIR="$SRCROOT/build";
CONFIG="Deployment";
TARGET="iKnowAndManage";

# check these values
if [ $SRCROOT = "" ]; then
	echo "Have no SRCROOT!";
	exit 1;
fi
if [ $BUILD_DIR = "" ]; then
	echo "Have no BUILD_DIR!";
	exit 1;
fi
if [ $CONFIG = "" ]; then
	echo "Have no CONFIGURATION!";
	exit 1;
fi
if [ $TARGET = "" ]; then
	echo "Have no TARGET!";
	exit 1;
fi

# increment "buildnumber" and write it to Info.plist
./increment_buildnumber.rb
./write_buildnumber.rb

# build Deployment version
xcodebuild -target "$TARGET" -configuration "$CONFIG" clean build
#echo "rc = $RC";
#if [ $RC != 0 ]; then
#	echo "build did not succeed!";
#	exit 1;
#fi

# generate deploy archive
BUNDLEVERSION=`$SRCROOT/get_bundle_version.rb`;
DESTPATH="$SRCROOT/../iKnowAndManage-""$BUNDLEVERSION";

mkdir "$DESTPATH";
# copy app and userguide
cp -r "$BUILD_DIR/$CONFIG/iKnow & Manage.app" "$DESTPATH/";
cp "$SRCROOT/docs/UserGuide/iKnowAndManage_UserGuide_en.pdf" "$DESTPATH/";
# create new update_ikam.plist
DMGARCHIVE="iKnowAndManage-$BUNDLEVERSION.dmg";
ZIPARCHIVE="$DMGARCHIVE"".zip";
# create disk image
echo "Destpath: $DESTPATH";
hdiutil create -srcfolder "$DESTPATH" "$SRCROOT/../$DMGARCHIVE";
sleep 2;
# zip it
cd "$SRCROOT/..";
zip "$ZIPARCHIVE" "$DMGARCHIVE";

exit 0
