const fs = require('fs')
const relax = require('./libs/vororelax')
var name = "embed_2g_5d"

var w = 4000
var h = 4000
var pad0 = 20
var pad1 = 10

var vs = fs.readFileSync("output/"+name+".txt").toString().split("\n").filter(x=>x.length).map(x=>x.split(" ")).map(x=>[x[0],parseFloat(x[1]),parseFloat(x[2]),parseFloat(x[3]),parseFloat(x[4]),parseFloat(x[5])]);

var o = `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}">`
o += `<rect x="0" y="0" width="${w}" height="${h}" fill="rgb(10,20,30)"/>`

var mins = [Infinity,Infinity,Infinity,Infinity,Infinity]
var maxs = [-Infinity,-Infinity,-Infinity,-Infinity,-Infinity]

for (var i = 0; i < vs.length; i++){
	for (var j = 0; j < mins.length; j++){
		mins[j] = Math.min(mins[j],vs[i][j+1])
		maxs[j] = Math.max(maxs[j],vs[i][j+1])
	}
}
for (var i = 0; i < vs.length; i++){
	for (var j = 0; j < mins.length; j++){
		vs[i][j+1] = (vs[i][j+1]-mins[j])/(maxs[j]-mins[j]);
	}
	vs[i][1] = vs[i][1]*(w-pad0*2)+pad0
	vs[i][2] = vs[i][2]*(h-pad0*2)+pad0
}

var sites = relax.main(vs.map(x=>x.slice(1,3)),[pad1,pad1,w-pad1,h-pad1],16);
vs = sites.map((x,i)=>[vs[i],x.x,x.y,x.cell])

for (var i = 0; i < vs.length; i++){
	var [v,x,y,cell] = vs[i];
	o += `<path d="`
	for (var j = 0; j < cell.length; j++){
		// console.log(cell[j])
		o += j?'L':'M'
		o += cell[j][0]+" "+cell[j][1]+" "
	}
	o += `z" fill="none" stroke="white" opacity="0.1" stroke-width="0.2"/>`
}

for (var i = 0; i < vs.length; i++){
	var [v,x,y,cell] = vs[i];
	var [t,_0,_1,r,g,b] = v;

	// c = `rgba(${~~(Math.random()*200)},${~~(Math.random()*200)},${~~(Math.random()*200)},0.75)`
	c = `rgba(${~~(55+r*200)},${~~(55+g*200)},${~~(55+b*200)},0.75)`

	o += `<circle cx="${x}" cy="${y}" r="1" fill="${c}"/>`
	o += `<text text-anchor="middle" x="${x}" y="${y-2}" font-size="4" fill="${c}">${t}</text>`
}
o += `</svg>`
fs.writeFileSync("vis/"+name+".svg",o)

