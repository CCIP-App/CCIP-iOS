export MAIN_VERSION=2.3

trim() {
    local var=$@
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}
settingBundle() {
    local keyValue=$1
    local value=$2
    _cnt=`/usr/libexec/PlistBuddy -c "Print PreferenceSpecifiers:" "$SETTINGS_FILE"|grep Dict|wc -l`
    for idx in `seq 0 $(($_cnt - 1))`; do
        # echo "the index is: $idx."
        val=`/usr/libexec/PlistBuddy -c "Print PreferenceSpecifiers:$idx:Key" "$SETTINGS_FILE"`
        val=`trim "$val"`;
        # echo "the value of PreferenceSpecifiers:${idx}:Key: is ${val}."

        if [ "$val" == "$keyValue" ]; then
            echo "the index of the entry whose 'Key' is '$keyValue' is $idx."
            # now set it
            /usr/libexec/PlistBuddy -c "Set PreferenceSpecifiers:$idx:DefaultValue $value" "$SETTINGS_FILE"

            # just to be sure that it worked
            ver=`/usr/libexec/PlistBuddy -c "Print PreferenceSpecifiers:$idx:DefaultValue" "$SETTINGS_FILE"`
            echo "PreferenceSpecifiers:$idx:DefaultValue set to: $ver"
        fi
    done
}
FLAG_ITEMS=0
settingFlagsDefine() {
    FLAG_ITEMS=$(($FLAG_ITEMS+1))
    /usr/libexec/PlistBuddy -c "Add :PreferenceSpecifiers:$FLAG_ITEMS:Type string ""PSTitleValueSpecifier""" "$APP_FLAGS_FILE"
    /usr/libexec/PlistBuddy -c "Add :PreferenceSpecifiers:$FLAG_ITEMS:Key string ""$1""" "$APP_FLAGS_FILE"
    /usr/libexec/PlistBuddy -c "Add :PreferenceSpecifiers:$FLAG_ITEMS:Title string ""$1""" "$APP_FLAGS_FILE"
    /usr/libexec/PlistBuddy -c "Add :PreferenceSpecifiers:$FLAG_ITEMS:DefaultValue string ""$2""" "$APP_FLAGS_FILE"
}
settingFlagsBundle() {
    /usr/libexec/PlistBuddy -c "Delete :PreferenceSpecifiers" "$APP_FLAGS_FILE"
    /usr/libexec/PlistBuddy -c "Delete :Title" "$APP_FLAGS_FILE"
    /usr/libexec/PlistBuddy -c "Add :PreferenceSpecifiers array" "$APP_FLAGS_FILE"
    /usr/libexec/PlistBuddy -c "Add :PreferenceSpecifiers:0 dict" "$APP_FLAGS_FILE"
    /usr/libexec/PlistBuddy -c "Add :PreferenceSpecifiers:0:Type string ""PSGroupSpecifier""" "$APP_FLAGS_FILE"
    /usr/libexec/PlistBuddy -c "Add :PreferenceSpecifiers:0:Title string ""Application Flags""" "$APP_FLAGS_FILE"
    until [ "$#" == "0" ]; do
        defineString=`echo $1 | sed -e 's/=/ /'`
        defineKey=`echo $defineString | awk '{print $1}'`
        defineValue=`echo $defineString | sed -e 's/'$defineKey' //'`
        settingFlagsDefine "$defineKey" "$defineValue";
        shift
    done
    /usr/libexec/PlistBuddy -c "Add :Title string ""SettingsTitle""" "$APP_FLAGS_FILE"
}
gitVersion=`git rev-parse --short HEAD`
buildVersion=`agvtool vers -terse`
cd "$PROJECT_DIR"
productVersion=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFOPLIST_FILE"`
productVersion="$MAIN_VERSION"
mainVersion="$productVersion.$buildVersion"
version="$mainVersion #$gitVersion"
flags=$GCC_PREPROCESSOR_DEFINITIONS
timeStamp=`date +"%Y-%m-%d %H:%M:%S GMT+8"`
SETTINGS_FILE=Settings.bundle/Root.plist
APP_FLAGS_FILE=Settings.bundle/AppFlags.plist

# /usr/libexec/PlistBuddy -c "set CFBundleVersion $version" "$INFOPLIST_FILE"

cd "Supporting Files"
settingBundle "version_preference" "$version $ARCHS";
settingBundle "build_timestamp" "$timeStamp";
settingFlagsBundle $flags;

cat CCIP.xcconfig > CCIP.debug.xcconfig
cat CCIP.xcconfig > CCIP.release.xcconfig

export CONF_NAME="`echo $TARGET_NAME | awk '{ print tolower($0) }'`"
export domain="$TARGET_NAME"
export mainDomain="coscup.org"
export mainStaffDomain="staff.$mainDomain"
export sponsorWebUrlBase=""
export sponsorWebUrl=""
export sponsorUseWeb=0
export staffWebUrlBase=""
export staffWebUrl=""
export staffUseWeb=0
export color_title_highlighted="#009a79"
export color_gradient1="#f9fea5"
export color_gradient2="#20e2d7"
export color_gradient3="#abf4b7"
export color_button_to="#2ce4d4"
export color_button_default="#3d983c"
export color_card_text="#009a79"
export color_label_text="#3d983c"
export color_navigation_bar_item="#3d983c"
export color_favorite_button="#50e3c2"

function replace_slash() {
    echo "$1" | sed -E 's$#$\\#$g' | sed -E 's#/#\\/#g'
}

function xcc_replace() {
    f=`replace_slash "$2"`
    r=`replace_slash "$3"`
    sed -i '' -E 's/'"$f"'/'"$r"'/g' CCIP.debug.xcconfig
    [[ "$1" -eq "0" ]] && sed -i '' -E 's/'"$f"'/'"$r"'/g' CCIP.release.xcconfig || sed -i '' -E 's/'"$f"'//g' CCIP.release.xcconfig
}

#xcc_replace 1 "#Dev#"                       "-Dev"
xcc_replace 1 "#Dev#"                       ""
xcc_replace 0 "#BUILD_VERSION#"             "$mainVersion"
xcc_replace 0 "#BUILD_SHORT_VERSION#"       "$productVersion"
xcc_replace 0 "#APP_NAME#"                  "$TARGET_NAME"
xcc_replace 0 "#define#"                    "$PREDEFINITIONS"
xcc_replace 0 "#domain#"                    "$domain"
xcc_replace 0 "#CONF_NAME#"                 "$CONF_NAME"
