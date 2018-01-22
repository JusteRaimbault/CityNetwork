# -*- coding: utf-8 -*-
import time,sys
import relevant,utils,stats,dbmanagement,kwExtraction

def run():
    task = sys.argv[1]

    if task=='--keywords-extraction':
        from treetagger import TreeTagger
        ## extract keywords
        if len(sys.argv) != 4 : raise(Exception('Usage : --keywords-extraction sourcefile.csv outfile.sqlite3'))
        source = sys.argv[2]
        target = sys.argv[3]
        kwExtraction.run_kw_extraction(source,target)

    if task=='--stats':
        ## stats
        stats.export_ref_info()

    if task=='--relevance-estimation':
        ## relevance estimation
        source = sys.argv[2]
        mongodb = sys.argv[3]
        kwLimit = sys.argv[4]
        eth = sys.argv[5]

        # migrate keywords to mongo
        dbmanagement.keywords_to_mongo(source,mongodb)
        # estimate relevance
        relevant.relevant_full_corpus(mongodb,int(kwLimit),int(eth))
        # export dico to R
        #sys.exec()

#    if task=='--cybergeo':
#        cybergeo.extract_cybergeo_keywords()
#        #cybergeo.extract_relevant_cybergeo(2000)
#        #cybergeo.extract_relevant_cybergeo_fulltext(20)

def main():

    start = time.time()

    run()

    print('Ellapsed Time : '+str(time.time() - start))


main()
