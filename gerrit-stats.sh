#!/bin/bash

REPO_NAME="gerrit-stats"
WORK_DIR="$WORKSPACE/$REPO_NAME"

#clean work dir
if [[ -d "$WORK_DIR" ]]; then
  rm -rf "$WORK_DIR"
fi

#check out source code
git clone https://github.com/lminhthuan225/$REPO_NAME.git

cd $WORK_DIR || (
  echo "Folder $REPO_NAME does not exist."
  exit 1
)

if [[ "$UPDATE_DATA" == "true" ]]; then
    echo "Downloading json data..."
    ./gerrit_downloader.sh \
      -s carmd-ev-lxcim_sa@gerrit.dev.legato \
      -i /storage/services/credentials/CARMD-EV-LXCIM_sa/id_rsa \
      -o json-storage

    if [[ ! -d "$WORK_DIR/json-storage" ]]; then
      echo "There is no json file to generate stats"
      exit 0
    fi

    echo "Generating stats for all projects..."
    ./gerrit_stats.sh
fi

if [[ "$UPDATE_UI" == "true" ]]; then
  cd "GerritStats" || (
    echo "Folder GerritStats does not exist"
    exit 0
  )

  npm run webpack
fi


