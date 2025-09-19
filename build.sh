#!/bin/bash

set -e

if test -f key.properties; then
    keypath="$(pwd)/key.properties"
elif test -f ../key.properties; then
    keypath="../key.properties"
elif test -f ../../key.properties; then
    keypath="../../key.properties"
elif test -f ~/key.properties; then
    keypath="~/key.properties"
else
    read -p "Full path to key.properties: " keypath
    if ! test -f $keypath; then
        echo "File does not exist."
        exit 1
    fi

fi
echo "Found key.properties!"

git submodule update
read -p "Number to build: " count

export PUB_CACHE=$(pwd)/.pub-cache
export PATH=$PATH:.flutter/bin

flutter config --no-analytics
flutter pub get

rm -f android/key.properties
ln -s $keypath android/key.properties
rm -rf output
mkdir output

for i in $(seq 1 $count); do
    ir=$(($i % 9))
    echo "Building number $i"
    cp assets/icons/$ir/icon.png assets/icon/
    dart run rename setAppName --value "Worktest $i"
    dart run rename setBundleId --value "dev.lojcs.worktest.v$i"
    dart run flutter_launcher_icons
    flutter build apk --release --split-per-abi
    mv build/app/outputs/flutter-apk/app-arm64-v8a-release.apk output/Worktest-$i-arm64-v8a.apk
done

rm android/key.properties