#!/bin/bash

# source $LEGATO_SCRIPT_PATH/common.sh
REPO_NAME="gerrit-stats"

echo "Saving artifacts"
# message $COLOR_INFO "Saving artifacts"
if [ -z "$ARTIFACT_PATH" ]; then
    echo "No ARTIFACT_PATH specified, discarding results"
    # message $COLOR_WARN "No ARTIFACT_PATH specified, discarding results"
    exit 0
fi

STATIC_DIR="$WORKSPACE/$REPO_NAME/GerritStats/out-html"

if [[ -e "$STATIC_DIR" ]]; then
    cd "$STATIC_DIR"
fi

VERSION=$(git describe --tags)
echo $VERSION
ARTIFACT_PATH=$(echo $ARTIFACT_PATH | sed "s/VERSION/$VERSION/g")

echo "Artifacts to be stored in '$ARTIFACT_PATH'"
# message $COLOR_INFO "Artifacts to be stored in '$ARTIFACT_PATH'"
mkdir -p $ARTIFACT_PATH
chmod go+r -R $STATIC_DIR

if [[ "$UPDATE_DATA" == "true" ]]; then
    for obj in $(ls -1 $STATIC_DIR/data); do
        # Remove old content
        if [ -e "$ARTIFACT_PATH/data/$obj" ]; then
            rm -rf $ARTIFACT_PATH/data/$obj
        fi
        cp -Rf $STATIC_DIR/data/$obj $ARTIFACT_PATH/data/$obj
    done
fi

if [[ "$UPDATE_UI" == "true" ]]; then
    for obj in $(ls -1 $STATIC_DIR); do
        if [[ "$obj" == "data" ]]; then
            continue
        fi
        # Remove old content
        if [ -e "$ARTIFACT_PATH/$obj" ]; then
            rm -rf $ARTIFACT_PATH/$obj
        fi
        echo $ARTIFACT_PATH/$obj
        cp -Rf $STATIC_DIR/$obj $ARTIFACT_PATH/$obj
    done
fi



