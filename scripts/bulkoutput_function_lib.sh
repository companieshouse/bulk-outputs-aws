#!/bin/sh

#
# NOTE:
# When the bucket becomes encrypted, we'll have to add the following to the 
# end of the aws s3 call: --server-side-encryption AES256 
#


# Params:
# $1 = Calling script name
# $2 = Product name, eg "prod100"
# $3 = Product variant where applicable, eg "all_opt".  Can be left blank
function no_file_found ()
{
echo "No $2 $3 file found"
echo -e "$1 running on $server could not find a $2 file to copy to s3" | \
         mail -s "No $2 $3 file found" -r $email_from_address \
         $email_recipient_list
}

# Params:
# $1 = Calling script name
# $2 = Product name, eg "prod100"
# $3 = Latest file found
# $4 = Product variant where applicable, eg "all_opt".  Can be left blank
function duplicate_file_found ()
{
echo "$2 $4 file has identical contents to previous file, so file not copied"
echo -e "$1 running on $server has determined that the latest file is: $3, " \
        " but this file has previously been copied to the cloud" | \
        mail -s "Identical $2 $4 file detected" \
        -r $email_from_address $email_recipient_list
}

#Params:
# $1 = Product
# $2 = Latest file
# $3 = Renamed  file
# $4 = Previous file
# $5 = Product_type (free, secure or adhoc)
# $6 = Quiet mode
function copy_to_aws ()
{
echo $PATH
echo "Renamed file ready to copy to s3 is $renamed_file"
#today=$(date '+%Y%m%d')
yyyy=$(date '+%Y')
mm=$(date '+%m')
dd=$(date '+%d')
#echo "params $1 $2 $3 $4 $5 $6"
echo Product_type=$5
if [[ $6 == "quiet" ]] ;
then
    echo "Copying in quiet mode"
    aws s3 cp $2 s3://$5.bulk-gateway."$aws_environment".ch.gov.uk/$1"/"$yyyy"/"$mm"/"$dd"/"$3 --profile $aws_profile  --sse aws:kms --sse-kms-key-id 22d0b912-dac1-4cab-9622-7f6f68efab68  --no-verify-ssl --quiet
    #aws s3 cp $2 s3://$5.bulk-gateway."$aws_environment".ch.gov.uk/$1"/"$yyyy"/"$mm"/"$dd"/"$3 --profile $aws_profile  --sse aws:kms --sse-kms-key-id 22d0b912-dac1-4cab-9622-7f6f68efab68  --debug --ca-bundle ~/.ssh/websenseproxy.companieshouse.local.pem --quiet

    result_code=$?
    if ! [[ $result_code -eq 0 ]]; then
        failed_to_copy_to_aws $1 $result_code 
    else
        echo "Copy complete"
    fi
else
    aws s3 cp $2 s3://$5.bulk-gateway."$aws_environment".ch.gov.uk/$1"/"$yyyy"/"$mm"/"$dd"/"$3 --profile $aws_profile  --sse aws:kms --sse-kms-key-id 22d0b912-dac1-4cab-9622-7f6f68efab68 --no-verify-ssl
    if ! [[ $result_code -eq 0 ]]; then
        failed_to_copy_to_aws $1 $result_code
    else
        echo "Copy complete"
    fi
fi
cp $2 $4
}

#Params:
# $1 = Product
# $2 - File type - currently xml or b64
# $3 = Run number
# $4 = product_type (free, secure or adhoc)
# $5 = Quiet mode
function copy_multiple_files_to_aws ()
{
yyyy=$(date '+%Y')
mm=$(date '+%m')
dd=$(date '+%d')

extension=""
if [[ $2 == "b64" ]] ;
then
    extension=".enc.b64"
fi

if [[ $5 == "quiet" ]] ;
then
    echo "Copying in quiet mode"
    echo "bulk_output_dir is $bulk_output_dir"
    for j in "$bulk_output_dir"${1^}_$run_number*$2*;
    do
        s3_name=$(basename ${j%_*});
        aws s3 cp ${j} s3://$4.bulk-gateway."$aws_environment".ch.gov.uk/$1"/"$yyyy"/"$mm"/"$dd"/"$s3_name$extension --profile $aws_profile  --sse aws:kms --sse-kms-key-id 22d0b912-dac1-4cab-9622-7f6f68efab68 --no-verify-ssl --quiet ;
    result_code=$?
    if ! [[ $result_code -eq 0 ]]; then
        failed_to_copy_to_aws $1 $result_code
    else
        echo "Copy complete"
    fi
    done
else
    for j in "$bulk_output_dir"${1^}_$run_number*$2*;
    do
        s3_name=$(basename ${j%_*});
        aws s3 cp ${j} s3://$4.bulk-gateway."$aws_environment".ch.gov.uk/$1"/"$yyyy"/"$mm"/"$dd"/"$s3_name$extension --profile $aws_profile  --sse aws:kms --sse-kms-key-id 22d0b912-dac1-4cab-9622-7f6f68efab68 --no-verify-ssl ;
    result_code=$?
    if ! [[ $result_code -eq 0 ]]; then
        failed_to_copy_to_aws $1 $result_code
    else
        echo "Copy complete"
    fi
    done
fi
}

# Params:
# $1 = Product name, eg "prod100"
# $2 = Result code
function failed_to_copy_to_aws ()
{
    echo "Failure in copying $1 file to aws, result code is $2"
    
    echo -e "Failure in copying $1 file to aws, result code is $2, see log at $log_location""copy_bulkoutputs_to_s3.log" | \
         mail -s "Failed to copy $1 file to aws" -r $email_from_address \
         $email_recipient_list
}
