# Woof Diaries Config File

#PATHS:
bids_path=/mnt/starkdata1/head_dog/BIDS #bids directory
#template_path=/mnt/starkdata1/head_dog/AguirreAtlas
der_path=${bids_path}/derivatives #bids derivatives path folder- don't change unless necessary
gridlog_path=${bids_path}/gridlog #where log files will be stored if using grid
code_path=${bids_path}/code #where github code is stored. Change file name if saved differently
config=${bids_path}/code/woof_config.sh #path to this file
czeibert_atlas=
nitzsche_atlas=
uci_atlas=

#Reset perms:
# ${code_path}/perms.sh ${code_path}

# Describe data set- useful for batch processing.
subjects=(2001374 2153069 2217181 2239002 2278937 2306922 2323916 2336732 2337992 2342342 2351090 2353475 2370574 2372462 2456428 CBECPU CBICBX CCACAI CCACKM CCADBD CCBCHK CCBCMP CCBCPK CCCCJP CCCCUR CCDCJM CCECUM CCFCGY CCFCUI CCLCBX CCLDAL CDBCVB CDFCIA CDGCTP CDHCPP CDICJH CDLDEL CEACSR CEHCSW CEICER CEJCLY CEKCMG CELCBU)
no_of_subjects=`expr ${#subjects[@]} - 1`

sessions=(T0 T1)
no_of_subjects=`expr ${#sessions[@]} - 1`