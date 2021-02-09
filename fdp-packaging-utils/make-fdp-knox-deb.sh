#!/usr/bin/env bash

function die()
{
        echo "Error: $1" >&2
        exit 1
}

[ -z "$LOCAL_DIR" ] && die "No LOCAL_DIR specified"
[ -z "$ENV" ] && die "No ENV specified"
[ -z "$MODULE" ] && die "No MODULE specified"

PACKAGE_SUFFIX=""

case "$MODULE" in
        gateway-release) PACKAGE_SUFFIX="gateway";;
esac

[ -z "PACKAGE_SUFFIX" ] && die "MODULE ${MODULE} is not supported. Supported MODULE(s) are: gateway-release"
[ ! -d "$LOCAL_DIR" ] && die "$LOCAL_DIR does not exist"


PACKAGE=fdp-knox-${PACKAGE_SUFFIX}
DEB_DIR="${LOCAL_DIR}"/packaging

[ ! -d "$DEB_DIR" ] && mkdir "$DEB_DIR"

mkdir -p "${DEB_DIR}"/usr/share/${PACKAGE}
mkdir -p "${DEB_DIR}"/usr/lib/${PACKAGE}

echo "BUILDING ${PACKAGE}"
mvn -Ppackage,release -Drat.ignoreErrors=true -DskipTests -pl ${MODULE} clean package

echo "Copying zip"

cp ${LOCAL_DIR}/src/target/1.5.0/knox-1.5.0.zip "${DEB_DIR}"/usr/share/${PACKAGE}/

TIMESTAMP=$(date +%s)
VERSION="fk-1.5.0-${BUILD_NUMBER}-${TIMESTAMP}"

echo "Setting params, ENV as ${ENV}, PACKAGE as ${PACKAGE}, VERSION as ${VERSION}, MODULE as ${MODULE}"

sed -i "s/__ENV__/${ENV}/g" "${DEB_DIR}"/*
sed -i "s/__PACKAGE__/${PACKAGE}/g" "${DEB_DIR}"/*
sed -i "s/__VERSION__/${VERSION}/g" "${DEB_DIR}"/*
sed -i "s/__MODULE__/${MODULE}/g" "${DEB_DIR}"/*

sed -i "s/__PACKAGE__/${PACKAGE}/g" "${DEB_DIR}"/usr/share/${PACKAGE}/health_check.sh

sed -i "s/__ENV__/${ENV}/g" "${LOCAL_DIR}"/fdp-packaging-utils/*
sed -i "s/__PACKAGE__/${PACKAGE}/g" "${LOCAL_DIR}"/fdp-packaging-utils/*
sed -i "s/__VERSION__/${VERSION}/g" "${LOCAL_DIR}"/fdp-packaging-utils/*

chmod -R 775 deb
dpkg-deb -b deb ${PACKAGE}.deb