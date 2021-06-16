#!/bin/sh
# This script copies archived bulk output products from the share
# chfas-pl2:/vol/batenvp1reparchive to an Amazon S3 bucket.  We are using
# the archived copies so as not to interfere with the existing Bulk Outputs process.
# When the Gateway is de-commissioned, we will move the files directly from the
# batenvp1rep share.

# You must supply a valid product name/number as the first parameter.
# If the product has multiple variants, you must also supply the variant
# as a second parameter.
# So, usage examples:
#     copy_bulkoutputs_to_s3 201
#     copy_bulkoutputs_to_s3 100 all_opt

progname="$(basename $0)"

. $HOME/.bash_profile
. $bin_dir"process.properties"
. $bin_dir"bulkoutput_function_lib.sh"

exec &>> $log_location"copy_bulkoutputs_to_s3.log"

echo
echo "************************************************************"
echo

echo "$progname begins at "`date +"%H.%M.%S on %d/%m/%Y"`

# arg1 should contain the bulk output product. Check that it isn't empty...
if [ -z "${1}" ] ; then
   echo "Usage: $progname  bulk_output_product"
   exit 1
fi

#bulk_product=${1^^}

bulk_product=$1

if [[ " $valid_bulkoutputs " =~ " $bulk_product " ]] ; then
    echo "Requested product is $bulk_product"
else 
    echo "Valid bulk output products are: $valid_bulkoutputs"
    echo "exiting..."
    exit 1
fi

# validate the second parameter (the product variant)
case "$bulk_product" in
    10[01])
         daily_directory_variant="${2}"
         if [[ -z $daily_directory_variant || ! "$valid_daily_directory_variants" =~ "$daily_directory_variant" ]] ;            
         then
            echo "For Daily Directory products (100 and 101) you must supply the variant"
            echo "Valid variants are: $valid_daily_directory_variants"
            exit 1
        fi ;;

    202)
        prod202_variant="${2}"
        if [[ -z $prod202_variant || ! "$valid_prod202_variants" =~ "$prod202_variant" ]] ;
        then
            echo "For Product 202 you must supply the variant"
            echo "Valid variants are: $valid_prod202_variants"
            exit 1
        fi ;;
    203)
        prod203_variant="${2}"
        if [[ -z $prod203_variant || ! "$valid_prod203_variants" =~ "$prod203_variant" ]] ;
        then
            echo "For Product 203 you must supply the variant"
            echo "Valid variants are: $valid_prod203_variants"
            exit 1
        fi ;;
    208)
        prod208_variant="${2}"
        if [[ -z $prod208_variant || ! "$valid_prod208_variants" =~ "$prod208_variant" ]] ;
        then
            echo "For Product 208 you must supply the variant"
            echo "Valid variants are: $valid_prod208_variants"
            exit 1
        fi ;;
    209)
        prod209_variant="${2}"
        if [[ -z $prod209_variant || ! "$valid_prod209_variants" =~ "$prod209_variant" ]] ;
        then
            echo "For Product 209 you must supply the variant"
            echo "Valid variants are: $valid_prod209_variants"
            exit 1
        fi ;;
    213)
        prod213_variant="${2}"
        if [[ -z $prod213_variant || ! "$valid_prod213_variants" =~ "$prod213_variant" ]] ;
        then
            echo "For Product 213 you must supply the variant"
            echo "Valid variants are: $valid_prod213_variants"
            exit 1
        fi ;;
    214)
        prod214_variant="${2}"
        if [[ -z $prod214_variant || ! "$valid_prod214_variants" =~ "$prod214_variant" ]] ;
        then
            echo "For Product 214 you must supply the variant"
            echo "Valid variants are: $valid_prod214_variants"
            exit 1
        fi ;;
    215)
        prod215_variant="${2}"
        if [[ -z $prod215_variant || ! "$valid_prod215_variants" =~ "$prod215_variant" ]] ;
        then
            echo "For Product 215 you must supply the variant"
            echo "Valid variants are: $valid_prod215_variants"
            exit 1
        fi ;;
   230)
        prod230_variant="${2}"
        if [[ -z $prod230_variant || ! "$valid_prod230_variants" =~ "$prod230_variant" ]] ;
        then
            echo "For Product 230 you must supply the variant"
            echo "Valid variants are: $valid_prod230_variants"
            exit 1
        fi ;;
   233)
        prod233_variant="${2}"
        if [[ -z $prod233_variant || ! "$valid_prod233_variants" =~ "$prod233_variant" ]] ;
        then
            echo "For Product 233 you must supply the variant"
            echo "Valid variants are: $valid_prod233_variants"
            exit 1
        fi ;;

esac

case "$bulk_product" in
    100)
            . copy_prod100_to_s3.sh $daily_directory_variant ;;
    101)
            . copy_prod101_to_s3.sh $daily_directory_variant ;;
    202)
            . copy_prod202_to_s3.sh $prod202_variant ;;
    203)
            . copy_prod203_to_s3.sh $prod203_variant ;;
    208)
            . copy_prod208_to_s3.sh $prod208_variant ;;
    209) 
            . copy_prod209_to_s3.sh $prod209_variant ;;
    213)
            . copy_prod213_to_s3.sh $prod213_variant ;;
    214)    
            . copy_prod214_to_s3.sh $prod214_variant ;;
    215) 
            . copy_prod215_to_s3.sh $prod215_variant ;;
    230)
            . copy_prod230_to_s3.sh $prod230_variant ;;
    233)
            . copy_prod233_to_s3.sh $prod233_variant ;;

    all)        
            for i in $valid_bulkoutputs
            do
                case "$i" in
                    100)
                        echo "Copying all prod100 variants"
		        . copy_prod100_to_s3.sh all_variants ;;
                    101)        
                        echo "Copying all prod101 variants"
                        . copy_prod101_to_s3.sh all_variants ;;
                    202) 
                        echo "Copying all prod202 variants"
                        . copy_prod202_to_s3.sh all_variants ;;
                    203)
                        echo "Copying all prod203 variants"
                        . copy_prod203_to_s3.sh all_variants ;;
                    208)
                        echo "Copying both prod208 file types"
                        . copy_prod208_to_s3.sh both ;;
                    209)
                        echo "Copying both prod209 file types"
                        . copy_prod209_to_s3.sh both ;;
                    213)
                        echo "Copying all prod213 variants"
                        . copy_prod213_to_s3.sh all_variants ;;
                    214)
                        echo "Copying all prod214 variants"
                        . copy_prod214_to_s3.sh all_variants ;;
                    215)
                        echo "Copying all prod215 variants"
                        . copy_prod215_to_s3.sh all_variants ;;
                    *)
                        echo "Copying prod"$i
                        bulk_output_command="copy_prod"$i"_to_s3.sh"
                        echo "command is $bulk_output_command"
                        . $bulk_output_command 
                 esac
            done ;;
    *)
        bulk_output_command="copy_prod"$bulk_product"_to_s3.sh"
        echo "command is $bulk_output_command"
        . $bulk_output_command ;;
esac

echo "$progname ends OK at" `date +"%H.%M.%S on %d/%m/%Y"`
