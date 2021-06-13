#!/bin/bash

#Grab folder names that contain the output for each sample (these tend to be shorter than the file name)
files=$(ls *assemblyStats)

# Create a header for a tab deliminated file of the combined BUSCO stats
echo "Number_of_Scaffolds:	Total_Nucleotide_content:	Longest_Scaffolds:	Shortest_Scaffolds:	Mean_Scaffold_Size:	Median_Scaffold_length: N50_Scaffold_length:	L50_Scaffold_length:	N90_Scaffold_length:	L90_Scaffold_length:" > assemblyStatsTable.txt
# Create a header for a markdown file of the combined BUSCO stats
echo "|Sample | Number_of_Scaffolds:|Total_Nucleotide_content:|Longest_Scaffolds:|Shortest_Scaffolds:|Mean_Scaffold_Size:|Median_Scaffold_length:|N50_Scaffold_length:|L50_Scaffold_length:|N90_Scaffold_length:|L90_Scaffold_length:|" > assemblyStatsTable.md
echo "| -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |" >> assemblyStatsTable.md

# Loop through the folder names
for file in $files 
do 
	values=$(cat $file | grep -v singularity | head | cut -f 1,2 | transpose.awk | tail -n 1)
	valuesMD=$(cat $file | grep -v singularity | head | cut -f 1,2 | transpose.awk | tail -n 1| tr '\t' '|')
	# print stored variables
	echo "$file $values" >> assemblyStatsTable.txt
	echo "|$file|$valuesMD|" >> assemblyStatsTable.md
done


