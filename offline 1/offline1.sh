#!/bin/bash

traverse_directories()
{
	local source="$1"
	local target_dir="$2"
	local roll="$3"

	# echo "$verbose"
	if [ -d "$1" ]
	then
		for i in "$1"/*
		do
			traverse_directories "$i" "$target_dir" "$roll"
		done
	
	elif [ -f "$source" ]
	then
		if [[ "$source" == *.c ]]; then
    		# echo "$source has a .c extension."
			# echo "$(basename "$source")"
			mkdir -p "$target_dir/C/$roll"
			mv "$source" "$target_dir/C/$roll"
			if [ "$verbose" = true ]; then
				echo "Orgasnising files of $roll"
			fi
		elif [[ "$source" == *.java ]]; then
    		# echo "$source has a .java extension."
			# echo "$(basename "$source")"
			mkdir -p "$target_dir/Java/$roll"
			mv "$source" "$target_dir/Java/$roll"
			if [ "$verbose" = true ]; then
				echo "Orgasnising files of $roll"
			fi
		elif [[ "$source" == *.py ]]; then
    		# echo "$source has a .python extension."
			# echo "$(basename "$source")"
			mkdir -p "$target_dir/Python/$roll"
			mv "$source" "$target_dir/Python/$roll"
			if [ "$verbose" = true ]; then
				echo "Orgasnising files of $roll"
			fi
		fi
	fi
}

rename_files() {
    local source_dir="$1"
    for file in "$source_dir"/*; do
       if [ -f "$file" ]; then
            base_name=main
            extension="${file##*.}"
			if [[ "$file" == *.java ]]; then
				base_name=Main
			fi
			# echo "$extension"
			# echo "$base_name"
			# echo "$file"

			if [[ "$file" != "${file%/*}/$base_name.$extension" ]]; then
            	mv -f "$file" "${file%/*}/$base_name.$extension"
			fi
        elif [ -d "$file" ]; then
            # Recursively call the function for subdirectories
            rename_files "$file"
        fi
    done
}


runCfiles() {
	local source_dir="$1"
	local input_dir="$2"
	local answer_dir="$3"
	local csv_file="$4"
	local home_dir="$5"

	Matched=0
	NotMatched=0

	# echo "$source_dir"
	# echo "$input_dir"
	# echo "$answer_dir"

	for file in "$source_dir"/*; do
	   if [ -f "$file" ]; then
	   		# echo "$file"
			cd "$source_dir"
  			gcc -o main.out "$file"
			if [ "$verbose" = true ]; then
				echo "Executing files of $(basename "$source_dir")"
			fi
			mkdir -p outputs
			counter=1
			for input in "$input_dir"/*; do
				if [ -f "$input" ]; then
					./main.out < "$input" > "$source_dir/outputs/out${counter}.txt"
					((counter++))					
				fi
			done
			counter=1
			for output in "$source_dir/outputs"/*; do
				if [ -f "$output" ]; then
					diff_result=$(diff -q "$source_dir/outputs/out${counter}.txt" "$answer_dir/ans${counter}.txt")
					if [ -z "$diff_result" ]; then
						((Matched++))
					else
						((NotMatched++))
					fi	

				((counter++))			
				fi
			done

			cd "$home_dir"
			# echo "Matched: $Matched"
			# echo "NotMatched: $NotMatched"
			echo "$(basename "$source_dir"),C,$Matched,$NotMatched" >> "$csv_file"
			cd "$source_dir"
			Matched=0
			NotMatched=0

		elif [ -d "$file" ]; then
			runCfiles "$file" "$input_dir" "$answer_dir" "$csv_file" "$home_dir"
		else
			echo "No files found"
		fi

		
	done



}

runJavaFiles()
{
	local source_dir="$1"
	local input_dir="$2"
	local answer_dir="$3"
	local csv_file="$4"
	local home_dir="$5"

	Matched=0
	NotMatched=0

	# echo "$source_dir"
	# echo "$input_dir"
	# echo "$answer_dir"

	for file in "$source_dir"/*; do
	   if [ -f "$file" ]; then
	   		# echo "$file"
			cd "$source_dir"
  			javac "$file"
			if [ "$verbose" = true ]; then
				echo "Executing files of $(basename "$source_dir")"
			fi
			mkdir -p outputs
			counter=1
			for input in "$input_dir"/*; do
				if [ -f "$input" ]; then
					java Main < "$input" > "$source_dir/outputs/out${counter}.txt"
					((counter++))					
				fi
			done
			counter=1
			for output in "$source_dir/outputs"/*; do
				if [ -f "$output" ]; then
					diff_result=$(diff -q "$source_dir/outputs/out${counter}.txt" "$answer_dir/ans${counter}.txt")
					if [ -z "$diff_result" ]; then
						((Matched++))
					else
						((NotMatched++))
					fi	

				((counter++))			
				fi
			done

			cd "$home_dir"
			# echo "Matched: $Matched"
			# echo "NotMatched: $NotMatched"
			echo "$(basename "$source_dir"),Java,$Matched,$NotMatched" >> "$csv_file"
			cd "$source_dir"
			Matched=0
			NotMatched=0
		elif [ -d "$file" ]; then
			runJavaFiles "$file" "$input_dir" "$answer_dir" "$csv_file" "$home_dir"
		else
			echo "No files found"
		fi
	done
}
runPythonFiles(){
	local source_dir="$1"
	local input_dir="$2"
	local answer_dir="$3"
	local csv_file="$4"
	local home_dir="$5"

	Matched=0
	NotMatched=0

	# echo "$source_dir"
	# echo "$input_dir"
	# echo "$answer_dir"

	for file in "$source_dir"/*; do
	   if [ -f "$file" ]; then
	   		# echo "$file"
			cd "$source_dir"
			if [ "$verbose" = true ]; then
				echo "Executing files of $(basename "$source_dir")"
			fi
			mkdir -p outputs
			counter=1
			for input in "$input_dir"/*; do
				if [ -f "$input" ]; then
					python3 "$file" < "$input" > "$source_dir/outputs/out${counter}.txt"
					((counter++))					
				fi
			done
			counter=1
			for output in "$source_dir/outputs"/*; do
				if [ -f "$output" ]; then
					diff_result=$(diff -q "$source_dir/outputs/out${counter}.txt" "$answer_dir/ans${counter}.txt")
					if [ -z "$diff_result" ]; then
						((Matched++))
					else
						((NotMatched++))
					fi	

				((counter++))			
				fi
			done
			
			cd "$home_dir"
			# echo "Matched: $Matched"
			# echo "NotMatched: $NotMatched"
			echo "$(basename "$source_dir"),Python,$Matched,$NotMatched" >> "$csv_file"
			cd "$source_dir"
			Matched=0
			NotMatched=0
		elif [ -d "$file" ]; then
			runPythonFiles "$file" "$input_dir" "$answer_dir" "$csv_file" "$home_dir"
		else
			echo "No files found"
		fi
	done
}

home_dir=$(pwd)
submission_folder="$home_dir/$1"
target_folder="$home_dir/$2"
input_folder="$home_dir/$3"
answer_folder="$home_dir/$4"
aux_arguement_1="$5"
aux_arguement_2="$6"
verbose=false
noexecute=false

if(($# > 4)); then
	if [ "$aux_arguement_1" == "-v" ]; then
		verbose=true
	elif [ "$aux_arguement_1" == "-noexecute" ]; then
		noexecute=true
	fi
	if [ "$aux_arguement_2" == "-noexecute" ]; then
		noexecute=true
	elif [ "$aux_arguement_2" == "-v" ]; then
		verbose=true
	fi

elif(($# < 4)); then
	echo "Invalid number of arguments"
	exit 1
fi






# echo "Home directory: $home_dir"
# echo "Submission folder: $submission_folder"
# echo "Target folder: $target_folder"

if [ -d "$target_folder" ]; then
	rm -rf "$target_folder"
fi
mkdir -p $target_folder
cd $target_folder
mkdir -p C
mkdir -p Java
mkdir -p Python
cd $submission_folder

for file in *.zip; do
	roll=${file: -11: -4}
	mkdir -p "destination/$roll"
    unzip -q -d "destination/$roll" "$file"
	traverse_directories "destination/$roll" "$target_folder" "$roll"
done

rm -rf destination

cd $home_dir
rename_files $target_folder

if [ "$noexecute" = false ]; then

	output_file="output.csv"
	echo "Roll,type,Matched,NotMatched" > "$output_file"
	runCfiles "$target_folder/C" "$input_folder" "$answer_folder"  "$output_file" "$home_dir"
	runJavaFiles "$target_folder/Java" "$input_folder" "$answer_folder"  "$output_file" "$home_dir"
	runPythonFiles "$target_folder/Python" "$input_folder" "$answer_folder"  "$output_file" "$home_dir"
fi


# if [ -d 'destination' ]
# then

# 	echo "destination exists"


# 	traverse_directories destination "$target_folder"
# else
# 	echo "No zip files found"
# fi

# cd ..
# cd ..
# mkdir Matches
# cd Matches
# mkdir Targets
# cd ..
# cd Workspace
# cd $submission_folder
# traverse_directories $submission_folder
# pwd


