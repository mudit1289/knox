#!/bin/bash -ex

PACKAGE=__PACKAGE__
REPO_NAME=__ENV__-${PACKAGE}
ENV_NAME=${REPO_NAME}-env
ENV_DEF_SKELETON_FILE=${PACKAGE}-envdef

REPO_URL=`reposervice --host 10.24.0.41 --port 8080 pub --repo ${REPO_NAME} --appkey ${PACKAGE} --debs ${PACKAGE}.deb`
if [ $? -eq 0 ] ; then
  CURRENT_VERSION=`echo $REPO_URL | grep -oe "\([0-9]\+\)$"`
  TMP_FILE=`tempfile`
  sed -e "s/__REPO_VERSION__/$((CURRENT_VERSION))/g" ${ENV_DEF_SKELETON_FILE} > $TMP_FILE
  reposervice --host 10.24.0.41 --port 8080 penv --name ${ENV_NAME} --appkey ${PACKAGE} --envdef $TMP_FILE --debug true
else
  echo "Could not update the repo service with debian package" && exit 1
fi
