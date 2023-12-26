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

	ffmpeg -i $inputFile -filter_complex ${tracksCmd}${trailingTracksCmd}amerge=inputs=${#tracks[@]}[aout] -map 0:v -map "[aout]" -c:v copy -c:a aac $outputFile
}
