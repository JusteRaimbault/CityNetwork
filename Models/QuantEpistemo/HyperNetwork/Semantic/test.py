
import utils,stats#,kwExtraction
import nltk
from langdetect import detect

#corpus = utils.corpus_from_csv('../data/NetworkTerritories/cit2_abstract.csv.csv',";")
print(stats.corpus_languages('../data/UrbanGrowth/urbangrowth_depth2.csv'))




#print(corpus)

#kwExtraction.run_kw_extraction('../data/NetworkTerritories/test-extract.csv','../data/NetworkTerritories/test-extract.sqlite3')

#STOPWORDS_DICT = dict()
#for lang in nltk.corpus.stopwords.fileids():
#    print(lang)
# -> see how many languages are needed ; test ZH ?


## test sqlite
#ref = ['5883133859893048314','blabla']
#language='french'
#kwtext='kw1;kw2'
#query = "INSERT INTO refdesc (id,language,abstract_keywords,abstract) VALUES (\'"+ref[0]+"\',\'"+language+"\',\'"+kwtext+"\',\'"+ref[1]+"\');"# ON DUPLICATE KEY UPDATE language = VALUES(language),abstract_keywords=VALUES(abstract_keywords),abstract=VALUES(abstract);"
#print(query)
# initialisation
#initquery = "CREATE TABLE refdesc (id TEXT,language TEXT,abstract_keywords TEXT,abstract TEXT);"
#utils.insert_sqlite(initquery,'test/test.sqlite3')
#utils.insert_sqlite(query,'test/test.sqlite3')
