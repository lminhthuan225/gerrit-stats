#!/bin/bash

source $LEGATO_SCRIPT_PATH/common.sh
REPO_NAME="gerrit-stats"

message $COLOR_INFO "Saving artifacts"
if [ -z "$ARTIFACT_PATH" ]; then
    message $COLOR_WARN "No ARTIFACT_PATH specified, discarding results"
    exit 0
fi

STATIC_DIR="$WORKSPACE/$REPO_NAME/GerritStats/out-html"

if [[ -e "$STATIC_DIR" ]]; then
    cd "$STATIC_DIR"
fi

VERSION=$(git describe --tags)
ARTIFACT_PATH=$(echo $ARTIFACT_PATH | sed "s/VERSION/$VERSION/g")
echo $ARTIFACT_PATH

message $COLOR_INFO "Artifacts to be stored in '$ARTIFACT_PATH'"
mkdir -p $ARTIFACT_PATH/data
chmod go+r -R $STATIC_DIR

copy_ui_file() {
    if [[ $(ls $WORKSPACE/ui | wc -l) == 0 ]]; then
        for file in $(ls $STATIC_DIR); do
            if [ -e "$ARTIFACT_PATH/$file" ]; then
                rm -f $ARTIFACT_PATH/$file
            fi
            cp $STATIC_DIR/$file $ARTIFACT_PATH/$file
        done
    else 
        for file in $(ls $WORKSPACE/ui); do
            if [ -e "$ARTIFACT_PATH/$file" ]; then
                rm -f $ARTIFACT_PATH/$file
            fi
            cp $WORKSPACE/ui/$file $ARTIFACT_PATH/$file
        done
    fi
}

if [[ "$TYPE_OF_UPDATE" == "data" ]]; then
    for file in $(ls $STATIC_DIR/data); do
        # Remove old content
        if [[ -e "$ARTIFACT_PATH/data/$file" ]]; then
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



