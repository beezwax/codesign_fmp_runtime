#!/bin/bash

# 2015-01-02 simon_b: now check for Icon? file
# 2015-01-02 simon_b: now check framework folders before trying to sign to help with debugging
# 2015-01-02 simon_b: rm's now forced for all cases where file/older may not pre-exist
# 2017-07-28 simon_b: added -f for some ln's in case script was previously stopped partly through signing

# Verbose & expand variables
#set -x

# Show commands being executed
#set -o verbose

# Stop for most errors.
set -e

# Below should be the same as Common Name, which is typically your org name with a prefix,
# ie: "Developer ID Application: My Organization Name, Inc." 

devID="Developer ID Application: YOUR ORG NAME HERE"

# This is the path to the runtime application to be signed:
appPath="/Users/simon_b/runtime/YourRuntime.app"

# Special characters like spaces need to be escaped in paths. e.g. space character gets a backslash before the space.

cd "$appPath"

# If this is present it will cause the code signing to fail.
rm -f "Icon^M"

cd Contents
rm -Rfv _CodeSignature

# FIX FRAMEWORKS

# Frameworks have a required format for code signing that the runtime does not include.
# Also rm out previous codesigning to make sure we recreate things correctly and with our own certificate.

cd Frameworks/

if [ -d "DBEngine.framework" ]; then
	cd DBEngine.framework
	rm -Rfv _CodeSignature
	rm -f DBEngine
	rm -f Resources
	##ln -s Versions/A/Resources Resources
	ln -s Versions/A/DBEngine DBEngine
	ln -fs A Versions/Current
	cd ..
fi

if [ -d FMEngine.framework ]; then
	cd FMEngine.framework
	rm -Rfv _CodeSignature
	rm -f FMEngine
	rm -f Resources
	ln -s Versions/A/Resources Resources
	ln -s Versions/A/FMEngine FMEngine
	ln -fs A Versions/Current
	cd ..
fi

if [ -d FMWrapper.framework ]; then
	cd FMWrapper.framework
	rm -Rfv _CodeSignature
	rm -f FMWrapper
	rm -f Resources
	rm -rf Versions/A/Headers
	ln -s Versions/A/Resources Resources
	ln -s Versions/A/FMWrapper FMWrapper
	ln -fs A Versions/Current
	cd ..
fi

if [ -d OmniORB4.framework ]; then
	cd OmniORB4.framework
	rm -Rfv _CodeSignature
	rm -f OmniORB4
	rm -f Resources
	ln -s Versions/A/Resources Resources
	ln -s Versions/A/OmniORB4 OmniORB4
	ln -fs A Versions/Current
	cd ..
fi

if [ -d OpenSSL.framework ]; then
	cd OpenSSL.framework
	rm -Rfv _CodeSignature
	rm -f OpenSSL
	rm -f Resources
	ln -s Versions/A/Resources Resources
	ln -s Versions/A/OpenSSL OpenSSL
	ln -fs A Versions/Current
	cd ..
fi

if [ -d Support.framework ]; then
	cd Support.framework
	rm -Rfv _CodeSignature
	rm -f Resources
	rm -f Support
	ln -s Versions/A/Resources Resources
	ln -s Versions/A/Support Support
	ln -fs A Versions/Current
	cd ..
fi

# SIGN ALL THE RUNTIME COMPONENTS

# Each included framework must be signed. We could've used the --deep option instead, but Apple docs
# say that its better to do this explicitly. This also means we won't codesign anything inadvertently
# included in our runtime, or some new component in a future FileMaker version.

cd "$appPath"

codesign -f -vvvv -s "$devID" Contents/Frameworks/DBEngine.framework/Versions/A
codesign -f -vvvv -s "$devID" Contents/Frameworks/FMEngine.framework/Versions/A
codesign -f -vvvv -s "$devID" Contents/Frameworks/FMWrapper.framework/Versions/A
codesign -f -vvvv -s "$devID" Contents/Frameworks/OmniORB4.framework/Versions/A
codesign -f -vvvv -s "$devID" Contents/Frameworks/OpenSSL.framework/Versions/A
codesign -f -vvvv -s "$devID" Contents/Frameworks/Support.framework/Versions/A
codesign -f -vvvv -s "$devID" Contents/Frameworks/*.dylib
codesign -f -vvvv -s "$devID" Contents/XPCServices/*.xpc
#codesign -f -vvvv -s "$devID" --entitlements "$appPath"/../../entitlements.plist Contents/MacOS/Runtime
codesign -f -vvvv -s "$devID" Contents/MacOS/Runtime

cd ..

echo
pwd
ls "$appPath"/../../
echo

##codesign -f -vvvv -s "$devID" --entitlements "$appPath"/../../entitlements.plist .

# Apple docs say the you should avoid using the --deep option, and instead rely on the discrete calls above.
#codesign -f --deep -vvvv -s "$devID" "$appPath"

# VERIFY CODE SIGNING

# Verify that we are really done.

echo
echo "Verify codesign is complete"
codesign --verify --verbose "$appPath"

echo
echo "Check that app is now accepted by sandboxing"
spctl -a -t exec -v "$appPath"

echo "DONE"
