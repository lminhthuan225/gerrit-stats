#!/bin/bash

source $LEGATO_SCRIPT_PATH/common.sh
REPO_NAME="gerrit-stats"

message $COLOR_INFO "Saving artifacts"
if [ -z "$ARTIFACT_PATH" ]; then
    message $COLOR_WARN "No ARTIFACT_PATH specified, discarding results"
    exit 1
fi

STATIC_DIR="$WORKSPACE/$REPO_NAME/GerritStats/out-html"

cd "$STATIC_DIR" || (
  echo "Folder $REPO_NAME does not exist in this workspace($WORKSPACE)"
  exit 1
)

# VERSION=$(git describe --tags)
# ARTIFACT_PATH=$(echo $ARTIFACT_PATH | sed "s/VERSION/$VERSION/g")
echo $ARTIFACT_PATH

message $COLOR_INFO "Artifacts to be stored in '$ARTIFACT_PATH'"
mkdir -p $ARTIFACT_PATH/data
chmod go+r -R $STATIC_DIR


remove_old_artifact_and_copy_new_artifact() {
    local folder=${1-}
    
    for file in $(ls $folder); do
        if [ -e "$ARTIFACT_PATH/$file" ]; then
            rm -f $ARTIFACT_PATH/$file
        fi
        cp $folder/$file $ARTIFACT_PATH/$file
    done
}

copy_ui_file() {
    if [[ $(ls $WORKSPACE/ui | wc -l) == 0 ]]; then
        remove_old_artifact_and_copy_new_artifact $STATIC_DIR
    else 
        remove_old_artifact_and_copy_new_artifact $WORKSPACE/ui
    fi
}

if [[ "$TYPE_OF_UPDATE" == "data" ]]; then
    for file in $(ls $STATIC_DIR/data); do
        # Remove old content
        if [[ -d "$ARTIFACT_PATH/data/$file" ]]; then
            echo "Removing old data, project: $file"
            rm -rf $ARTIFACT_PATH/data/$file
        fi
        echo "Copying to artifact folder, project: $file"
        cp -Rf $STATIC_DIR/data/$file $ARTIFACT_PATH/data/$file
    done

    if [[ ! -e "$ARTIFACT_PATH/index.html" || ! -e "$ARTIFACT_PATH/bundle.js" ]]; then 
        copy_ui_file
    fi
fi

if [[ "$TYPE_OF_UPDATE" == "ui" ]]; then
    copy_ui_file
fi



