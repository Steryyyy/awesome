/(index|volume:|device.description|alsa.card_name|muted:)/&& !/base/ { {++a} {ne=ne"\n"$0}   {if  (a%5==0){ne=ne"|"}} }  \
END  { gsub("\n","",ne);   n=split(ne,ar,"\\|"); for(i=1;i<n;i++) {gsub(/,.*dB/,"",ar[i]); \
gsub(/(volume:|index:|muted:|"|\/|%|=|dB)/,"",ar[i]); end=substr(ar[i],1,4);gsub(/ */,"",end); \
ar[i]=substr(ar[i],4);$0=ar[i];c=index($0,"alsa.card_name")+16;d=index($0,"device.description")+20;\
if (d>c) {dev=substr($0,d); card=substr($0,c,d-c-22);}  \
else	{dev=substr($0,d,c-d-18);card=substr($0,c)} \
   print $1"|"card"|"$4"|"$6"|"dev"|"end ;} }
