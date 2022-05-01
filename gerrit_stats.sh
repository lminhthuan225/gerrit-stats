#!/bin/bash

script_path=$(pwd)
static_file_out_dir=$script_path/GerritStats/out-html
data_out_dir=$script_path/GerritStats/out-html/data
jar_dir=$script_path/GerritStats/build/libs
project_info_dir=$script_path/GerritStats/src/main/frontend

json_dir=json-storage
project_names=$(ls $json_dir | grep -e '.json$' | cut -d "." -f 1)
hash_code="487fd0a6850bc56e1ec548072aaa2412f32323c7059a0d00144e013f4930c77f"

function join_by {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

remove_null_line() {
    local file_path=${1-} file_name=${2-}
    file="$file_path/$file_name"

    #format original json file
    echo "Formatting file"
    jq '.' $file.json > ${file}_temp.json

    #replace null | null, by ''
    echo "Removing null line"
    sed -e 's/^[ ]*null,//g' -e 's/^[ ]*null//g' -i ${file}_temp.json #-e 's/^[ ]*},\n*[ ]*null/}/g'

    mv ${file}_temp.json $file.json
}

#clean old data
clean_old_data() {
    rm -rf $data_out_dir
}

#generate data for all projects in json folder
generate_stats() {
    echo "Cleaning old data..."
    clean_old_data
    for project_name in $project_names
    do
        echo "Checking null line in json file, project:  $project_name"
        remove_null_line $json_dir $project_name
        java -Xmx4096m -Xms256m \
            -jar $jar_dir/GerritStats.jar \
            -o $data_out_dir/$project_name \
            --file $json_dir/$project_name.json || exit 1
    done
    generate_project_info
}

project_names_str=""
generate_project_info() {
    for project_name in $project_names
    do
        overview_path=$data_out_dir/$project_name/overview.js
        dataset_overview_path=$data_out_dir/$project_name/datasetOverview.js

        overview_data_file_content=$(cat $overview_path | cut -d "=" -f2 | sed -e 's/\;//g' -e '/identity/d' | jq '.[] | {identifier: .identifier, commitCount: .commitCount}' | sed 's/\}/\},/g' | tr '\n' ' ' | sed 's/ //g')
        dataset_overview_file_content=$(cat $dataset_overview_path | cut -d "=" -f2 | sed -e 's/\;//g' -e '/identity/d' | jq '. | {fromDate: .fromDate, toDate: .toDate}' | sed 's/\}/\},/g' | tr '\n' ' ' | sed 's/ //g')
        
        project_names_str+=" {name:\"$project_name\",overviewUserdata:[$overview_data_file_content],datasetOverview:$dataset_overview_file_content}"
    done
    rewrite_project_info
}

rewrite_project_info() {
    rm -f $project_info_dir/projects.js
    joined_array=$(join_by , $project_names_str)

cat > $project_info_dir/projects.js <<EOF
    export default [$joined_array] // $hash_code
EOF

    replace_project_info_in_bundlejs
}

# # generate static file if have npm
# cd  || exit 1
# npm run webpack 
#another way is replacing an existing projects exports.default line
replace_project_info_in_bundlejs() {
    bundle_js_path=$script_path/GerritStats/out-html/bundle.js
    replace_line=$(
        egrep -n "$hash_code" $bundle_js_path | cut -d " " -f1 | cut -d ":" -f1 
    )
    # replace_line=`expr "$line_before_replace_line" + 1`
    echo "Replaced line: $replace_line"
    file_content=$(sed -e 's/\/\//\\\/\\\//' -e 's/export default/exports.default =/' $script_path/GerritStats/src/main/frontend/projects.js)
    # line_identifier="${hash_code}skqist225"
    number_of_line=$(cat $script_path/GerritStats/src/main/frontend/projects.js | wc -l)
    echo "number of line: $number_of_line"
    if [[ $number_of_line == "1" ]]; then 
    sed -i "${replace_line}s/.*/$hash_code/" $bundle_js_path
sed -i -f - $bundle_js_path << EOF
s/$hash_code/$file_content/
EOF
    fi
}

generate_stats
