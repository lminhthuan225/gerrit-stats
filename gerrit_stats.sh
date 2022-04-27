#!/bin/bash
#
# Runs GerritStats, generating HTML output by default.
#

# script_path="$(cd "$(dirname -- "$0")" || exit 1; pwd -P)"
script_path=$(pwd)
output_dir="$script_path/out-html"

new_args=()
index=0
next_is_output_dir=""

for arg in "$@"; do
    if [ "$next_is_output_dir" != "" ]; then
        output_dir="$arg"
        next_is_output_dir=""
    elif [ "$arg" == "-o" ]; then
        next_is_output_dir="1"
    else
        new_args[$index]="$arg"
        let "index += 1"
    fi
done

function join_by {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

json_dir=./my-json
#generate data for all projects in json folder
project_names=$(ls $json_dir | grep -e '.json$' | cut -d "." -f 1)
# rm -rf GerritStats/out-html/data
rm -f GerritStats/src/main/frontend/projects.js
touch GerritStats/src/main/frontend/projects.js
project_names_str=""
# for name in $project_names
# do
#     # project_names_str+=" {name:\"$name\"}"
#     java -Xmx4096m -Xms256m -jar GerritStats/build/libs/GerritStats.jar \
#     -o GerritStats/out-html/data/$name --file $json_dir/$name.json || exit 1
#     echo "Output generated to GerritStats/out-html/data/$name"
# done

for name in $project_names
do
    if [[ $name != "Legato" ]]; then
        overview_path=$(pwd)/GerritStats/out-html/data/$name/overview.js
        dataset_overview_path=$(pwd)/GerritStats/out-html/data/$name/datasetOverview.js

        overview_data_file_content=$(cat $overview_path | cut -d "=" -f2 | sed -e 's/\;//g' -e '/identity/d' | jq '.[] | {identifier: .identifier, commitCount: .commitCount}' | sed 's/\}/\},/g' | tr '\n' ' ' | sed 's/ //g')
        dataset_overview_file_content=$(cat $dataset_overview_path | cut -d "=" -f2 | sed -e 's/\;//g' -e '/identity/d' | jq '. | {fromDate: .fromDate, toDate: .toDate}' | sed 's/\}/\},/g' | tr '\n' ' ' | sed 's/ //g')
        
        project_names_str+=" {name:\"$name\",overviewUserdata:[$overview_data_file_content],datasetOverview:$dataset_overview_file_content}"
    fi
done

joined_array=$(join_by , $project_names_str)
cat > GerritStats/src/main/frontend/projects.js <<EOF 
export default [
    $joined_array
]
EOF



# generate static file
# cd "$script_path/GerritStats" || exit 1
# npm run webpack && \
# 	mkdir -p "$output_dir/data" && \
#     cp -r "$script_path/GerritStats/out-html/data" "$output_dir/" && \
#     cp -r "$script_path/GerritStats/out-html/"* "$output_dir/"

# npm run webpack-watch
