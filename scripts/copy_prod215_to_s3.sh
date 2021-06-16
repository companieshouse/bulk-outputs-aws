# This script copies product 215 variants to an Amazon S3 bucket.  

this_progname="$(basename $BASH_SOURCE)"
this_product="prod215"
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

# Repeat the validation of the 215 variant in copy_bulkoutputs_to_s3 in case
# this script is called directly

variant="${1}"
if [[ -z $variant || ! "$valid_prod215_variants" =~ "$variant" ]] ;
    then
    echo "For Product 215 you must supply the variant"
    echo "Valid variants are: $valid_prod215_variants"
    exit 1
fi

latest_file=""

# get latest file of the required variant

variant_list=""

case $variant in
    rec_ind)
       variant_list="rec_ind" ;;
    ext_rec_ind)
       variant_list="ext_rec_ind" ;;
    all_variants)
       variant_list="rec_ind ext_rec_ind" ;;
esac

for i in $variant_list
do
    prod215_file_pattern="$i*"
    latest_file=`ls -tr $bulk_output_dir$prod215_file_pattern | tail -1`
    echo "Latest prod215 file is $latest_file"
    previous_file="$previous_files_dir/prod215."$i
    echo previous prod215 file is $previous_file

    if [[ $latest_file == "" ]]
    then
        no_file_found $this_progname $this_product $i
    else
        if  cmp -s $latest_file $previous_file
        then
            duplicate_file_found $this_progname $this_product $latest_file $i
        else
            renamed_file="$(basename ${latest_file})"
            renamed_file="$(tr -s  '.' '_' <<<$renamed_file)".txt
            echo renamed file now is $renamed_file
            # Clive and David requested that the extended filename be changed from ext_rec_ind to 
            # rec_ind_ext.  Just comment out the following 'if' statement if the customers 
            # complain and you want to revert. 
            if [[ $renamed_file == "ext"* ]]; then
                runno=`echo $renamed_file|awk '{print substr($1,13,4)}'`
                renamed_file="rec_ind_ext_"$runno".txt"
            fi
            copy_to_aws $this_product $latest_file $renamed_file $previous_file $product_type "quiet"
        fi
    fi

done

echo
echo "$this_progname ends at" `date +"%H:%M:%S on %d/%m/%Y"`

echo
echo "********************"
echo

