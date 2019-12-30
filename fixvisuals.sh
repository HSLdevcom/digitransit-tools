
#HowTo: 
# With this script you can automatically switch new reference photos for visual tests. It looks for current images in gemini-report folder that has failed 5 times, and replaces ui visual test images with those images. 
# This script should reside in gemini-report folder, same where for example index.html is. your own path to ui visual tests is needed too. 


#! bin/bash

readarray -d '' array < <(find images/ -name "*diff_5*" -print0)
actual="~current_5"
png=".png"
uipath="<path_to_ui>/digitransit-ui/test/visual-images/"
for i in "${array[@]}"
do :
    newPic=${i: 0:-11}$actual$png
    mv $newPic $uipath${i: 7:-11}$png
done
