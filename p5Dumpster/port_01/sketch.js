
//----------------------------------------
let nAssetsToLoad = 11; 
let textBigramUmapEmbeddings3D;
let breakupSummaryLengths; 
let dumpsterImg;
let histbgImg;
let kamalFlags;
let languageData;
let languageTags;
let font6;
let accessThemes;
let breakupsPerDay2005;

var loadingPeriodDuration = 2000; 
var loadingPeriodStartTime = 0; 

//----------------------------------------
// Asset URLs and filenames
const textEmbeddingFilename         = "data/text_bigrams_umap_3d.tsv";
const dumpsterImageFilename         = "data/dumpster_1010x675.jpg";
const breakupSummaryLengthsFilename = "data/breakupSummaryLengths.dat";
const kamalFlagsFilename            = "data/kamalFlags.txt";
const languageDataFilename          = "data/languageData.txt";
const languageTagsFilename          = "data/languageTags.txt";
const font6Filename                 = "data/6px2bus.ttf";
const accessThemesFilename          = "data/accessThemes.tsv";
const breakupsPerDay2005Filename    = "data/breakupsPerDay2005.txt";
const histbgImageFilename           = "data/hist_1010x125.jpg";

//----------------------------------------
let DH; 




//----------------------------------------
function setup(){
  createCanvas (DUMPSTER_APP_W, DUMPSTER_APP_H);
  loadingPeriodStartTime = millis();
  setTimeout(loadAssets,loadingPeriodDuration);

  
}

//----------------------------------------
function loadAssets(){
  var bVerbose = true; 
  loadClips (function(){nAssetsToLoad--;});

  
  textBigramUmapEmbeddings3D = loadTable (textEmbeddingFilename, 'tsv', function(){
    if (bVerbose){ print("Loaded text embedding.");} nAssetsToLoad--;});
  dumpsterImg = loadImage (dumpsterImageFilename, function(){
    if (bVerbose){ print("Loaded main background image.");} nAssetsToLoad--;});
  histbgImg = loadImage (histbgImageFilename, function(){
    if (bVerbose){ print("Loaded secondary background image.");} nAssetsToLoad--;});
  accessThemes = loadTable(accessThemesFilename, "tsv", function(){
    if (bVerbose){ print("Loaded access themes.");} nAssetsToLoad--;});
  languageData = loadStrings(languageDataFilename, function(){
    if (bVerbose){ print("Loaded language data.");} nAssetsToLoad--;}); 
  languageTags = loadStrings(languageTagsFilename, function(){
    if (bVerbose){ print("Loaded language tags.");} nAssetsToLoad--;}); 
  kamalFlags = loadStrings(kamalFlagsFilename, function(){
    if (bVerbose){ print("Loaded flagset.");} nAssetsToLoad--;}); 
  breakupSummaryLengths = loadBytes (breakupSummaryLengthsFilename, function(){
    if (bVerbose){ print("Loaded breakup summary lengths.");} nAssetsToLoad--;});
  font6 = loadFont(font6Filename, function(){
    if (bVerbose){ print("Loaded pixel font.");} nAssetsToLoad--;});
  
  breakupsPerDay2005 = loadStrings(breakupsPerDay2005Filename, gotBreakupsPerDay2005);
}

//----------------------------------------
function gotBreakupsPerDay2005(bpd05){
  var bVerbose = true; 
  if (bVerbose){ 
    print("Loaded breakup timeline.");
  } 
  nAssetsToLoad--;
  var KOS = null; 
  DH  = new DumpsterHistogram (bpd05, 0, HEART_WALL_B, DUMPSTER_APP_W, HISTOGRAM_H, KOS);
}


//----------------------------------------
function draw(){
  
  var bLoaded = ((nAssetsToLoad == 0) && (FILENAMES.length == 0));
  if (!bLoaded){
    drawWaitingForFilesToLoad();

  } else {
    background(100);
    fill(255);

    // Background
    drawDumpsterBackground();

    // HeartManager
    /*
    HM.informOfMouse(mouseX, mouseY, mouseIsPressed);
    HM.mouseTestHearts();
    HM.updateHearts();
    HM.renderHeartObjects(); 
    HM.performScheduledShuffling();
    */

    // var nPoints = textBigramUmapEmbeddings3D.getRowCount(); 
    // var px = textBigramUmapEmbeddings3D.getNum(i, 1);
    // var py = textBigramUmapEmbeddings3D.getNum(i, 2);

    /*
    textFont (font6);
    textSize (12); // or 6
    */

    // "paragraphfont" is Georgia, which is web safe.
    textFont('Georgia'); 
    textStyle(ITALIC);
    textSize(10);

  
    var filenames = Object.keys(Files);
    var nFiles = filenames.length;
    var idx = int(floor(map(mouseX, 0, width, 0, nFiles)));
    var breakupTextPath = filenames[idx];
    if (breakupTextPath){
      text(breakupTextPath,20,30);
      text(breakupSummaryLengths.bytes[idx], 20, 50); 
      var breakupClip = Files[breakupTextPath];
      if (breakupClip){
        text(breakupClip,20,80);
      }
    }

    
    
    //}

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

//====================================================================
function drawDumpsterBackground() {
  background (0, 0, 0);
  image (dumpsterImg, HEART_WALL_L, HEART_WALL_T);
}