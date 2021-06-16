# This script copies product 201 to an Amazon S3 bucket.  

this_progname="$(basename $BASH_SOURCE)"
this_product="prod201"
product_type="free"

echo
echo "********************"
echo 

echo "$this_progname begins at" `date +"%H:%M:%S on %d/%m/%Y"`

# May need to load the properties if called directly
if [[ -z $server ]] ;
then
    . $bin_dir"process.properties"
    . $bin_dir"bulkoutput_function_lib.sh"
fi

latest_file=""

previous_file="$previous_files_dir/prod201"
echo previous prod201 file is $previous_file

prod201_file_pattern="Prod201_????_*"
latest_file=`ls -tr $bulk_output_dir$prod201_file_pattern | tail -1`

if [[ $latest_file == "" ]]
then
    no_file_found $this_progname $this_product
else
    if  cmp -s $latest_file $previous_file
    then
        duplicate_file_found $this_progname $this_product $latest_file
    else
        renamed_file=$(basename ${latest_file%_*}).txt
        copy_to_aws $this_product $latest_file $renamed_file $previous_file $product_type "quiet"
    fi
fi

echo
echo "$this_progname ends at" `date +"%H:%M:%S on %d/%m/%Y"`

echo
echo "********************"
echo

