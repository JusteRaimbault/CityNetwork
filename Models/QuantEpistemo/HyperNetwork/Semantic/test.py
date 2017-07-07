
import utils,stats#,kwExtraction
import nltk
import langdetect

#corpus = utils.corpus_from_csv('../data/NetworkTerritories/cit2_abstract.csv.csv',";")
#print(stats.corpus_languages('../data/UrbanGrowth/urbangrowth_depth2.csv'))
#print(stats.corpus_languages('../data/NetworkTerritories/cit2_abstract.csv.csv'))
# {'no': 0.0005698005698005698, 'pt': 0.005698005698005698, 'de': 0.011396011396011397, 'vi': 0.0002849002849002849,
#'hr': 0.0002849002849002849, 'en': 0.8712250712250712, 'da': 0.0008547008547008547, 'sl': 0.0002849002849002849,
#'ro': 0.0014245014245014246, 'it': 0.003703703703703704, 'ca': 0.002279202279202279, 'af': 0.0017094017094017094,
# 'es': 0.03219373219373219, 'tr': 0.0002849002849002849, 'pl': 0.0005698005698005698, 'so': 0.0005698005698005698,
# 'nl': 0.0019943019943019944, 'tl': 0.0011396011396011395, 'sv': 0.0002849002849002849, 'fr': 0.06324786324786325}

zh = '重要临港产业的空间分布特征及其临港偏好程度的差异性比较'
print(langdetect.detect(zh))
print(langdetect.detect_langs(zh))

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
