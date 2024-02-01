# Given a video file with multiple audio tracks, use ffmpeg to create a new video that merges the specified audio tracks and adjusts their output volume.
merge_tracks() {
	if [ "$#" -ne 4 ]; then
		echo "Usage: merge_tracks inputFilename outputFilename \"audio tracks\" \"volume levels\""
		return 1
	fi

	inputFile="$1"
	outputFile="$2"
	tracks=($3)
	volumes=($4)

	if [ "${#tracks[@]}" -ne "${#volumes[@]}" ]; then
		echo "Audio tracks and volume level arrays need to have same length"
		return 1
	fi

	tracksCmd=""
	trailingTracksCmd=""

	for ((i = 0; i < ${#tracks[@]}; i++)); do
		tracksCmd+="[0:a:${tracks[i]}]volume=${volumes[i]}[a${tracks[i]}];"
		trailingTracksCmd+="[a${tracks[i]}]"
	done

	ffmpeg -v error -i $inputFile -filter_complex ${tracksCmd}${trailingTracksCmd}amerge=inputs=${#tracks[@]}[aout] -map 0:v -map "[aout]" -c:v copy -c:a aac $outputFile
	copy_metadata $inputFile $outputFile
}

# Given a video file, use ffmpeg to compress the video to the given resolution.
compress_video() {
	if [ "$#" -ne 4 ]; then
		echo "Usage: compress_video inputFilename outputFilename width height"
		return 1
	fi

	inputFile="$1"
	outputFile="$2"
	width="$3"
	height="$4"

	ffmpeg -v error -i $inputFile -vf "scale=$width:$height" -c:a copy $outputFile
	copy_metadata $inputFile $outputFile
}

# Given an array of video files, use compress_video() to compress them all to the given resolution.
compress_videos() {
	if [ "$#" -lt 4 ]; then
		echo "Usage: compress_videos width height outputDir inputFilenames"
		return 1
	fi
	
	width=$1
    height=$2
    outputDir=$3
    shift 3

    for file in "$@"; do
		echo "Compressing $inputFile"
		compress_video $file "$outputDir/$file" $width $height
    done
}

# Given a video file, use ffmpeg to trim the start of the video.
trim_video_start() {
	if [ "$#" -ne 3 ]; then
		echo "Usage: trim_video_start inputFilename outputFilename "seconds or HH:MM:SS""
		return 1
	fi
	
	inputFile="$1"
	outputFile="$2"
	newStartTime="$3"
	
	ffmpeg -v error -i $inputFile -ss $newStartTime -c:a aac $outputFile
	copy_metadata $inputFile $outputFile
}
