#!/bin/bash

REPO_NAME="gerrit-stats"
WORK_DIR="$WORKSPACE/$REPO_NAME"

#if folder does not exist 
if [[ ! -d "$WORK_DIR" ]]; then
  git clone https://github.com/lminhthuan225/$REPO_NAME.git
fi

cd $WORK_DIR || (
  echo "Folder $REPO_NAME does not exist in this workspace($WORKSPACE)"
  exit 1
)

if [[ "$TYPE_OF_UPDATE" == "data" ]]; then
  if [[ "$SKIP_DOWNLOAD_STEP" == "false" ]]; then
    echo "Downloading json data..."
    ./gerrit_downloader.sh \
      -s carmd-ev-lxcim_sa@172.17.0.10 \
      -i /storage/services/credentials/CARMD-EV-LXCIM_sa/id_rsa \
      -o json-storage

    #back up json file
    rm -rf $WORKSPACE/json-storage
    mkdir -p $WORKSPACE/json-storage
    # now=$(date +'%d/%m/%Y')
    cp -r json-storage $WORKSPACE/json-storage
  fi

  if [[ ! -d "$WORK_DIR/json-storage" ]]; then
    echo "There is no json file to generate stats"
    exit 0
  fi

  echo "Generating stats for all projects..."
  ./gerrit_stats.sh
fi

VERSION=$(git describe --tags)
if [[ "$TYPE_OF_UPDATE" == "ui" ]]; then
  #retrive hash commit of before ui
  if [[ ! -d $WORKSPACE/ui/$VERSION ]]; then
    mkdir -p $WORKSPACE/ui/$VERSION
  fi

  cd $WORKSPACE/ui/$VERSION
  git clone \
    --depth 3 \
    --filter=blob:none \
    --no-checkout \
    https://github.com/lminhthuan225/$REPO_NAME.git
  cd $REPO_NAME
  git sparse-checkout set out-html
  # $WORKSPACE/new-ui/$REPO_NAME/Gerrit-Stats/out-html
fi


