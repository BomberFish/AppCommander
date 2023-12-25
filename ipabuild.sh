#!/bin/bash

set -e

cd "$(dirname "$0")"

WORKING_LOCATION="$(pwd)"
APPLICATION_NAME=AppCommander
PLATFORM=iOS
SDK=iphoneos
if [[ $* == *--debug* ]]; then
    TARGET=Debug
else
    TARGET=Release
fi

if [[ $* == *--clean* ]]; then
    echo "[*] Deleting previous packages..."
    rm -rf "build/$APPLICATION_NAME.ipa"
    rm -rf "build/$APPLICATION_NAME.tipa"
fi

if [[ $* == *--deepclean* ]]; then
    echo "[*] Deleting build folder..."
    rm -rf "build"
fi

echo "[*] Building $APPLICATION_NAME ($TARGET)..."

if [ ! -d "build" ]; then
    mkdir build
fi

cd build

xcodebuild -project "$WORKING_LOCATION/$APPLICATION_NAME.xcodeproj" \
    -scheme "$APPLICATION_NAME" \
    -configuration "$TARGET" \
    -derivedDataPath "$WORKING_LOCATION/build/DerivedDataApp" \
    -destination "generic/platform=$PLATFORM" \
    clean build \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO"

DD_APP_PATH="$WORKING_LOCATION/build/DerivedDataApp/Build/Products/"$TARGET"-$SDK/$APPLICATION_NAME.app"
TARGET_APP="$WORKING_LOCATION/build/$APPLICATION_NAME.app"
cp -r "$DD_APP_PATH" "$TARGET_APP"

echo "[*] Removing code signature"
codesign --remove "$TARGET_APP"
if [ -e "$TARGET_APP/_CodeSignature" ]; then
    rm -rf "$TARGET_APP/_CodeSignature"
fi
if [ -e "$TARGET_APP/embedded.mobileprovision" ]; then
    rm -rf "$TARGET_APP/embedded.mobileprovision"
fi

# Add entitlements
echo "[*] Adding entitlements"
ldid -S"$WORKING_LOCATION/$APPLICATION_NAME/$APPLICATION_NAME.entitlements" "$TARGET_APP/$APPLICATION_NAME"

#echo "[*] Building RootHelper..."
#cd $WORKING_LOCATION/RootHelper
#if ! type "gmake" > /dev/null; then
#    echo "[!] gmake not found, using macOS bundled make instead"
#    make clean
#    if [[ $* == *--debug* ]]; then
#    make
#    else
#    make FINALPACKAGE=1
#    fi
#else
#    gmake clean
#    if [[ $* == *--debug* ]]; then
#    gmake -j"$(sysctl -n machdep.cpu.thread_count)"
#    else
#    gmake -j"$(sysctl -n machdep.cpu.thread_count)" FINALPACKAGE=1
#    fi
#fi
#cp "$WORKING_LOCATION/RootHelper/.theos/obj/debug/RootHelper" "$TARGET_APP/roothelper"
#cd -

echo "[*] Packaging..."
mkdir Payload
cp -r $APPLICATION_NAME.app Payload/$APPLICATION_NAME.app

if [[ $* != *--debug* ]]; then
strip Payload/$APPLICATION_NAME.app/$APPLICATION_NAME
fi

zip -vr $APPLICATION_NAME.tipa Payload
rm -rf $APPLICATION_NAME.app
rm -rf Payload

