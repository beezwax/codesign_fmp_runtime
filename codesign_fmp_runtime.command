#!/bin/bash

# 2015-01-02 simon_b: now check for Icon? file
# 2015-01-02 simon_b: now check framework folders before trying to sign to help with debugging
# 2015-01-02 simon_b: rm's now forced for all cases where file/older may not pre-exist


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

# fix the frameworks
# rm commands to make sure we recreate things correctly.
cd Frameworks/

if [ -d "DBEngine.framework" ]; then
	cd DBEngine.framework
	rm -Rfv _CodeSignature
	rm -f DBEngine
	rm -f Resources
	##ln -s Versions/A/Resources Resources
	ln -s Versions/A/DBEngine DBEngine
	ln -s A Versions/Current
	cd ..
fi

if [ -d FMEngine.framework ]; then
	cd FMEngine.framework
	rm -Rfv _CodeSignature
	rm -f FMEngine
	rm -f Resources
	ln -s Versions/A/Resources Resources
	ln -s Versions/A/FMEngine FMEngine
	ln -s A Versions/Current
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
	ln -s A Versions/Current
	cd ..
fi

if [ -d OmniORB4.framework ]; then
	cd OmniORB4.framework
	rm -Rfv _CodeSignature
	rm -f OmniORB4
	rm -f Resources
	ln -s Versions/A/Resources Resources
	ln -s Versions/A/OmniORB4 OmniORB4
	ln -s A Versions/Current
	cd ..
fi

if [ -d OpenSSL.framework ]; then
	cd OpenSSL.framework
	rm -Rfv _CodeSignature
	rm -f OpenSSL
	rm -f Resources
	ln -s Versions/A/Resources Resources
	ln -s Versions/A/OpenSSL OpenSSL
	ln -s A Versions/Current
	cd ..
fi

if [ -d Support.framework ]; then
	cd Support.framework
	rm -Rfv _CodeSignature
	rm -f Resources
	rm -f Support
	ln -s Versions/A/Resources Resources
	ln -s Versions/A/Support Support
	ln -s A Versions/Current
	cd ..
fi

# Exit if any errors.
##set -e

# now we sign all the parts
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

# Verify that we are really done.

echo
echo "Verify codesign is complete"
codesign --verify --verbose "$appPath"

echo
echo "Check that app is now accepted by sandboxing"
spctl -a -t exec -v "$appPath"
