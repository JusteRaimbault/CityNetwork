

### Data collection


 - Construct the citation network : `java -jar DataCollection/citationNetwork.jar $SOURCE.[csv|bib] $OUTPUT $DEPTH`
(requires to have a torpool running in backgroud : `java -jar DataCollection/torpool.jar $NWORKERS` or `DataCollection/launchtorpool.sh`

 - Collect abstracts : `java -jar DataCollection/abstractSetRetriever.jar $SOURCE $OUTPUT`

### Keywords extraction

 - Extract potential keywords : `python Semantic/main.py --keywords-extraction $SOURCE $OUTPUT.sqlite3`

### Relevance estimation

 - Estimate keywords relevance : `python Semantic/main.py --relevance-estimation $NKWS $ETH`

### Graph construction

 - Raw graph construction

 - Sensitivity analysis
 
