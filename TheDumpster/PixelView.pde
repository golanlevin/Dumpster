import java.text.DecimalFormat;
import java.text.NumberFormat;

class PixelView {

  TheDumpster  mom;
  BreakupManager BM;
  PixelIndexer	PIN;
  KnowerOfSelections KOS;

  boolean bMouseInView; 
  int mousePixelIndex;

  int keyOffsetX = 0;
  int keyOffsetY = 0; 

  int currentSelectedBreakupId;
  int currentMouseoverBreakupId;
  int pixelClickedBreakupId;
  int pixelIndexOfSelectedBupId;
  int pixelIndexOfMouseoverBupId;


  float hiliteXf;
  float hiliteYf;
  float hiliteMoXf;
  float hiliteMoYf;
  float moAlph;

  float myMouseX, myMouseY;

  PImage img;
  int nPixels;
  int pixels[];

  int rLUT[];
  int gLUT[];
  int bLUT[];

  int L, T, R, B, W, H;

  final int nmagX = 7;
  final int nmagY = 5;
  final int nmagP = nmagX*nmagY;
  final int nmagScale = 18;
  int magPixels[];

  private final NumberFormat NF = new DecimalFormat("00000");

  //=======================================================================
  public PixelView (TheDumpster m, BreakupManager bm, KnowerOfSelections kos) {
    mom = m;
    BM	 = bm;
    KOS = kos;

    myMouseX = myMouseY = 0;

    magPixels = new color[nmagP];
    for (int i=0; i<nmagP; i++) {
      magPixels[i] = color(0,0,0, 255);
    }


    hiliteXf = DUMPSTER_INVALID;
    hiliteYf = DUMPSTER_INVALID;

    hiliteMoXf = DUMPSTER_INVALID;
    hiliteMoYf = DUMPSTER_INVALID;
    moAlph = 1.0f;

    L = PIXELVIEW_L;
    T = PIXELVIEW_T;
    R = PIXELVIEW_L + PIXELVIEW_W;
    B = PIXELVIEW_T + PIXELVIEW_H;
    W = PIXELVIEW_W;
    H = PIXELVIEW_H;

    bMouseInView = false;
    mousePixelIndex = DUMPSTER_INVALID;
    currentSelectedBreakupId = DUMPSTER_INVALID;
    pixelIndexOfSelectedBupId = DUMPSTER_INVALID;

    img = new PImage(PIXELVIEW_W, PIXELVIEW_H);
    nPixels = PIXELVIEW_W * PIXELVIEW_H;
    pixels = new int[nPixels];
    for (int i=0; i<nPixels; i++) {
      pixels[i] = 0xFF000000;
    }
    
    constructLUTs();
    recalculate();
 
    PIN = new PixelIndexer(BM); // getting stuck here
  }
  //=======================================================================
  void constructLUTs() {
    rLUT = new int[256];
    gLUT = new int[256];
    bLUT = new int[256];

    float r0 = 0; 
    float r1 = 255;
    float rpow = 1.20f;

    float g0 = 16;
    float g1 = 190;
    float gpow = 2.50f; //2.50f;

    float b0 = 16;
    float b1 = 255 - MALE_BLUE_AMOUNT;
    float bpow = 2.60f;

    for (int i=0; i<256; i++) {
      float frac =  (float)i/255.0f;
      float r = r0 + (r1-r0)*(float)pow(frac, rpow); 
      float g = g0 + (g1-g0)*(float)pow(frac, gpow); 
      float b = b0 + (b1-b0)*(float)pow(frac, bpow);

      rLUT[i] = ((int)r); 
      gLUT[i] = ((int)g); 
      bLUT[i] = ((int)b);
    }
  }


  //=======================================================================
  void updateImage() {


    recalculate();
  }






  //=======================================================================
  void recalculate() {
    boolean bUseBogus = false;
    final int A = 0xFF000000;

    img.loadPixels();
    if (BM.currentlySelectedBreakupId == DUMPSTER_INVALID) {
      for (int i=0; i<nPixels; i++) {
        pixels[i] = A;
      }
    } 
    else {

      if (bUseBogus) {
        for (int i=0; i<nPixels; i++) {
          int r = (int)(random(0, 1)*255.0f);
          int g = (int)(random(0, 1)*255.0f);
          int b = (int)(random(0, 1)*255.0f);
          pixels[i] = (int) color(r, g, b);
        }
      } 
      else {

        int   MALES[]        = BM.MALES;
        float SIMILARITIES[] = BM.SIMILARITIES;

        // The ith cell of the lookup table PixelIndexToBupIndex, which represents a pixel loc,
        // contains the ID (index in the array) of an appropriately sorted Bup.

        short PixelIndexToBupIndex[] = PIN.PixelIndexToBupIndex;
        
        for (int i=0; i<nPixels; i++) {

          int bupIndex = PixelIndexToBupIndex[i];
          int c = (int)(255.0 * SIMILARITIES[bupIndex]);
          int m = MALES[bupIndex];
          

          int r =      (rLUT[c])<< 16;
          int g =      (gLUT[c])<< 8;
          int b = m +  (bLUT[c]);  


          pixels[i] = A + r + g + b;
        }
      }
    }

    img.pixels = pixels;
    img.updatePixels();
  }


  //=======================================================================
  void render() {


    updateSelectionInfo();
    updateMouseoverInfo();


    fill (255,255,255); 
    image(img, PIXELVIEW_L, PIXELVIEW_T, PIXELVIEW_W*PIXELVIEW_SCALE, PIXELVIEW_H*PIXELVIEW_SCALE);

    noFill();
    stroke(0);
    rect(PIXELVIEW_L-1, PIXELVIEW_T-1, PIXELVIEW_W*PIXELVIEW_SCALE+1, PIXELVIEW_H*PIXELVIEW_SCALE+1); 

    drawCurrentMouseoverBreakupId();
    drawCurrentSelectedBreakupId();

    renderMagnificationView();
  }





  //=======================================================================
  void renderMagnificationView() {
    int pid = DUMPSTER_INVALID;

    boolean bMouseover = false;
    if ((hiliteMoXf != DUMPSTER_INVALID) &&
      (pixelIndexOfMouseoverBupId < nPixels) && 
      (pixelIndexOfMouseoverBupId > DUMPSTER_INVALID)) {
      pid = pixelIndexOfMouseoverBupId;
      bMouseover = true;
    } 
    else if ((pixelIndexOfSelectedBupId < nPixels) && 
      (pixelIndexOfSelectedBupId > DUMPSTER_INVALID)) {
      pid = pixelIndexOfSelectedBupId;
    }


    if (pid != DUMPSTER_INVALID) {
    
        


      int xc = (pid % (int)PIXELVIEW_W);
      int yc = (pid / (int)PIXELVIEW_W);
      if (bMouseover) {
        int xi = ((pixelIndexOfMouseoverBupId+keyOffsetX)                       % (int)PIXELVIEW_W);
        int yi = ((pixelIndexOfMouseoverBupId+(keyOffsetY*PIXELVIEW_W))         / (int)PIXELVIEW_W);
        
        xc = xi;//// ((int)round(hiliteMoXf))%PIXELVIEW_W; // problem is here
        yc = yi;/// ((int)round(hiliteMoYf))%PIXELVIEW_H;
        
        xc = ((int)round(hiliteMoXf / PIXELVIEW_SCALE ))%PIXELVIEW_W; // problem is here
        yc = ((int)round(hiliteMoYf / PIXELVIEW_SCALE ))%PIXELVIEW_H;
      }


      int xMagStart = nmagScale -1;//8;
      int yMagStart = PIXELVIEW_H*PIXELVIEW_SCALE +nmagScale -1; // (int)(DUMPSTER_APP_H - HISTOGRAM_H + 8 + 30); //413; 443; 

      int col;
      int xp, yp, pindex;
      int yo = (int)(nmagY/2);
      int xo = (int)(nmagX/2);
      int xm, ym; // coords of magnified pixel

      noStroke(); 
      for (int y=0; y<nmagY; y++) {

        yp = yc+y-yo;
        if ((yp<0)||(yp>=PIXELVIEW_H)) { 
          // col = (int)(color(0,0,0));
          // no reason to draw, it was already blacked.
        } 
        else {
          for (int x=0; x<nmagX; x++) {
            xp = xc+x-xo;
            if ((xp<0) || (xp>=PIXELVIEW_W)) {
              ;
            } 
            else {
              pindex = yp*PIXELVIEW_W + xp;
              col = (int)pixels[pindex];
              fill(col); 

              // and draw that magnified pixel
              xm = xMagStart + nmagScale*x;
              ym = yMagStart + nmagScale*y;
              rect(xm, ym, nmagScale, nmagScale);
            }
          }
        }
      }

      // let's just ask the helpDisplayer for the color of its data field.
      HelpDisplayer HD = mom.HD;
      float rectR = HD.textr;
      float rectG = HD.textg;
      float rectB = HD.textb;

      // draw a colorful border
      pushMatrix();
      translate(xMagStart, yMagStart-1);
      
      noFill();
      stroke((int)(rectR*0.7), (int)(rectG*0.7), (int)(rectB*0.7));
      rect(0,0, 7*nmagScale, 5*nmagScale); //35.5f, 26);
      rect(-1,-1, 7*nmagScale + 2, 5*nmagScale+ 2);

      stroke(rectR, rectG, rectB);
      line(nmagScale*3.5, 0,           nmagScale*3.5, nmagScale*2);
      rect(nmagScale*3,   nmagScale*2, nmagScale, nmagScale);
      rect(nmagScale*3-1,   nmagScale*2-1, nmagScale+2, nmagScale+2);
      
      popMatrix(); 
    }
  }



  /* 
   	rect(x0,y0, magXs[x],magYs[y]);
   	x0 += magXs[x];
   							
   	static final int magXs[] = {2,3,4,5,7,5,4,3,2};
   	static final int magYs[] = {2,4,7,4,2};
   	*/

  //=======================================================================
  void sendArrowKey(int key) {
    if (bMouseInView) {
      switch (key) {
      case 10: // enter: so execute;
        returnPressed();
        break;

      case 37: // left arrow
        keyOffsetX -= 1;
        keyOffsetX = max(keyOffsetX, 0-(pixelIndexOfMouseoverBupId%PIXELVIEW_W));
        break;
      case 38: // up arrow
        keyOffsetY -= 1;
        keyOffsetY = max(keyOffsetY, 0-(pixelIndexOfMouseoverBupId/PIXELVIEW_W));
        break; 
      case 39: // right arrow
        keyOffsetX += 1; 
        keyOffsetX = min(keyOffsetX, PIXELVIEW_W-(pixelIndexOfMouseoverBupId%PIXELVIEW_W)-1);
        break;
      case 40:	// down arrow
        keyOffsetY += 1;
        keyOffsetY = min(keyOffsetY, PIXELVIEW_H-(pixelIndexOfMouseoverBupId/PIXELVIEW_W)-1);
        break;
      }
    }
  }

  //=======================================================================
  void drawCurrentMouseoverBreakupId () {
    if (hiliteMoXf != DUMPSTER_INVALID) {

      if ((pixelIndexOfMouseoverBupId < nPixels)) {
        if (pixelIndexOfMouseoverBupId > DUMPSTER_INVALID) {

          int xi = PIXELVIEW_SCALE* ((pixelIndexOfMouseoverBupId+keyOffsetX)                       % (int)PIXELVIEW_W);
          int yi = PIXELVIEW_SCALE* ((pixelIndexOfMouseoverBupId+(keyOffsetY*PIXELVIEW_W))         / (int)PIXELVIEW_W);

          //int xi = ((pixelIndexOfMouseoverBupId)  % (int)PIXELVIEW_W);
          //int yi = ((pixelIndexOfMouseoverBupId)  / (int)PIXELVIEW_W);

          float A = 0.675f;
          float B = 1.0f - A;
          hiliteMoXf = A*hiliteMoXf + B*(float)(xi);
          hiliteMoYf = A*hiliteMoYf + B*(float)(yi);
          if ((abs(hiliteMoXf-xi) < 3.0f) && (abs(hiliteMoYf-yi) < 3.0f)) {
            hiliteMoXf = xi;
            hiliteMoYf = yi;
          }

          //if ((hiliteMoXf == hiliteXf) && (hiliteMoXf == hiliteXf)){
          ;// if the mouseover == the clickon, dont bother drawing bluebox
          //} else {
          moAlph = 1.0f;
          fill(0, 0, 255, moAlph*48.0f);
          stroke(0, 0, 255);
          rect(hiliteMoXf-3.0f, hiliteMoYf-3.0f, 10, 10);
          noFill();
          rect(hiliteMoXf-4.0f, hiliteMoYf-4.0f, 12, 12);
          stroke(0, 0, 255, moAlph*50.0f);
          rect(hiliteMoXf-5.0f, hiliteMoYf-5.0f, 14, 14);
          //}
        } 
        else {
          moAlph *= HEART_BLUR_CA;
          if (moAlph > 0.035f) {
            fill(0, 0, 255, moAlph*48.0f);
            stroke(0, 0, 255, moAlph*255.0f);
            rect(hiliteMoXf-3.0f, hiliteMoYf-3.0f, 10, 10);
            noFill();
            rect(hiliteMoXf-4.0f, hiliteMoYf-4.0f, 12, 12);
            stroke(0, 0, 255, moAlph*50.0f);
            rect(hiliteMoXf-5.0f, hiliteMoYf-5.0f, 14, 14);
          }
        }
      }
    }
  }


  //=======================================================================
  void drawCurrentSelectedBreakupId () {
    if ((pixelIndexOfSelectedBupId != DUMPSTER_INVALID) && 
      (pixelIndexOfSelectedBupId >= 0) && 
      (pixelIndexOfSelectedBupId < nPixels)) {

      int xi = PIXELVIEW_SCALE* (pixelIndexOfSelectedBupId % PIXELVIEW_W);
      int yi = PIXELVIEW_SCALE* (pixelIndexOfSelectedBupId / (int)PIXELVIEW_W);

      hiliteXf = 0.65f*hiliteXf + 0.35f*(float)xi;
      hiliteYf = 0.65f*hiliteYf + 0.35f*(float)yi;
      if ((abs(hiliteXf-xi) < 3.0f) && (abs(hiliteYf-yi) < 3.0f)) {
        hiliteXf = xi;
        hiliteYf = yi;
      }

      noFill();
      stroke(255, 255, 0); // yellow
      rect(hiliteXf-3.0f, hiliteYf-3.0f, 10, 10);
      rect(hiliteXf-4.0f, hiliteYf-4.0f, 12, 12);
      rect(hiliteXf-5.0f, hiliteYf-5.0f, 14, 14);
      
      stroke(255, 100, 0); // orange
      rect(hiliteXf-6.0f, hiliteYf-6.0f, 16, 16);
      stroke(255, 100, 0, 100); // orange
      rect(hiliteXf-7.0f, hiliteYf-7.0f, 18, 18);
      
      stroke(255, 100, 0, 50); // orange
      line(hiliteXf-8.0f,  hiliteYf-6.0f, hiliteXf-8.0f,  hiliteYf+11.0f);
      line(hiliteXf+12.0f, hiliteYf-6.0f, hiliteXf+12.0f, hiliteYf+11.0f);
      line(hiliteXf-6.0f,  hiliteYf-8.0f,  hiliteXf+11.0f, hiliteYf-8.0f);
      line(hiliteXf-6.0f,  hiliteYf+12.0f, hiliteXf+11.0f, hiliteYf+12.0f);
    }
  }

  //=======================================================================
  void informOfMouse (float mx, float my, boolean pressed) {

    //mx = (int)mx * PIXELVIEW_SCALE;
    //my = (int)my * PIXELVIEW_SCALE;
    
    int mxi = (int)mx;
    int myi = (int)my;

    if (pressed == false) {
      if ((myMouseX != mx) || (myMouseY != my)) {
        keyOffsetX = 0;
        keyOffsetY = 0;
      }
    }
    myMouseX = mx;
    myMouseY = my;


    bMouseInView = false;
    mousePixelIndex = DUMPSTER_INVALID;
    if ((mxi/PIXELVIEW_SCALE >= L) && (mxi/PIXELVIEW_SCALE < R) && 
        (myi/PIXELVIEW_SCALE >= T) && (myi/PIXELVIEW_SCALE < B)) {
      bMouseInView = true;

      mousePixelIndex = (myi/PIXELVIEW_SCALE - PIXELVIEW_T)*PIXELVIEW_W  + (mxi/PIXELVIEW_SCALE - PIXELVIEW_L);
      mousePixelIndex = min(nPixels-1, max(0, mousePixelIndex)); 

      if (pressed == false) {
        if (	(mousePixelIndex != DUMPSTER_INVALID) && 
          (mousePixelIndex >= 0) && 
          (mousePixelIndex < nPixels)) {
          KOS.currentMouseoverBreakupId =  PIN.PixelIndexToBupIndex[mousePixelIndex];

          int offsetPindex = mousePixelIndex + keyOffsetX + (keyOffsetY*PIXELVIEW_W);
          offsetPindex = min(nPixels-1, max(0, offsetPindex)); 
          KOS.currentMouseoverBreakupIdWithOffset = PIN.PixelIndexToBupIndex[offsetPindex];
        }
      }
    } 
    else {

      // if the cursor is not in the pixel region
      if (KOS.currentMouseoverBreakupId == DUMPSTER_INVALID) {
        pixelIndexOfMouseoverBupId = DUMPSTER_INVALID;
      }
    }
  }


  //=======================================================================
  void returnPressed() {

    pixelClickedBreakupId = DUMPSTER_INVALID;

    if (KOS.currentMouseoverBreakupIdWithOffset != DUMPSTER_INVALID) {
      pixelClickedBreakupId = KOS.currentMouseoverBreakupIdWithOffset;
      if (pixelClickedBreakupId !=  DUMPSTER_INVALID) {
        /*
				int mindex = PIN.BupIndexToPixelIndex[pixelClickedBreakupId];
         				
         				int xi = ((mindex+  keyOffsetX) % (int)PIXELVIEW_W);
         				int yi = ((mindex+( keyOffsetY*PIXELVIEW_W)) / (int)PIXELVIEW_W);
         				hiliteXf = (float)xi;
         				hiliteYf = (float)yi;
         				hiliteMoXf = (float)xi;
         				hiliteMoYf = (float)yi;*/

        updateSelectionInfo();
        keyOffsetX = 0;
        keyOffsetY = 0;
      }
    }
  }

  //=======================================================================
  void mousePressed() {


    pixelClickedBreakupId = DUMPSTER_INVALID;

    if (mousePixelIndex != DUMPSTER_INVALID) {
      int curBupId = PIN.PixelIndexToBupIndex[mousePixelIndex];
      if ((curBupId != DUMPSTER_INVALID) && (curBupId < N_BREAKUP_DATABASE_RECORDS_20K)) {

        if (BM.bups[curBupId].VALID) {
          KOS.currentSelectedBreakupId  = curBupId;
          pixelClickedBreakupId = KOS.currentSelectedBreakupId; 

          int xi = (mousePixelIndex % (int)PIXELVIEW_W)*PIXELVIEW_SCALE;
          int yi = (mousePixelIndex / (int)PIXELVIEW_W)*PIXELVIEW_SCALE;
          hiliteXf = (float)xi;
          hiliteYf = (float)yi;
          hiliteMoXf = (float)xi;
          hiliteMoYf = (float)yi;

          updateSelectionInfo();
        }
      }
      keyOffsetX = 0;
      keyOffsetY = 0;
    }
  }

  //=======================================================================
  void updateSelectionInfo() {



    if ((KOS.currentSelectedBreakupId != currentSelectedBreakupId) && 
      (KOS.currentSelectedBreakupId >= 0) && 
      (KOS.currentSelectedBreakupId < nPixels) && 
      (KOS.currentSelectedBreakupId != DUMPSTER_INVALID)) {

      currentSelectedBreakupId = KOS.currentSelectedBreakupId;
      pixelIndexOfSelectedBupId = PIN.BupIndexToPixelIndex[currentSelectedBreakupId];
      //System.out.println("Here bupid = " + currentSelectedBreakupId + " pixid = " + pixelIndexOfSelectedBupId); 
      //System.out.println("HERE " + pixelIndexOfSelectedBupId) ;

      if (hiliteXf == DUMPSTER_INVALID) {
        int xi = (pixelIndexOfSelectedBupId % (int)PIXELVIEW_W);
        int yi = (pixelIndexOfSelectedBupId / (int)PIXELVIEW_W);
        hiliteXf = (float)xi;
        hiliteYf = (float)yi;
        keyOffsetX = 0;
        keyOffsetY = 0;
      }
    }
  }


  //=======================================================================
  void updateMouseoverInfo() {

    if ((KOS.currentMouseoverBreakupId != currentMouseoverBreakupId) && 
      (KOS.currentMouseoverBreakupId >= 0) && 
      (KOS.currentMouseoverBreakupId < nPixels) && 
      (KOS.currentMouseoverBreakupId != DUMPSTER_INVALID)) {

      currentMouseoverBreakupId = KOS.currentMouseoverBreakupId;
      pixelIndexOfMouseoverBupId = PIN.BupIndexToPixelIndex[currentMouseoverBreakupId];


      if (hiliteMoXf == DUMPSTER_INVALID) {
        int xi = (pixelIndexOfMouseoverBupId % PIXELVIEW_W);
        int yi = (pixelIndexOfMouseoverBupId / (int)PIXELVIEW_W);
        hiliteMoXf = (float)xi;
        hiliteMoYf = (float)yi;
      }
    }
  }

  //=======================================================================
  String getMouseString () {
    String out = "";
    if (bMouseInView && (mousePixelIndex != DUMPSTER_INVALID)) {
      if ((mousePixelIndex >= 0) && (mousePixelIndex < nPixels)) {
        int mouseBreakupIndex = PIN.PixelIndexToBupIndex[mousePixelIndex];

        // ID --------------------------------
        int id = BM.bups[mouseBreakupIndex].ID;
        String idString = NF.format(id);
        out += "ID: " + idString;
        out += '\n';

        // AGE --------------------------------
        int age = BM.bups[mouseBreakupIndex].age;
        out += "AGE: ";
        out += (age > 0) ? (""+age) : "N/A";
        out += '\n';

        // SEX --------------------------------
        int sex = BM.bups[mouseBreakupIndex].sex;
        out += "SEX: ";
        switch (sex) {
        case 2: 
          out += "M"; 
          break;
        case 1: 
          out += "F"; 
          break;
        default: 
        case 0: 
          out += "N/A"; 
          break;
        }
        out += '\n';

        // MATCH -------------------------------
        out += "MATCH: ";
        float SIMILARITIES[] = BM.SIMILARITIES;
        int match = (int)(100.0f * SIMILARITIES[mouseBreakupIndex]);
        out += match;
        out += '\n';
      }
    }
    return out;
  }
}

