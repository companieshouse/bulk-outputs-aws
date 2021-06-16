# This script copies product 233 variants to an Amazon S3 bucket.  

this_progname="$(basename $BASH_SOURCE)"
this_product="prod233"
product_type="secure"

echo "********************"
echo 

echo "$this_progname begins at" `date +"%H:%M:%S on %d/%m/%Y"`

# May need to load the properties if called directly
if [[ -z $server ]] ;
then
    . $bin_dir"process.properties"
    . $bin_dir"bulkoutput_function_lib.sh"
fi

# Repeat the validation of the 233 variant in copy_bulkoutputs_to_s3 in case
# this script is called directly

variant="${1}"
if [[ -z $variant || ! "$valid_prod233_variants" =~ "$variant" ]] ;
    then
    echo "For Product 233 you must supply the variant"
    echo "Valid variants are: $valid_prod233_variants"
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
            #EW
            echo "The Prod233 EW file" 
            previous_file="$previous_files_dir/prod233ew"
            prod233_file_pattern="Prod233_????_ew*"$i"*"
            latest_file=`ls -tr $bulk_output_dir$prod233_file_pattern | tail -1`
            echo "Latest prod233 EW file is $latest_file"
            run_number=`echo $latest_file|cut -d "_" -f 2|cut -c -4`
            echo "Run number is $run_number"

            if [[ $latest_file == "" ]]
            then
                no_file_found $this_progname $this_product $i
            else
                 renamed_file=$(basename ${latest_file})
                 renamed_file=${renamed_file%"${renamed_file#????????????}"}_ew.enc.xml
                 copy_to_aws $this_product $latest_file $renamed_file $previous_file $product_type "quiet"
            fi 

            #SC
            echo "The Prod233 SC file"
            previous_file="$previous_files_dir/prod233sc"
            prod233_file_pattern="Prod233_????_sc*"$i"*"
            latest_file=`ls -tr $bulk_output_dir$prod233_file_pattern | tail -1`
            echo "Latest prod233 SC file is $latest_file"
            run_number=`echo $latest_file|cut -d "_" -f 2|cut -c -4`
            echo "Run number is $run_number"

            if [[ $latest_file == "" ]]
            then
                no_file_found $this_progname $this_product $i
            else
                 renamed_file=$(basename ${latest_file})
                 renamed_file=${renamed_file%"${renamed_file#????????????}"}_sc.enc.xml
                 echo $this_product $latest_file $renamed_file $previous_file $product_type
                 copy_to_aws $this_product $latest_file $renamed_file $previous_file $product_type "quiet"
            fi 

            #NI
            echo "The Prod233 NI file"
            previous_file="$previous_files_dir/prod233ni"
            prod233_file_pattern="Prod233_????_ni*"$i"*"
            latest_file=`ls -tr $bulk_output_dir$prod233_file_pattern | tail -1`
            echo "Latest prod233 NI file is $latest_file"
            run_number=`echo $latest_file|cut -d "_" -f 2|cut -c -4`
            echo "Run number is $run_number"

            if [[ $latest_file == "" ]]
            then
                no_file_found $this_progname $this_product $i
            else
                 renamed_file=$(basename ${latest_file})
                 renamed_file=${renamed_file%"${renamed_file#????????????}"}_ni.enc.xml
                 echo $this_product $latest_file $renamed_file $previous_file $product_type
                 copy_to_aws $this_product $latest_file $renamed_file $previous_file $product_type "quiet"
            fi ;;

        b64)
            for customer_name in "${!p233_customers[@]}";
            do
                echo customer_name is $customer_name
                customer_number=${p233_customers[$customer_name]};
                echo customer number is $customer_number 
                prod233_file_pattern="Prod233_????_$customer_number"_*"$i"*
                echo prod233_file_pattern is $prod233_file_pattern            
                latest_file=`ls -tr $bulk_output_dir$prod233_file_pattern | tail -1`
                run_number=`echo $latest_file|cut -d "_" -f 2`
                echo "Run number is $run_number"
                renamed_file=$customer_name/$(basename ${latest_file%_*}).enc.b64
                echo renamed file is $renamed_file
                previous_file="none"
                copy_to_aws $this_product $latest_file $renamed_file $previous_file $product_type "quiet"
                done ;;
        esac
done

echo
echo "$this_progname ends at" `date +"%H:%M:%S on %d/%m/%Y"`

echo
echo "********************"
echo

