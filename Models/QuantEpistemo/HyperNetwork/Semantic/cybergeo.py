#import utils,kwExtraction
# kw extraction for cybergeo corpus alone
import utils,kwFunctions
#from lxml import html,etree
#import kwExtraction


def extract_relevant_cybergeo_fulltext(kwLimit):
    resdir = 'res/cybergeo_full/'
    #
    corpus = utils.get_data('SELECT id FROM cybergeo WHERE fulltext_keywords IS NOT NULL AND fulltext_keywords!=\'\' LIMIT 10;','mysql')
    occurence_dicos=utils.import_kw_dico_req('SELECT id,fulltext_keywords FROM cybergeo WHERE fulltext_keywords IS NOT NULL AND fulltext_keywords!=\'\' LIMIT 10;','mysql')
    [relevantkw,relevant_dico] = kwFunctions.extract_relevant_keywords(corpus,kwLimit,occurence_dicos)
    # export as csv
    utils.export_dico_csv(relevant_dico,resdir+'relevantDico_kw'+str(kwLimit),False)
    export_dico_num_csv(relevantkw,resdir+'termhoods_kw'+str(kwLimit),False)



def extract_cybergeo_fulltext_keywords():
    data=get_fulltext_cyb_corpus()
    for ref in data :
        print(ref)
    #kwExtraction.run_fulltext_kw_extraction(data)

#extract_cybergeo_fulltext_keywords()


def extract_cybergeo_keywords():
    data=utils.get_data('SELECT refdesc.id,refdesc.abstract FROM refdesc INNER JOIN cybergeo ON cybergeo.id=refdesc.id;','mysql') # WHERE abstract IS NOT NULL AND abstract!=\'\';','mysql')
    print(len(data))
    kwExtraction.run_kw_extraction(map(lambda l : [l[0],clean_abstract(l[1])],data))
    #for l in map(lambda l : [l[0],clean_abstract(l[1])],data):
    #    print(l[0])


def clean_abstract(abstract):
    t = abstract.replace('<br>','').replace('</br>','').replace('<em>','').replace('</em>','').replace('<br />','')
    tree = html.fromstring('<html><body>'+t+'</body></html>')
    #tree = etree.fromstring('<xml>'+abstract+'</xml>')
    #print(abstract)
    #print(tree[0][0].text)
    #print('')
    #print(len(tree))
    if len(tree[0])==0 :
        return(t)
    else :
        #print('=======================\n=======================')
        #print(abstract)
        #print('-----------')
        #print(tree[0][0][0].text)
        if len(tree.find_class('resume'))>0 : return(tree.find_class('resume')[0].text)
	#print('-----------')
	if len(tree.find_class('resumeru'))>0 : return(tree.find_class('resumeru')[0].text)
        #return(tree[0][0][0].text)


# dtabase=../../Data/dumps/20160205_cybergeo.sqlite3
def extract_relevant_cybergeo (kwLimit,database) :
    corpus = utils.get_data('SELECT cybergeo.id FROM refdesc INNER JOIN cybergeo ON cybergeo.id=refdesc.id WHERE abstract_keywords IS NOT NULL AND abstract_keywords!=\'\';',database)
    print(corpus)
    occurence_dicos = utils.import_kw_dico_req('SELECT cybergeo.id,abstract_keywords FROM refdesc INNER JOIN cybergeo ON cybergeo.id=refdesc.id WHERE abstract_keywords IS NOT NULL AND abstract_keywords!=\'\';',database)
    print(occurence_dicos)
    [relevantkw,relevant_dico] = kwFunctions.extract_relevant_keywords(corpus,kwLimit,occurence_dicos)
    utils.export_dico_csv(relevant_dico,'res/cybergeo/relevantDico_kwLimit'+str(kwLimit),False)
    utils.export_dico_num_csv(relevantkw,'res/cybergeo/kw_'+str(kwLimit),False)


#for kwLimit in [100,200,500,1000,1500,2000]:
#    extract_relevant_cybergeo (kwLimit,'../../Data/dumps/20160210_cybergeo.sqlite3')
