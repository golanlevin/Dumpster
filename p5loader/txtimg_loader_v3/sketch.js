
//----------------------------------------
var nAssetsToLoad = 2; 
var textBigramUmapEmbeddings3D;
var loadingPeriodDuration = 3000; 
var loadingPeriodStartTime = 0; 
const textEmbeddingFilename = "assets/text_bigrams_umap_3d.tsv";


//----------------------------------------
function setup(){
  createCanvas(800,400);
  loadingPeriodStartTime = millis();
  setTimeout(loadAssets,loadingPeriodDuration);
}


//----------------------------------------
function loadAssets(){
  textBigramUmapEmbeddings3D = loadTable (textEmbeddingFilename, 'tsv', function(){nAssetsToLoad--;});
  loadClips (function(){nAssetsToLoad--;});
}


//----------------------------------------
function draw(){
  
  var bLoaded = ((nAssetsToLoad == 0) && (FILENAMES.length == 0));
  if (!bLoaded){
    drawWaitingForFilesToLoad();

  } else {
    background(100);
    fill(255);

    // var nPoints = textBigramUmapEmbeddings3D.getRowCount(); 
    // var px = textBigramUmapEmbeddings3D.getNum(i, 1);
    // var py = textBigramUmapEmbeddings3D.getNum(i, 2);
    

    var filenames = Object.keys(Files);
    var nFiles = filenames.length;
    var idx = floor(map(mouseX, 0, width, 0, nFiles));
    var breakupTextPath = filenames[idx];
    if (breakupTextPath){
      text(breakupTextPath,20,30);
      var breakupClip = Files[breakupTextPath];
      if (breakupClip){
        text(breakupClip,20,80);
      }
    }
  }
}


//----------------------------------------
function drawWaitingForFilesToLoad(){
  var elapsed = millis() - loadingPeriodStartTime;
  var elapsedFrac = constrain(map(elapsed, 0,loadingPeriodDuration, 0,1), 0,1);
  var bgCol = elapsedFrac * 255;
  background(bgCol, 0, 0);
  fill(255);
  text("loading...",100,100);
}