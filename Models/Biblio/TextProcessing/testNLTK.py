
## Test for text processing, stems extraction

import nltk

raw_text = open('data/corpus_example.txt').read()
#print(type(raw_text))
print('Raw Text : ',raw_text)

# Tokenize

tokens = nltk.word_tokenize(raw_text)
print('Words : ',len(tokens))

tokens_wordpunct = nltk.wordpunct_tokenize(raw_text)
print('Wordpunct : ',len(tokens_wordpunct))

text = nltk.Text(tokens)

# POS tagging ?

text.similar('simulation')

tagged = nltk.pos_tag(text)
print(tagged)

###########

# test stemmers

#porter = nltk.PorterStemmer()
#lancaster = nltk.LancasterStemmer()
#test the porter
#print([porter.stem(t) for t in tokens])
