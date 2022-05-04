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
    cp -r json-storage $WORKSPACE
  fi

  if [[ ! -d "$WORK_DIR/json-storage" ]]; then
    echo "There is no json file to generate stats"
    exit 1
  fi

  if [[ "$SKIP_GENERATE_STATS_STEP" == "false" ]]; then
    ./gerrit_stats.sh
  fi
fi

if [[ "$TYPE_OF_UPDATE" == "ui" ]]; then  
  STATIC_DIR="$WORK_DIR/GerritStats/out-html"
  cd $STATIC_DIR
  echo "Removing old ui..."
  for file in $(ls $(pwd)); do
      if [[ $file == "data" ]]; then
        continue
      else 
        rm -f $file
      fi
  done
  echo "Cloning new ui..."
  git fetch origin main
  git reset --hard FETCH_HEAD
  
  $WORK_DIR/rewrite_project_info.sh
  
  for file in $(ls $(pwd)); do
      if [[ $file == "data" ]]; then
        continue
      else 
        cp $file $WORKSPACE/ui/$file
      fi
  done
fi


