#!/bin/bash

# Script is for searching a single folder of pdfs using pdfgrep,
# notifying if any result was found, and opening only the pdfs
# that contain a result in evince with text highlighted.
#
# MUST HAVE PDFGREP AND EVINCE INSTALLED!
#
# Coded by: Robert Brown
# February 21, 2023

# store search argument
search_term=$1

# define file in current dir to store raw search results.
search_results_file=pdf_search_results.txt

# define file to be used for stripped filenames.
stripped_urls_file=stripped_url_results.txt

# run pdfgrep for search term on all pdf files in directory ignoring case and printing filename, and populate search file with results.
pdfgrep $1 -iH *.pdf > $search_results_file

# if raw search file is not empty and file size > 0, meaning results were found, do this.
if [ -s "${search_results_file}" ]
then
	# print success message.
	echo "match for $search_term found!"

	# cut filenames from results file using : as delimiter and put in new txt file.
	cut -d: -f1 $search_results_file > $stripped_urls_file

	# remove raw search file.
	rm $search_results_file

	# define empty array to store unique filenames.
	filename_array=()

	# read over filenames from stripped_urls_file and put into array only if not already in array.
	while read filename; do

		if [[ ! " ${filename_array[*]} " =~ " ${filename} " ]];
		then
			filename_array[${#filename_array[@]}]=$filename
		fi
	done < $stripped_urls_file

	#remove stripped urls file
	rm $stripped_urls_file

	# print unique results from array.
	printf 'Results found in: %s\n' "${filename_array[@]}"

	# open unique result files with text highlighted.
	echo "Opening files..."
	for unique_filename in "${filename_array[@]}"
	do
		evince --find=$search_term $unique_filename &
	done

# else if file is empty, print no match found.
else
	echo "No match found for $search_term"

	script_name="${0##*/}"
	printf 'Proper syntax is ./%s <search_term>. Ex.: ./%s banana\n' $script_name $script_name
fi
