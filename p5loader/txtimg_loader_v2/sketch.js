function setup(){
  createCanvas(800,400);
  setTimeout(loadClips,10);
}

function draw(){
  background(100);
  fill(255);
  text("loading...",100,100);

  stroke(0);
  strokeWeight(1);

  var idx = ~~(mouseY/4)*200+~~(mouseX/4);

  var filenames = Object.keys(Files);
  for (var i = 0; i < filenames.length; i++){
    fill(Files[filenames[i]]?(idx==i?255:150):50);
    rect((i%200)*4,~~(i/200)*4,4,4);
  }
  
  if (Files[filenames[idx]]){
    fill(255);
    text(Files[filenames[idx]],mouseX,mouseY);
  }else{
    fill(255);
    text(filenames[idx],mouseX,mouseY);
  }
}