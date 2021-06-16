# This script copies product 208 to an s3  bucket.  It can copy:
# the xml file or
# the b64 files or   
# both the xml file and the b64 files

this_progname="$(basename $BASH_SOURCE)"
this_product="prod208"
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

# Repeat the validation of the 208 variant in copy_bulkoutputs_to_s3 in case
# this script is called directly
variant="${1}"
if [[ -z $variant || ! "$valid_prod208_variants" =~ "$variant" ]] ;
    then
    echo "For Product 208 you must supply the variant"
    echo "Valid variants are: $valid_prod208_variants"
    exit 1
fi

latest_file=""

# get latest file of the required variant

variant_list=""

case $variant in
    xml)
       variant_list="xml" ;;
    b64)
       variant_list="b64" ;;
    both)
       variant_list="xml b64" ;;
esac

for i in $variant_list
do
    case $i in
        xml)
            prod208_file_pattern="Prod208_????*"$i"*"
            latest_file=`ls -tr $bulk_output_dir$prod208_file_pattern | tail -1`
            echo "Latest prod208 file is $latest_file"

            if [[ $latest_file == "" ]]
            then
                no_file_found $this_progname $this_product $i
            else
               run_number=`echo $latest_file|cut -d "_" -f 2`
               echo "Run number is $run_number"
               copy_multiple_files_to_aws $this_product xml $run_number $product_type "quiet"
            fi ;;
        b64)
            prod208_file_pattern="Prod208_????*"$i"*"
            latest_file=`ls -tr $bulk_output_dir$prod208_file_pattern | tail -1`
            run_number=`echo $latest_file|cut -d "_" -f 2`
            echo "Run number is $run_number"
            copy_multiple_files_to_aws $this_product b64 $run_number $product_type "quiet" ;;
        esac
done

echo
echo "$this_progname ends at" `date +"%H:%M:%S on %d/%m/%Y"`

echo
echo "********************"
echo

