const fs = require('fs')
const relax = require('./libs/vororelax')
var name = "embed_text_2g"


var w = 4000
var h = 4000
var pad0 = 20
var pad1 = 10

var vs = fs.readFileSync("output/"+name+".txt").toString().split("\n").filter(x=>x.length).map(x=>x.split(" ")).map(x=>[x[0],parseFloat(x[1]),parseFloat(x[2]),parseFloat(x[3])]);

// vs = vs.slice(0,100)

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

var sites = relax.main(vs.map(x=>x.slice(1,3)),[pad1,pad1,w-pad1,h-pad1],36);
vs = sites.map((x,i)=>[vs[i],x.x,x.y,x.cell])

for (var i = 0; i < vs.length; i++){
	var [v,x,y,cell] = vs[i];
	o += `<path d="`
	for (var j = 0; j < cell.length; j++){
		// console.log(cell[j])
		o += j?'L':'M'
		o += cell[j][0]+" "+cell[j][1]+" "
	}
	o += `z" fill="rgb(10,20,30)" stroke="white" opacity="0.1" stroke-width="0.2" onmouseover="document.getElementById('t${i}').setAttribute('visibility','visible');this.setAttribute('fill','white')" onmouseout="document.getElementById('t${i}').setAttribute('visibility','hidden');this.setAttribute('fill','rgb(10,20,30)')"/>\n`
}

function wraptext(t,n=80){
	function oneline(t){
		var o = [];
		var words = t.split(" ");
		var line = "";
		for (var i = 0; i < words.length; i++){

			if ((line + words[i]).length <= n){
				line += " "+words[i];

			}else{
				o.push(line)
				line = words[i];
				if (line.length > n){
					var a = line.slice(0,n-1);
					var b = line.slice(n-1);
					o.push(a+"-");
					line = b;
				}
			}
		}
		if (line.length){
			o.push(line)
		}
		return o
	}
	var o = t.split("\n").map(x=>x.trim()).map(oneline);
	return o.flat().map(x=>x.trim());
}
function tspantext(t,n=80){
	var lines = wraptext(t,n);
	var o = ``;
	for (var i = 0; i < lines.length; i++){
		o += `<tspan x="0" dy="8">${lines[i]}</tspan>`
	}
	return o;
}

for (var i = 0; i < vs.length; i++){
	var [v,x,y,cell] = vs[i];
	var [t,_0,_1,r] = v;
	tt = t.replace("text/",'').replace(".txt",'');

	var f = fs.readFileSync(t).toString();
	// f = f.replace(/&/g,"&amp;")
	// f = f.replace(/</g,"&lt;")
	// f = f.replace(/>/g,"&gt;")
	f = f.replace(/[^A-z0-9 ]/g,"-")
	f = t+"\n"+f;


	// c = `rgba(${~~(Math.random()*200)},${~~(Math.random()*200)},${~~(Math.random()*200)},0.75)`
	c = `rgba(${~~(r*255)},${~~(255-r*255)},${255},0.75)`

	o += `<circle cx="${x}" cy="${y}" r="1" fill="${c}" pointer-events="none"/>`
	// o += `<text text-anchor="middle" x="${x}" y="${y-2}" font-size="4" fill="${c}" pointer-events="none">${tt}</text>`
	o += `<g transform="translate(${x} ${y})" visibility="hidden" id="t${i}"><text x="0" y="0" font-size="8" fill="white" font-family="monospace" pointer-events="none">${tspantext(f)}</text></g>`
}
o += `</svg>`
fs.writeFileSync("vis/"+name+".svg",o)

