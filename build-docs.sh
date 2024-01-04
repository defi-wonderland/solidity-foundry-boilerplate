#!/bin/bash

root_path="src" # this could be src/interfaces

# generate docs in a temporary directory
temp_folder="technical-docs"

# path to the base folder
base_folder="docs/src/$root_path"

FOUNDRY_PROFILE=docs forge doc --out "$temp_folder"

# edit generated summary not to have container pages
# - [jobs](src/interfaces/jobs/README.md)
# should become
# - [jobs]()
# TODO

# edit generated summary titles to start with an uppercase letter
# - [jobs]()
# should become
# - [Jobs]()
# TODO

# edit the SUMMARY after the Interfaces section
# https://stackoverflow.com/questions/67086574/no-such-file-or-directory-when-using-sed-in-combination-with-find
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' -e '/\Technical Documentation/q' docs/src/SUMMARY.md
else
  sed -i -e '/\Technical Documentation/q' docs/src/SUMMARY.md
fi
# copy the generated SUMMARY, from the tmp directory, without the first 5 lines
# and paste them after the Interfaces section on the original SUMMARY
tail -n +4 $temp_folder/src/SUMMARY.md >> docs/src/SUMMARY.md

# delete old generated interfaces docs
rm -rf docs/src/$root_path
# there are differences in cp and mv behavior between UNIX and macOS when it comes to non-existing directories
# creating the directory to circumvent them
mkdir -p docs/src/$root_path
# move new generated interfaces docs from tmp to original directory
cp -R $temp_folder/src/$root_path docs/src

# delete tmp directory
rm -rf $temp_folder

# function to replace text in all files (to fix the internal paths)
replace_text() {
    for file in "$1"/*; do
        if [ -f "$file" ]; then
            sed -i "s|$temp_folder/src/||g" "$file"
        elif [ -d "$file" ]; then
            replace_text "$file"
        fi
    done
}

# calling the function to fix the paths
replace_text "$base_folder"