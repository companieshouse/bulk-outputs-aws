# This script is intended to get around the fact that there is no concept of
# a 'wildcard' when using the aws cli.

# At the moment this command is only configured to copy to the 'free' Bulk 
# outputs bucket.

# The script takes 3 mandatory and one optional parameter:
#    a local directory (Mandatory)
#    a file pattern    (Mandatory)
#    the stem of an aws resource name (Mandatory)
#    a 'dry-run' indicator 
#
# Examples:
#    copy_pattern_to_s3.sh . Prod101*.dat prod100/archive
#    copy_pattern_to_s3.sh . Prod101*.dat prod100/archive dry-run

if ! [[ $# -ge 3 ]]; then
    echo "usage:"
    echo "    copy_pattern_to_s3.sh  source_directory  pattern  stem_of_aws_resource_name  [dry-run]"
    echo "Examples:"
    echo "    copy_pattern_to_s3.sh . \"Prod100*.dat\" prod100/archive"
    echo "    copy_pattern_to_s3.sh . \"Prod100*.dat\" prod100/archive dry-run"
    echo "NB If there is a wildcard in the pattern parameter you MUST surround it with quotes" 
    exit 1
fi

local_dir=$1
pattern=$2
aws_path=$3
dry_run=$4

product_type="free"
aws_environment="live"
aws_profile="bulk-live"

# OK, so I got bored writing these scripts and wanted something new to play with
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

cd $local_dir
if [[ $? -eq 0 ]]; then
    echo "directory changed to $local_dir"
else
    echo "no such local directory: $local_dir"
    exit 1 
fi

if grep -i -q "dry" <<< "$dry_run"; then
    echo "If executed without the dry-run parameter, your command would copy"
    echo "the following file(s) to s3"

    for i in `ls $pattern` ;
    do
        echo -e "${GREEN}$1/$i ${NC}would be copied to"
        echo -e "${CYAN}${product_type}.bulk-gateway."$aws_environment".ch.gov.uk/$3/$i${NC}"
        echo ""
    done

    echo "Exiting without copying files since a dry-run was requested"
    exit 0
fi

for i in `ls $pattern` ;
do
    aws s3 cp $1/${i} s3://${product_type}.bulk-gateway."$aws_environment".ch.gov.uk/$3/$i --profile $aws_profile  --sse aws:kms --sse-kms-key-id 22d0b912-dac1-4cab-9622-7f6f68efab68 --no-verify-ssl --quiet ;
done

