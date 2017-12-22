#!/bin/bash
rm -rf dns.temp
domain=$(echo $1 | cut -d "." -f1)
clear
if [[ -z "$1" ]]; then
echo "Usage:  ./recon-kmg.sh <hostname>"
exit 0
fi
echo Performing WHOIS Lookup...saving output to $1_whois.txt
whois $1 > $1_whois.txt
echo " "
echo DNS servers for $1:
nslookup -type=any $1 | grep nameserver | cut -d  "=" -f2 | cut -d " " -f2 | rev | cut -c2- | rev | tee $1_dnsservers.txt
echo " "
echo Mail servers for $1:
nslookup -type=mx $1 | grep mail | cut -d "=" -f2 | cut -d " " -f2,3 | tee $1_mxrecords.txt
echo " "
echo TXT records for $1:
nslookup -type=txt $1 | grep "text" | cut -d "=" -f2,3 | tee $1_txtrecords.txt
echo " "
for i in $(cat $1_dnsservers.txt); do
  echo " ";
  echo Attempting Zone Transfer on $i | tee -a $1_zonetransfer.txt;
  dig AXFR $1 $ns | tee -a $1_zonetransfer.txt;
done
echo " "
echo Performing Google Dorks, Shodan HQ, WHOIS Lookups on $1: Opening FireFox...
firefox -new-tab -url http://whois.sc/$1 -new-tab -url http://www.google.com/search?q=site%3A$1 -new-tab -url http://www.google.com/search?q=site%3A$1+type%3Apdf -new-tab -url http://www.google.com/search?q=site%3A$1+type%3Axls -new-tab -url http://www.google.com/search?q=site%3A$1+type%3Axlsx -new-tab -url http://www.google.com/search?q=site%3A$1+type%3Acsv -new-tab -url http://www.google.com/search?q=site%3A$1+type%3Atxt -new-tab -url http://www.google.com/search?q=site%3A$1+type%3Adb -new-tab -url https://www.shodan.io/search?query=$1 -new-tab -url https://www.shodan.io/search?query=$domain &
exit 0
