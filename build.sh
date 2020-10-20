#!/usr/bin/env bash

set -xeu
set -o pipefail

function finish() {
  ditto -c -k --sequesterRsrc --keepParent "${RESULT_BUNDLE_PATH}" "${RESULT_BUNDLE_PATH}.zip"
  rm -rf "${RESULT_BUNDLE_PATH}"
}

trap finish EXIT

export OPASS_MAIN_VERSION=3.0
export OPASS_GIT_VERSION=$(git rev-parse --short HEAD)
export OPASS_GIT_COMMITS=$(($(git rev-list --all --count) + 1))
export OPASS_VERSION="${OPASS_MAIN_VERSION}.${OPASS_GIT_COMMITS}"
export OPASS_VERSION_PREFERENCE="${OPASS_VERSION} #${OPASS_GIT_VERSION}"
export OPASS_BUILD_TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S GMT+8")
export OPASS_PROFILE_UDID=$(echo "$OPASS_PROVISIONING_PROFILES" | jq -r '.[].udid')
export OPASS_WILDCARD_PROFILE_UDID=$(echo "$OPASS_WILDCARD_PROVISIONING_PROFILES" | jq -r '.[].udid')

SDK="${SDK:-iphoneos}"
WORKSPACE="${WORKSPACE:-OPass.xcworkspace}"
SCHEME="${SCHEME:-OPass}"
CONFIGURATION=${CONFIGURATION:-Release}

BUILD_DIR=${BUILD_DIR:-.build}
ARTIFACT_PATH=${RESULT_PATH:-${BUILD_DIR}/Artifacts}
RESULT_BUNDLE_PATH="${ARTIFACT_PATH}/${SCHEME}.xcresult"
ARCHIVE_PATH=${ARCHIVE_PATH:-${BUILD_DIR}/Archives/${SCHEME}.xcarchive}
DERIVED_DATA_PATH=${DERIVED_DATA_PATH:-${BUILD_DIR}/DerivedData}
EXPORT_OPTIONS_FILE="ExportOptions.plist"

rm -rf "${RESULT_BUNDLE_PATH}"

xcrun xcodebuild \
    -workspace "${WORKSPACE}" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -sdk "${SDK}" \
    -parallelizeTargets \
    -showBuildTimingSummary \
    -disableAutomaticPackageResolution \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -archivePath "${ARCHIVE_PATH}" \
    -resultBundlePath "${RESULT_BUNDLE_PATH}" \
    MAIN_BUILD_VERSION="${OPASS_VERSION}" \
    MAIN_BUILD_SHORT_VERSION="${OPASS_VERSION}" \
    OPASS_VERSION="${OPASS_VERSION}" \
    OPASS_VERSION_PREFERENCE="${OPASS_VERSION_PREFERENCE}" \
    OPASS_BUILD_TIMESTAMP="${OPASS_BUILD_TIMESTAMP}" \
    archive

xcrun xcodebuild \
    -exportArchive \
    -exportOptionsPlist "${EXPORT_OPTIONS_FILE}" \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${ARTIFACT_PATH}/${SCHEME}.app"

# Zip up the Xcode Archive into Artifacts folder.
ditto -c -k --sequesterRsrc --keepParent "${ARCHIVE_PATH}" "${ARTIFACT_PATH}/${SCHEME}.xcarchive.zip"
