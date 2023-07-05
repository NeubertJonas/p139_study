# CSV Files to be Uploaded

This folder contains processed data, which can be uploaded to SemDis in order to calculate semantic distances for the first response, last response, and all neighouring words.

Link: http://semdis.wlu.psu.edu

List of files: first_response.csv; last_response.csv; chain_response.csv

Once you have uploaded chain_response.csv to SemDis, place the resulting CSV file in the "_input" folder for calculating the chain scores.
Rename this file to "chain_responses_SemDis.csv".

(SemDis only provides semantic distance scores for word pairs, but you are likely interested in the mean & standard deviation for every word chain.)
