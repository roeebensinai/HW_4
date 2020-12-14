#!/bin/bash

# get the main page of website
wget https://www.ynetnews.com/category/3082

# count the number of uniqe articles that fit the condition
num_of_articles=$(grep -oE "https://www.ynetnews.com/article/\b[a-zA-Z0-9]{9}\b"\
 3082 | sort | uniq | wc -w)

# save all articles' URL in a text file
grep -oE "https://www.ynetnews.com/article/\b[a-zA-Z0-9]{9}\b" 3082 | sort | uniq\
 > articles.txt

# run through every article and count the target words
for(( i=1; i<=num_of_articles; i++)); do
	cur_article=$(sed -n "${i}p" articles.txt) # holds the current URL
	wget $cur_article
	# holds the current end of the URL - last 9 digits
	cur_file=$(awk -F/ '{print $5}' articles.txt | sed -n "${i}p") 
	
	(( Netanyahu_count=$(grep -o Netanyahu $cur_file | wc -w) ))
	(( Gantz_count=$(grep -o Gantz $cur_file | wc -w) ))
	
	
	if	(( !Netanyahu_count )) && (( !Gantz_count ));
		then 
		sed -i "s/$cur_file/&, -/" articles.txt;
		else 
		sed -i\
		"s/$cur_file/&, Netanyahu, $Netanyahu_count, Gantz, $Gantz_count/"\
		 articles.txt;
	fi
	rm $cur_file
done

# put all elements in the results file
echo $num_of_articles > results.csv
less articles.txt >> results.csv

# remove used files
rm articles.txt
rm 3082
