// Written for Processing 2.0b7
// Works in Processing 3.5.4, October 2020
// Be sure to uncompress the archive text.zip in data/


PImage 	 dumpsterimg;
boolean  bUseDumpsterImg;
PFont    font6;



KnowerOfSelections	       KOS;
ParagraphBalloonManager    PBM;
HeartManager               HM;
HeartBalloonConnector      HBC;
DumpsterHistogram          DH;
BreakupManager             BM;
PixelView                  PV;
HelpDisplayer              HD;

long lastGarbageCollectionTime;


//====================================================================
void settings(){
  size ((int)DUMPSTER_APP_W, (int)DUMPSTER_APP_H); // (1280,800)
}

//====================================================================
void setup() {
  

  lastGarbageCollectionTime = millis();
  bUseDumpsterImg = true;
  if (bUseDumpsterImg) {
    switch ((int)DUMPSTER_APP_W) {
    case 1280:
      // dumpsterimg = loadImage("dumpster_980x600.jpg");
      dumpsterimg = loadImage("dumpster_1010x675.jpg");
      break;

    case 1024: 
      dumpsterimg = loadImage("dumpster_972x689.jpg");
      break;

    case 640: 
    default: 
      dumpsterimg = loadImage("dumpster_972x689.jpg");
      break;
    }
  }

  font6 = loadFont("6px2bus24.vlw"); // fonts by 010BUS.
  KOS = new KnowerOfSelections();
  BM  = new BreakupManager();
  HM  = new HeartManager(KOS, BM, this);
  PBM = new ParagraphBalloonManager(); 
  HBC = new HeartBalloonConnector (PBM, HM);
  DH  = new DumpsterHistogram (font6, 0, HEART_WALL_B, DUMPSTER_APP_W, HISTOGRAM_H, KOS);

  PV  = new PixelView (this, BM, KOS); // freezing here. 
  HD  = new HelpDisplayer (font6, BM, KOS);
}

//====================================================================
void draw() {

  garbageCollectIfNecessary();

  // Background
  drawDumpsterBackground();

  // HeartManager
  HM.informOfMouse(mouseX, mouseY, mousePressed);
  HM.mouseTestHearts();
  HM.updateHearts();
  HM.renderHeartObjects(); 
  HM.performScheduledShuffling();

  // ParagraphBalloonManager
  PBM.informOfMouse(mouseX, mouseY, mousePressed);
  PBM.render(); 

  // HeartBalloonConnector
  HBC.renderConnections(); 

  // DumpsterHistogram
  DH.informOfMouse(mouseX, mouseY, mousePressed);
  DH.loop();

  // PixelView
  PV.informOfMouse(mouseX, mouseY, mousePressed);
  PV.render();

  // HelpDisplayer
  HD.update(mouseX, mouseY);
  HD.render();

  autoPlay();
}



//====================================================================
long lastInteractionTime = 0; 
void autoPlay() {
  long now = millis(); 
  long elapsed = now - lastInteractionTime;
  if (elapsed  > DUMPSTER_LONELY_TIME) {

    boolean bDoIt = (random(0, 1) < 0.01);
    if (bDoIt) {

      int randomId = (int) random(N_BREAKUP_DATABASE_RECORDS_20K);
      if (BM.bups[randomId].VALID) {
        HM.decimateCurrentHeartPopulation();
        int heartId = HM.addSelectedBreakupFromOutsideAndGetNewHeartId (randomId);
        enactSelectionOfExistingHeartAcrossDumpster (heartId);
      }
    }
  }
}
//====================================================================
void drawDumpsterBackground() {
  background (0, 0, 0);//64,64,64);
  if (bUseDumpsterImg) {
    //int bgw = (int)(DUMPSTER_APP_W - HEART_WALL_L);
    //int bgh = (int)(DUMPSTER_APP_H - HISTOGRAM_H); 
    image(dumpsterimg, HEART_WALL_L, HEART_WALL_T);//, bgw, bgh);
  }
}


//====================================================================
void keyPressed() {
  PV.sendArrowKey((int)key);
  lastInteractionTime = millis(); //DUMPSTER_LONELY_TIME

  if ((key == 10) && (PV.bMouseInView)) {
    int pixelClickedBreakupId = PV.pixelClickedBreakupId;
    if (BM.bups[pixelClickedBreakupId].VALID) {
      HM.decimateCurrentHeartPopulation();
      int heartId = HM.addSelectedBreakupFromOutsideAndGetNewHeartId (pixelClickedBreakupId);
      enactSelectionOfExistingHeartAcrossDumpster (heartId);
    }
  }
}

void mouseMoved() {
  lastInteractionTime = millis(); //DUMPSTER_LONELY_TIME
}

//====================================================================
void mousePressed() {

  lastInteractionTime = millis(); //DUMPSTER_LONELY_TIME

  HM.mousePressed();
  PV.mousePressed();
  int mouseClickedHeartID   = HM.mouseClickedHeartID;
  int pixelClickedBreakupId = PV.pixelClickedBreakupId;

  if 		((mouseClickedHeartID   != DUMPSTER_INVALID) &&
    (pixelClickedBreakupId == DUMPSTER_INVALID)) {
    // If the selection action came from the HeartManager, base the change from that
    enactSelectionOfExistingHeartAcrossDumpster (mouseClickedHeartID);
  } else if 	((mouseClickedHeartID   == DUMPSTER_INVALID) &&
    (pixelClickedBreakupId != DUMPSTER_INVALID)) {
    // If the selection action came from the PixelView, base the change from that
    if (BM.bups[pixelClickedBreakupId].VALID) {
      HM.decimateCurrentHeartPopulation();
      int heartId = HM.addSelectedBreakupFromOutsideAndGetNewHeartId (pixelClickedBreakupId);
      enactSelectionOfExistingHeartAcrossDumpster (heartId);
    }
  }
}



//====================================================================
void enactSelectionOfExistingHeartAcrossDumpster (int heartId) {

  if ((heartId != DUMPSTER_INVALID) && 
    (heartId >= 0) && (heartId < MAX_N_HEARTS)) {

    int correspondingBreakupId = HM.hearts[heartId].breakupId;
    if (correspondingBreakupId != DUMPSTER_INVALID) {
      PBM.execute(correspondingBreakupId, heartId);
      BM.informOfNewlySelectedBreakup(correspondingBreakupId);
      HM.refreshHeartColors(BM, correspondingBreakupId);
      PV.updateImage();
    }
  }
}



//====================================================================
void mouseReleased() {
  HM.mouseReleased();

  lastInteractionTime = millis(); //DUMPSTER_LONELY_TIME
}

//====================================================================
void garbageCollectIfNecessary() {
  int now = millis();
  if ((now - lastGarbageCollectionTime) > 20000) {
    System.gc();
    lastGarbageCollectionTime = now;
  }
}
