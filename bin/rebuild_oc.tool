#!/bin/bash

efiBaseFiles=(
  "OpenCore.efi"
)

efiDrivers=(
  "OpenCanopy.efi"
  "AudioDxe.efi"
  "OpenLinuxBoot.efi"
  "ResetNvramEntry.efi"
  "ToggleSipEntry.efi"
  "OpenRuntime.efi"
  "EnableGop.efi"
  "EnableGopDirect.efi"
)

efiTools=(
  "OpenShell.efi"
  "BootKicker.efi"
)

remove_files() {
  dir=$1
  shift
  arr=("$@")
  for efiFile in "${arr[@]}"; do
    #echo rm "${OC_VOLUME_DIR}/EFI/OC${dir}/${efiFile}"
    rm "${OC_VOLUME_DIR}/EFI/OC${dir}/${efiFile}"
  done
}

copy_files() {
  dir=$1
  shift
  arr=("$@")
  for efiFile in "${arr[@]}"; do
    if [ "${efiFile}" = "OpenShell.efi" ]; then
      efiFile="Shell.efi"
    fi
    #echo cp "${BUILD_DIR}/${efiFile}" "${OC_VOLUME_DIR}/EFI/OC${dir}/${efiFile}"
    cp "${BUILD_DIR}/${efiFile}" "${OC_VOLUME_DIR}/EFI/OC${dir}/${efiFile}" || exit -1
  done
}

read OC_VER <<< $(grep OPEN_CORE_VERSION\ *\"[0-9]\.[0-9]\.[0-9]\" Include/Acidanthera/Library/OcMainLib.h | cut -d \" -f 2)

if [ "$OC_VER" == "" ]; then
  echo "Cannot extract OC version"
  exit -1
fi

echo "OpenCore $OC_VER"

TARGET="DEBUG"
ARCH="X64"
OC_VOLUME_DIR=/Volumes/OPENCORE

SKIP_BUILD=0

while true; do
  if [ "$1" == "--skip-build" ] || [ "$1" == "-s" ]; then
    SKIP_BUILD=1
    shift
  elif [ "$1" == "--ovmf" ] || [ "$1" == "-o" ]; then
    OC_VOLUME_DIR=~/OPENCORE
    TARGET="NOOPT"
    shift
  elif [ "$1" == "--dir" ] || [ "$1" == "-d" ]; then
    shift
    if [ "$1" != "" ]; then
      OC_VOLUME_DIR=$1
      shift
    else
      echo "No output dir specified" && exit 1
    fi
  else
    break
  fi
done

if ! [ -d $OC_VOLUME_DIR ]; then
  echo "Target dir ${OC_VOLUME_DIR} does not exist" && exit 1
fi

if [ "$1" != "" ]; then
  TARGET=$1
  shift
fi

if [ "$1" != "" ]; then
  ARCH=$1
  shift
fi

eval "$(git status | grep "On branch" | awk -F '[ ]' '{print "MY_BRANCH=" $3}')"

if [ "$MY_BRANCH" = "" ]; then
  eval "$(git status | grep "HEAD detached at" | awk -F '[ ]' '{print "MY_BRANCH=" $4}')"
  if [ "$MY_BRANCH" = "" ]; then
    echo "Not on any git branch or tag!"
    exit 1
  fi
fi

BUILD_DIR="./UDK/Build/OpenCorePkg/${TARGET}_XCODE5/${ARCH}"

BASE=OpenCore-${OC_VER}-${TARGET}
VER_ZIP_FILE=~/OC/${BASE}-${MY_BRANCH}.zip
ZIP_FILE=~/OC/${BASE}.zip
UNZIP_DIR=~/OC/${BASE}

if [ ! -f $VER_ZIP_FILE ]; then
  echo "Cannot find ${VER_ZIP_FILE}, using 'rebuild_all -s' ..."
  echo
  # does not matter if -s is repeated
  ./rebuild_all.tool -s $@ || exit 1
  echo
elif diff -q ${VER_ZIP_FILE} ${ZIP_FILE} &>/dev/null; then
  >&2 echo "Zip is correct for ${MY_BRANCH} ${TARGET}."
else
  >&2 echo "Zip is not correct for ${MY_BRANCH} ${TARGET}."
  >&2 echo "Removing non-matching unzipped dir..."
  rm -rf $UNZIP_DIR || exit 1

  echo "Copying ${BASE}-${MY_BRANCH}.zip to ${BASE}.zip..."
  cp ${VER_ZIP_FILE} ${ZIP_FILE} || exit 1

  echo "Unzipping..."
  unzip ${ZIP_FILE} -d ${UNZIP_DIR} 1>/dev/null || exit 1

  echo "Copying ${MY_BRANCH} ${TARGET} files to ${OC_VOLUME_DIR}..."
  cp -r ${UNZIP_DIR}/${ARCH}/EFI ${OC_VOLUME_DIR} || exit 1
fi

# Remove files we will rebuild.
printf 'Removing %s' "${efiBaseFiles[@]}"
printf ', %s' "${efiDrivers[@]}"
printf ', %s' "${efiTools[@]}"
printf " from ${OC_VOLUME_DIR}...\n"

remove_files '' ${efiBaseFiles[@]}
remove_files '/Drivers' ${efiDrivers[@]}
remove_files '/Tools' ${efiTools[@]}

if [ "$SKIP_BUILD" != "1" ]; then
  # rebuild them
  echo "Rebuilding..."
  cd ./UDK
  source edksetup.sh BaseTools || exit 1
  build -a ${ARCH} -b ${TARGET} -t XCODE5 -p OpenCorePkg/OpenCorePkg.dsc || exit 1
  cd ..
fi

# put them back
printf "Copying ${MY_BRANCH} ${TARGET} "
printf '%s' "${efiBaseFiles[@]}"
printf ', %s' "${efiDrivers[@]}"
printf ', %s' "${efiTools[@]}"
printf " to ${OC_VOLUME_DIR}...\n"

copy_files '' ${efiBaseFiles[@]}
copy_files '/Drivers' ${efiDrivers[@]}
copy_files '/Tools' ${efiTools[@]}

if [ -f "${OC_VOLUME_DIR}/EFI/OC/Tools/Shell.efi" ]; then
  mv "${OC_VOLUME_DIR}/EFI/OC/Tools/Shell.efi" "${OC_VOLUME_DIR}/EFI/OC/Tools/OpenShell.efi" || exit -1
fi

echo "Done."
