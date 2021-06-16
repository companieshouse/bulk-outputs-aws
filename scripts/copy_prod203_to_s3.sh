# This script copies product 203 variants to an Amazon S3 bucket.  

this_progname="$(basename $BASH_SOURCE)"
this_product="prod203"
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

# Repeat the validation of the 203 variant in copy_bulkoutputs_to_s3 in case
# this script is called directly

variant="${1}"
if [[ -z $variant || ! "$valid_prod203_variants" =~ "$variant" ]] ;
    then
    echo "For Product 203 you must supply the variant"
    echo "Valid variants are: $valid_prod203_variants"
    exit 1
fi

latest_file=""

# get latest file of the required variant

variant_list=""

case $variant in
    dat)
       variant_list="dat" ;;
    rep)
       variant_list="rep" ;;
    all_variants)
       variant_list="dat rep" ;;
esac

for i in $variant_list
do
    prod203_file_pattern="Prod203_????_*"$i"*"
    latest_file=`ls -tr $bulk_output_dir$prod203_file_pattern | tail -1`
    echo "Latest prod203 file is $latest_file"
    previous_file="$previous_files_dir/prod203."$i
    echo previous prod203 file is $previous_file

    if [[ $latest_file == "" ]]
    then
        no_file_found $this_progname $this_product $i
    else
        if  cmp -s $latest_file $previous_file
        then
            duplicate_file_found $this_progname $this_product $latest_file $i
        else
            renamed_file="$(basename ${latest_file%_*}).$i".txt
            copy_to_aws $this_product $latest_file $renamed_file $previous_file $product_type "quiet"
        fi
    fi

done

echo
echo "$this_progname ends at" `date +"%H:%M:%S on %d/%m/%Y"`

echo
echo "********************"
echo

