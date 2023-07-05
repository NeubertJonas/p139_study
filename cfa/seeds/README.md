# Seed Words

Twelve seed words were selected for the CFA; Four each with emotional, abstract, and neutral connotation.
Selection was based on [LexOPS by Jack Taylor](https://jackedtaylor.github.io/LexOPSdocs/), which contains an English-language database of words and their attributes based on different studies.

## Variables

The following variables were used:

| Variable | Description | Source |
| -------- | ----------- | ------ |
| PoS.SUBTLEX_UK | Dominant parts of speech according to SUBTLEX-UK | https://doi.org/10.1080/17470218.2013.850521 |
| Zipf.SUBTLEX_UK | Zipf frequencies `(log10(frequency_per_million)+3)` calculated from UK subtitles | https://doi.org/10.1080/17470218.2013.850521 |
| AROU.Glasgow_Norms | Arousal ratings (1-9; less-more) from the Glasgow Norms | http://doi.org/10.3758/s13428-018-1099-3 |
| CNC.Glasgow_Norms | Concreteness ratings (1-7; low-high) from the Glasgow Norms | http://doi.org/10.3758/s13428-018-1099-3 |
| VAL.Glasgow_Norms | Valence ratings (1-9; more negative-more positive) from the Glasgow Norms | http://doi.org/10.3758/s13428-018-1099-3 |

For the other variables available in LexOPS, [see here](https://rdrr.io/github/JackEdTaylor/LexOPS/man/lexops.html).

SUBTLEX_UK, a database based on British TV/movie subtitle data, was chosen because it features more colloquially used words than other (for example, literature-based) datasets.

More information about the Glasgow Norms can be found in the supplementary material, such as the [Instructions for Rating Tasks](https://static-content.springer.com/esm/art%3A10.3758%2Fs13428-018-1099-3/MediaObjects/13428_2018_1099_MOESM1_ESM.pdf) and the complete [Glasgow Norms dataset](https://static-content.springer.com/esm/art%3A10.3758%2Fs13428-018-1099-3/MediaObjects/13428_2018_1099_MOESM2_ESM.csv).

### Limitation

In comparison to the full Glasgow Norms dataset (5.500 entries), LexOPS does not differentiate when a word has multiple meanings.
For example, the word "bar" features five entries in the Glasgow Norms: "bar", "bar (legal)", "bar (metal)", "bar (musical)", "bar (pub)" with distinct ratings.
LexOPS contains a simplified selection of the Glasgow Norms by only including "bar" (i.e., the ratings participants provided for this word when the meaning was not specified).

## Selection Procedure

The LexOPS dataset (containing 262.532 entries) was first narrowed down by only selecting nouns (`PoS.SUBTLEX_UK == "noun"`) and words from the Glasgow Norms dataset, resulting in a smaller dataset of 2.945 words.
Afterwards, the ratings for arousal, valence, and concreteness were used to identify three subsets based on the following criteria:

| Subset | Criteria | Number of Words |
| --- | --- | ---- |
| Emotional | High in valence and arousal; Concreteness above average (to differentiate from abstract words) | 284 |
| Abstract | Average valence and arousal; Low in concreteness (i.e., high in abstractness) | 60 |
| Neutral | Average valence and arousal; Concreteness above average | 45 |

Finally, all items were sorted by word frequency (Zipf.SUBTLEX_UK) and two researchers selected suitable words from the high-ranking results.

## Results

| Subset    | Seeds |
| ------    | ---   |
| Emotional | world, people, mother, father |
| Abstract  | mood, illusion, pride, time |
| Neutral   | taxi, jacket, boot, tower |
