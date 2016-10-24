/* This is a bash file that unzips and stores IPEDS Data Files */
/* I used it, in conjunction with Stata, to create a dataset of enrollment data from the US government for 13 years across multiple states to examine policy effects of state-based legislature */

cd ~/Downloads;
mv *.zip ipeds/;
cd ipeds/;
unzip -j \*.zip;
mv ~/Downloads/ipeds/*.zip ~/Downloads;


/* Change Directory in Each Do File */

sed -i.bak 's/k:\\ipedsdata\\dct\\//g' *.do;
sed -i.bak 's/c:\\dct\\//g' *.do;
sed -i.bak 's/" /"/g' *.do;

rm *.bak;
