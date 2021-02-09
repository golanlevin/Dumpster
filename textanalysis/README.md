Materials related to the revised (2020-21) analysis and loading of Dumpster texts. 

For text analysis, run in this order:

- `words.py` (`proc1()`) extract words from the corpus.
- `ngrams.py` (`proc1()`) extract n-grams from the corpus
- `w2v_runner.sh` run word2vec on the extracted words/n-grams
- `words.py` (`proc2()`) generate vector for each text clip from vector of the words it contains
- `ngrams.py` (`proc2()`) generate vector for each text clip from vector of the ngrams it contains
- `matrix.py` generate distance matrix for the text clips, encoding PNG
- `checkloss.py` check how much the PNG encoding of the distance matrix deviate from true values
- `embed.js` dimensionality reduction for the vectors, using UMAP
- `draw.js` generate SVG visualization of the embedding
- `draw_5d.js` generate SVG visualization of 5-dimensional embedding (RGBXY)

Explanation:

word2vec computes a 128 dimensional vector from each word in the corpus. For each text clip, the vectors of each word are averaged, using just simple mean. Each text clip is now also represented by a 128 dimensional vector. Run UMAP on these vectors, to embed the text clips into desired dimensions.


For encoding text as image for loading into the display, run in this order:

- encode all text clips into single image
    - first algorithm: `text2img.py`. The algorithm encodes 63 alphanumeric characters with 6 bits, and symbols with 12 bits.
    - alternatively, second algorithm: `text2img2.py`. The algorithm uses either 1 or 2 or many bytes for each word, based word frequency in the corpus. It also outputs a `text2_words.txt` that lists the words by frequency, required to decode the image.
- `check_text2img.py` load and print the image to see if it looks alright.


Who output who:
|script|output|
|---|---|
|`draw_5d.js`|`vis/embed(.+?)_5d.svg` based on `name` variable|
|`draw_text.js`|`vis/embed_text.svg`|
|`draw.js`|`vis/embed_([^_]+?).svg` based on `name` variable|
|`embed.js`|`output/embed_*.txt` based on last line|
|`matrix.py`|`output/distmat.png`(deprecated) `output/distmat_sqrt.png`|
|`ngrams.py proc1()`|`output/corp_2g.txt` `output/word_2g.txt`|
|`ngrams.py proc2()`|`output/vect_2g.txt`|
|`text2img.py`|`output/text.png`|
|`w2v_runner.sh`|`output/vectors.txt` or `output/vectors_2g.txt`|
|`words.py proc1()`|`output/corp.txt` `output/word.txt`|
|`words.py proc2()`|`output/vect.txt`|
|`https://pngquant.org/`|`output/distmat_quant.png` `output/distmat_sqrt_quant.png`|


For cleaning up html garbage in the text, unzip text.zip, put it in this folder, duplicate it, rename the duplicate to `text_cleaned` and run `cleanup.py`.

---

* textanalysis/output/vect.txt is the coordinate of each clip
* embed_text.txt is the umap embedding of each clip
embed_text_2g is the umap embedding of 2 grams of each clip


