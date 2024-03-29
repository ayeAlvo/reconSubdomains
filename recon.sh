# Colors
white="\e[97m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"
bold="\e[1m"
purple="\e[35m"
cyan="\e[36m"
clear="\e[0m"

# START
figlet -f slant  -c "Recon";
figlet -f digital -c "designed by Aye Alvo";
printf "\n";
# Reading entered domain
printf "${cyan}${bold}Enter domain to enumerate subdomains:${clear} ${white}\n";
read domain ;
printf "\n";

printf "${blue}[+] Starting...${clear} \n";
# Creating directories for domain
if [ ! -d "$domain" ];then
        mkdir $domain
printf "${blue}[+] Creating ${bold}$domain${clear}${blue} folder... ${clear}\n";
fi

# Enumerate all subdomains
printf "${blue}[+] Enumerating subdomains...${clear}\n";
printf "Please wait, this may take a few minutes\n";
amass enum --passive -d $domain -o $domain/amass.txt -silent;
enumAmass="$(cat $domain/amass.txt | wc -l)";
printf "${purple} ✅ amass found: ${bold}$enumAmass${clear}${purple} saved in ${bold}$domain/amass.txt ${clear}\n";
assetfinder --subs-only ${domain} > $domain/assetfinder.txt -silent;
enumAssetfinder="$(cat $domain/assetfinder.txt | wc -l)";
printf "${purple} ✅ assetfinder found: ${bold}$enumAssetfinder${clear}${purple} saved in ${bold}$domain/subfinder.txt ${clear}\n";
subfinder -d ${domain} -silent -o $domain/subfinder.txt > /dev/null;
enumSubfinder="$(cat $domain/subfinder.txt | wc -l)";
printf "${purple} ✅ subfinder found: ${bold}$enumSubfinder${clear}${purple} saved in ${bold}$domain/subfinder.txt ${clear}\n";

# Enumerate Cert.sh
#printf "${blue}[+] Enumerating CERT.SH...\n";
curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | anew $domain/cert.txt > /dev/null;
enumCert="$(cat $domain/cert.txt | wc -l)";
printf "${purple} ✅ CERT.sh found: ${bold}$enumCert${clear}${purple} saved in ${bold}${purple}$domain/cert.txt ${clear} \n";

# Enumerate SubDomains WayBack Machine
curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | anew $domain/waybackurl.txt > /dev/null;
enumWayBackURL="$(cat $domain/waybackurl.txt | wc -l)";
printf "${purple} ✅ WayBackURLs found: ${bold}$enumWayBackURL${clear}${purple} saved in ${bold}${purple}$domain/waybackurl.txt${clear} \n";

# Combining results
printf "${blue}[+] Combining all subdomains...${clear}\n";
cat $domain/assetfinder.txt $domain/subfinder.txt $domain/amass.txt $domain/cert.txt $domain/waybackurl.txt | anew $domain/domains.txt > /dev/null;
enumAllDomains="$(cat $domain/domains.txt | wc -l)";
printf "${purple} ✅ Combining result: ${bold}$enumAllDomains${clear}${purple} saved in ${bold}$domain/domains.txt ${clear} \n";

# Probe HTTP/HTTPS
printf "${blue}[+] Enumerate httprobe...${clear}\n";
cat $domain/domains.txt | httprobe > $domain/httpdomains.txt;
enumProbe="$(cat $domain/httpdomains.txt | wc -l)";
printf "${purple} ✅ httprobe result: ${bold}$enumProbe${clear}${purple} saved in ${bold}$domain/httpdomains.txt ${clear} \n";

# Verify Response Code
printf "${blue}[+] Verify response code...${cleaar}\n";
cat $domain/httpdomains.txt | while read line; do
        response=$(curl $line --write-out '%{response_code}' -L --head --silent --output /dev/null)
                echo "$line response code: $response" >> $domain/withresponsecode.txt;
done;
sort $domain/withresponsecode.txt -k 4 -o $domain/withresponsecode.txt;
printf "${purple} ✅ Done, saved in ${bold}$domain/withresponsecode.txt ${clear} \n";

# Search TakeOver Subdomain
printf "${blue}[+] Search TakeOver Subdomain...${cleaar}\n";
cat $domain/withresponsecode.txt | grep 404 | awk '{print $1}' > $domain/404.txt;
python3 takeover/takeover.py -l $domain/404.txt -o $domain/takeover.txt > /dev/null;
rm $domain/404.txt;
printf "${purple} ✅ Result saved in ${bold}$domain/takeover.txt ${clear} \n";

printf "\n";
printf "${bold}${cyan} - Finalized Recongnition -${clear}\n";