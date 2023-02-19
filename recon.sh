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
printf "✅${blue} Creating $domain folder ${clear}\n";
fi

# Enumerate all subdomains
printf "${blue}${bold}[+] Enumerating subdomains...${clear}\n";
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
curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | anew $domain/cert.txt > /dev/null;
enumCert="$(cat $domain/cert.txt | wc -l)";
printf "${purple} ✅ CERT.sh found: ${bold}$enumCert${clear}${purple} saved in ${bold}${purple}$domain/cert.txt ${clear} \n";

# Combining results
printf "${blue}${bold}[+] Combining all subdomains...${clear}\n";
cat $domain/assetfinder.txt $domain/subfinder.txt $domain/amass.txt $domain/cert.txt | anew $domain/domains.txt > /dev/null;
enumAllDomains="$(cat $domain/domains.txt | wc -l)"; 
printf "${purple} ✅ Combining result: ${bold}$enumAllDomains${clear}${purple} saved in ${bold}$domain/domains.txt ${clear} \n";

# Probe HTTP/HTTPS
printf "${blue}${bold}[+] Enumerate httprobe...${clear}\n";
cat $domain/domains.txt | httprobe > $domain/httpdomains.txt;
enumProbe="$(cat $domain/httpdomains.txt | wc -l)";
printf "${purple} ✅ httprobe result: ${bold}$enumProbe${clear}${purple} saved in ${bold}$domain/httpdomains.txt \n";

printf "\n";
printf "${bold}${cyan} - Finalized Recongnition -${clear}\n";

