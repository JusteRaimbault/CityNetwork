# -*- coding: utf-8 -*-
import time,sys
import relevant,utils,stats,cybergeo,kwExtraction


def run():
    task = sys.argv[1]

    if task=='--keywords-extraction':
        ## extract keywords
        source = sys.argv[2]
        kwExtraction.run_kw_extraction(source)

    if task=='--stats':
        ## stats
        stats.export_ref_info()

    if task=='--relevance-estimation':
        ## relevance estimation
        relevant.relevant_full_corpus(50000)

    if task=='--cybergeo':
        cybergeo.extract_cybergeo_keywords()
        #cybergeo.extract_relevant_cybergeo(2000)
        #cybergeo.extract_relevant_cybergeo_fulltext(20)

def main():

    start = time.time()

    run()

    print('Ellapsed Time : '+str(time.time() - start))


main()
