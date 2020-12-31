function setup(){
  createCanvas(800,400);
  loadAll(/*batchSize=*/1000,/*callback=*/function(){
    console.log("loaded.");
  });
}

function draw(){
  background(100);
  stroke(0);
  strokeWeight(1);
  var idx = ~~(mouseY/4)*200+~~(mouseX/4);

  for (var i = 0; i < FILENAMES.length; i++){
    fill(Files[FILENAMES[i]]?(idx==i?255:150):50);
    rect((i%200)*4,~~(i/200)*4,4,4);
  }
  
  
  if (Files[FILENAMES[idx]]){
    fill(255);
    text(Files[FILENAMES[idx]],mouseX,mouseY);
  }
}