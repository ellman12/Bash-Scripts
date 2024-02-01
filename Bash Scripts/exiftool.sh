# Uses exiftool to copy all the metadata from one file to another.
copy_metadata() {
	if [ "$#" -ne 2 ]; then
		echo "Usage: copy_metadata inputFilename outputFilename"
		return 1
	fi

	inputFile="$1"
	outputFile="$2"
	
 	exiftool -TagsFromFile $inputFile -All:All $outputFile -overwrite_original -api largefilesupport=1
}
