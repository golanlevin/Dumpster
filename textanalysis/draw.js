const fs = require('fs')
const relax = require('./libs/vororelax')
var name = "embed_2g"
var wname = "word_2g"
var w = 3000
var h = 3000
var pad0 = 20
var pad1 = 10

function hsv2rgb(e,a,r){let c,s,b,t,k,n,u,f,i;if(0==a)return[255*(c=r),255*(s=r),255*(b=r)];switch((t=e)>360&&(t=0),u=r*(1-a),f=r*(1-a*(n=(t/=60)-(k=~~t))),i=r*(1-a*(1-n)),k){case 0:c=r,s=i,b=u;break;case 1:c=f,s=r,b=u;break;case 2:c=u,s=r,b=i;break;case 3:c=u,s=f,b=r;break;case 4:c=i,s=u,b=r;break;default:c=r,s=u,b=f}return[255*c,255*s,255*b]}

var vs = fs.readFileSync("output/"+name+".txt").toString().split("\n").filter(x=>x.length).map(x=>x.split(" ")).map(x=>[x[0],parseFloat(x[1]),parseFloat(x[2])]);
var ws = Object.fromEntries(fs.readFileSync("output/"+wname+".txt").toString().split("\n").filter(x=>x.length).map(x=>x.split("\t")).map((x,i)=>[x[0],i]))
var o = `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}">`
o += `<rect x="0" y="0" width="${w}" height="${h}" fill="rgb(10,20,30)"/>`
var xmin = Infinity
var ymin = Infinity
var xmax = -Infinity
var ymax = -Infinity
for (var i = 0; i < vs.length; i++){
	var [t,x,y] = vs[i];
	xmin = Math.min(xmin,x);
	xmax = Math.max(xmax,x);
	ymin = Math.min(ymin,y);
	ymax = Math.max(ymax,y);
}
for (var i = 0; i < vs.length; i++){
	vs[i][1] = (vs[i][1]-xmin)/(xmax-xmin)*(w-pad0*2)+pad0
	vs[i][2] = (vs[i][2]-ymin)/(ymax-ymin)*(h-pad0*2)+pad0
}

var sites = relax.main(vs.map(x=>x.slice(1)),[pad1,pad1,w-pad1,h-pad1],16);
vs = sites.map((x,i)=>[vs[i][0],x.x,x.y,x.cell])

for (var i = 0; i < vs.length; i++){
	var [t,x,y,cell] = vs[i];
	o += `<path d="`
	for (var j = 0; j < cell.length; j++){
		// console.log(cell[j])
		o += j?'L':'M'
		o += cell[j][0]+" "+cell[j][1]+" "
	}
	o += `z" fill="none" stroke="white" opacity="0.1" stroke-width="0.2"/>`
}

for (var i = 0; i < vs.length; i++){
	var [t,x,y,cell] = vs[i];

	var s = ((ws[t]??vs.length)/vs.length);
	var ch = hsv2rgb(~~(s*210),0.5+s*0.5,1.0-s*0.5);

	// c = `rgba(${~~(Math.random()*200)},${~~(Math.random()*200)},${~~(Math.random()*200)},0.75)`
	c = `rgba(${~~ch[0]},${~~ch[1]},${~~ch[2]},0.75)`

	o += `<circle cx="${x}" cy="${y}" r="1" fill="${c}"/>`
	o += `<text text-anchor="middle" x="${x}" y="${y-2}" font-size="4" fill="${c}">${t}</text>`
}
o += `</svg>`
fs.writeFileSync("vis/"+name+".svg",o)

