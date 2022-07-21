#!/bin/bash

#Grab folder names that contain the output for each sample (these tend to be shorter than the file name)
folders=$(ls -lha  | grep drw | awk '{print $NF}' | grep -v "\."  | tr '\n' ' ')

# Create a header for a tab deliminated file of the combined BUSCO stats
echo "sample    percentages     completeBUSCOS  completeSingle  completeDuplicate       fragmented      missing total" > statsTable.txt 
# Create a header for a markdown file of the combined BUSCO stats
echo "|sample|percentages|completeBUSCOS|completeSingle|completeDuplicate|fragmented|missing|total|" > statsTable.md
echo "| -- | -- | -- | -- | -- | -- | -- | -- |" >> statsTable.md

# Loop through the folder names
for folder in $folders 
do 
	# For each folder execute the following grep commands to extract the information and store it in a variable we can use later 
	file=$(find . -name "*${folder}.txt")
	percentages=$(cat $file | grep "C:" | awk '{print $1}') 
	completeBUSCOS=$(grep "Complete BUSCOs" $file | awk '{print $1}')
	completeSingle=$(grep "Complete and single-copy BUSCOs" $file | awk '{print $1}')
	completeDuplicate=$(grep "Complete and duplicated BUSCOs" $file | awk '{print $1}')
	fragmented=$(grep "Fragmented BUSCOs" $file | awk '{print $1}')
	missing=$(grep "Missing BUSCOs" $file | awk '{print $1}')
	total=$(grep "Total BUSCO" $file | awk '{print $1}')
	
	# print the stored variables into the files
	echo "$folder:	$percentages	$completeBUSCOS	$completeSingle	$completeDuplicate	$fragmented	$missing	$total" >> statsTable.txt
        echo "|$folder:|$percentages|$completeBUSCOS|$completeSingle|$completeDuplicate|$fragmented|$missing|$total|" >> statsTable.md
	
done


