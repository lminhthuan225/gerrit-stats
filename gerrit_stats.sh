#!/bin/bash

set -eo pipefail

DATA_OUTPUT_DIR="GerritStats/out-html/data"
JAR_PATH="GerritStats/build/libs/GerritStats.jar"
PROJECT_INFO_PATH="GerritStats/src/main/frontend/projects.js"

JSON_DIR=json-storage
PROJECTS=$(ls $JSON_DIR | grep -e '.json$' | cut -d "." -f 1)
HASH_CODE="487fd0a6850bc56e1ec548072aaa2412f32323c7059a0d00144e013f4930c77f"

join_by() {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

remove_null_line() {
    local FILE_PATH=${1-}

    #format original json file
    jq '.' $FILE_PATH.json > ${FILE_PATH}_temp.json

    #replace null | null, by empty character
    sed -e 's/^[ ]*null,//g' -e 's/^[ ]*null//g' -i ${FILE_PATH}_temp.json

    mv ${FILE_PATH}_temp.json $FILE_PATH.json
}

#clean old data
clean_old_data() {
    rm -rf $DATA_OUTPUT_DIR
}
lk
#generate data for all projects in json folder
generate_stats() {
    echo "Cleaning old data..."
    clean_old_data
    for project in $PROJECTS
    do
        if [[ -s "$JSON_DIR/$project.json" ]]; then
            echo "Checking null line in json file:  $project.json"
            remove_null_line "$JSON_DIR/$project"
            java -Xmx4096m -Xms256m \
                -jar $JAR_PATH \
                -o $DATA_OUTPUT_DIR/$project \
                --file $JSON_DIR/$project.json || exit 1
        else
            echo "Skip empty json file: $project.json"
        fi
    done
    generate_project_info
}

PROJECT_INFO=""
generate_project_info() {
    echo "Generating all projects information..."
    for project in $PROJECTS
    do
        OVERVIEW_PATH=$DATA_OUTPUT_DIR/$project/overview.js
        DATASET_OVERVIEW_PATH=$DATA_OUTPUT_DIR/$project/datasetOverview.js

        if [[ -s "$OVERVIEW_PATH" && -s "$DATASET_OVERVIEW_PATH" ]]; then
            OV_FILE_CONTENT=$(cat $OVERVIEW_PATH | cut -d "=" -f2 | sed -e 's/\;//g' -e '/identity/d' | jq '.[] | {identifier: .identifier, commitCount: .commitCount}' | sed 's/\}/\},/g' | tr '\n' ' ' | sed 's/ //g')
            DS_FILE_CONTENT=$(cat $DATASET_OVERVIEW_PATH | cut -d "=" -f2 | sed -e 's/\;//g' -e '/identity/d' | jq '. | {fromDate: .fromDate, toDate: .toDate}' | sed 's/\}/\},/g' | tr '\n' ' ' | sed 's/ //g')

            PROJECT_INFO+=" {name:\"$project\",overviewUserdata:[$OV_FILE_CONTENT],datasetOverview:$DS_FILE_CONTENT}"
        fi
    done
    rewrite_project_info
}

rewrite_project_info() {
    rm -f $PROJECT_INFO_PATH
    JOINED_ARRAY=$(join_by , $PROJECT_INFO)

cat > $PROJECT_INFO_PATH <<EOF
    export default [$JOINED_ARRAY] // $hash_code
EOF

    replace_project_info_in_bundlejs
}

replace_project_info_in_bundlejs() {
    BUNDLEJS_PATH=GerritStats/out-html/bundle.js
    REPLACED_LINE=$(
        egrep -n "$HASH_CODE" $BUNDLEJS_PATH | cut -d " " -f1 | cut -d ":" -f1
    )

    PI_FILE_CONTENT=$(sed -e 's/\/\//\\\/\\\//' -e 's/export default/exports.default =/' $PROJECT_INFO_PATH)
    NUMBER_OF_LINE=$(cat $PROJECT_INFO_PATH | wc -l)

    if [[ $NUMBER_OF_LINE == "1" ]]; then 
    sed -i "${REPLACED_LINE}s/.*/$HASH_CODE/" $BUNDLEJS_PATH
sed -i -f - $BUNDLEJS_PATH << EOF
s/$HASH_CODE/$PI_FILE_CONTENT/
EOF
    fi
    echo "Generate all projects's stats successfully"
}

generate_stats
