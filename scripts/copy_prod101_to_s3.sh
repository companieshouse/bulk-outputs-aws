# This script copies product 101 variants to an Amazon S3 bucket.  

this_progname="$(basename $BASH_SOURCE)"
this_product="prod101"
product_type="free"

echo "$this_progname begins at" `date +"%H:%M:%S on %d/%m/%Y"`

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

# Repeat the validation of the Daily Directory variant in copy_bulkoutputs_to_s3 in case
# this script is called directly

variant="${1}"
if [[ -z $variant || ! "$valid_daily_directory_variants" =~ "$variant" ]] ;
    then
    echo "For Daily Directory products (100 and 101) you must supply the variant"
    echo "Valid variants are: $valid_daily_directory_variants"
    exit 1
fi

prod101_file_pattern=""

latest_file=""

previous_file="$previous_files_dir/prod101_"${1}

# get latest file of the required variant

variant_list=""

case $variant in 
    all_opt)
       variant_list="all_opt" ;;
    noopt)
       variant_list="noopt" ;;
    opt_1_2)
       variant_list="opt_1_2" ;;
    all_variants)
       variant_list="all_opt noopt opt_1_2" ;;
esac

for i in $variant_list 
do
    prod101_file_pattern="Prod101_????_"$i"*"
    latest_file=`ls -tr $bulk_output_dir$prod101_file_pattern | tail -1`
    echo
    previous_file="$previous_files_dir/prod101_"$i
    echo "Previous prod101 file is $previous_file"
    
    if [[ $latest_file == "" ]] ;
    then
        no_file_found $this_progname $this_product $i
    else
        if  cmp -s $latest_file $previous_file
        then
            duplicate_file_found $this_progname $this_product $latest_file $1
        else
            renamed_file=$(basename ${latest_file%_*}).txt
            copy_to_aws $this_product $latest_file $renamed_file $previous_file $product_type "quiet" 
        fi

    fi  

done

echo
echo "$this_progname ends at" `date +"%H:%M:%S on %d/%m/%Y"`

echo
echo "********************"
echo

