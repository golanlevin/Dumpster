const fs = require('fs');
const umapjs = require('./libs/umap-js')

var vs = fs.readFileSync("output/vectors_2g.txt").toString().split("\n").slice(2).filter(x=>x.length).map(x=>x.split(' '))

var X = vs.map(x=>x.slice(1).filter(x=>x.trim().length).map(parseFloat).map(x=>x*10000))
// console.log(JSON.stringify(X.slice(0,10)))

var umap = new umapjs.UMAP({
	nComponents:5,
	// nNeighbors:50,
});
// var Y = umap.fit(X);
// console.log(Y)

const nEpochs = umap.initializeFit(X);
console.log(nEpochs)
for (let i = 0; i < nEpochs; i++) {
    console.log(i,'/',nEpochs)
    umap.step();
}
const Y = umap.getEmbedding();
var w = Y.map((x,i)=>vs[i][0]+" "+x.join(" "))	.join("\n");
console.log(w);
fs.writeFileSync("output/embed_2g_5d.txt",w);