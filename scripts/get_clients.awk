/(index:|media.filename|volume:|sink:|source:|muted:|application.name =)/ { {++a} {ne=ne"\n"$0}   {if  (a%5==0){ne=ne"|"}} }\
END  { gsub("\n","",ne);   n=split(ne,ar,"\\|"); for (i=1;i<n;i++) {gsub(/,.*dB/,"",ar[i]) ; gsub(/<.*>/,"",ar[i]) ;\
gsub(/\w*[:-]/,"",ar[i]);gsub(/(dB|\/|%|")/,"",ar[i]);$0=ar[i];  print $1"|"$2"|"$4"|"$6"|"substr($0,index($0,$8)+2)} }
