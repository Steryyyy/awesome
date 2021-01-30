BEFORE{man=""; whole=""} /[0-9]: / {if ($2!="lo:"){  man=$2; if (whole==""){ whole=$2} else {whole=whole"\n"$2}}} /inet/ ||/link\/ether/ {if (man!=""){ whole=whole"|"$2} } END{print whole}
