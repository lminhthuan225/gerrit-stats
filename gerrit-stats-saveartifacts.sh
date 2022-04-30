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

# message $COLOR_INFO "Artifacts to be stored in '$ARTIFACT_PATH'"
# mkdir -p $ARTIFACT_PATH
# chmod go+r -R $STATIC_DIR

# if [[ "$TYPE_OF_UPDATE" == "data" ]]; then
#     for obj in $(ls -1 $STATIC_DIR/data); do
#         # Remove old content
#         if [ -e "$ARTIFACT_PATH/data/$obj" ]; then
#             rm -rf $ARTIFACT_PATH/data/$obj
#         fi
#         cp -Rf $STATIC_DIR/data/$obj $ARTIFACT_PATH/data/$obj
#     done
# fi

# if [[ "$TYPE_OF_UPDATE" == "ui" ]]; then
#     for file in $(ls $WORKSPACE/ui/$VERSION); do
#         if [[ "$file" == "data" ]]; then
#             continue
#         else 
#             if [ -e "$ARTIFACT_PATH/$file" ]; then
#                 # rm -f $ARTIFACT_PATH/$file
#             fi
#             cp $STATIC_DIR/$file $ARTIFACT_PATH/$file
#         fi
#     done
# fi



