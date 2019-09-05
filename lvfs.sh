#!/usr/bin/env bash

set -e

NAMESPACE="USB\VID_1209&PID_1776&REV_0001"
echo "NAMESPACE: ${NAMESPACE}"

UUID="$(appstream-util generate-guid "${NAMESPACE}")"
echo "UUID: ${UUID}"

#TODO: Should --dirty be used?
REVISION="$(git describe --tags)"
echo "REVISION: ${REVISION}"

DATE="$(git show -s --format="%ci" "$REVISION" | cut -d " " -f 1)"
echo "DATE: ${DATE}"

NAME="thelio-io_${REVISION}"
echo "NAME: ${NAME}"

SOURCE="https://github.com/system76/thelio-io-firmware/releases/tag/${REVISION}"
echo "SOURCE: ${SOURCE}"

BUILD="build/lvfs/${NAME}"
echo "BUILD: ${BUILD}"

rm -rf "${BUILD}"
mkdir -pv "${BUILD}"

cp -v "build/atmega32u4/main.hex" "${BUILD}/firmware.hex"

echo "writing '${BUILD}/firmware.metainfo.xml'"
cat > "${BUILD}/firmware.metainfo.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright 2019 System76 <info@system76.com> -->
<component type="firmware">
  <id>com.system76.ThelioIo.firmware</id>
  <name>Thelio Io</name>
  <summary>Firmware for the System76 Thelio Io</summary>
  <description>
    <p>
      The System76 Thelio Io firmware provides fan and power button control
      for System76 Thelio systems. There is additional drive backplane
      functionality that is not controlled by firmware.
    </p>
  </description>
  <provides>
    <!-- ${NAMESPACE} -->
    <firmware type="flashed">${UUID}</firmware>
  </provides>
  <url type="homepage">https://github.com/system76/thelio-io</url>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>GPL-3.0+</project_license>
  <developer_name>System76</developer_name>
  <releases>
    <release urgency="high" version="${REVISION}" date="${DATE}" install_duration="15">
      <checksum filename="firmware.hex" target="content"/>
      <url type="source">${SOURCE}</url>
      <description>
        <p>This release enables the REVISION command</p>
      </description>
    </release>
  </releases>
  <categories>
    <category>X-Device</category>
  </categories>
  <requires>
    <!-- TODO -->
    <id compare="ge" version="1.2.9">org.freedesktop.fwupd</id>
  </requires>
  <keywords>
    <keyword>dfu</keyword>
  </keywords>
  <custom>
    <value key="LVFS::UpdateProtocol">org.usb.dfu</value>
  </custom>
</component>
EOF

gcab \
    --verbose \
    --create \
    --nopath \
    "${BUILD}.cab" \
    "${BUILD}/"*

echo "created '${BUILD}.cab'"