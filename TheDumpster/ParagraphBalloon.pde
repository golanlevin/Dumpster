
//==================================================================
class ParagraphBalloon {

  Paragraph myParagraph;
  int   breakupId;
  int   heartId;

  PFont paraFont;
  float px, py;
  float pw, ph;
  float targety;

  float rad;
  float margL, margR;
  float margT, margB;
  float paragraphWidth;

  boolean b_prepared;
  boolean b_drawShadow;
  boolean b_correspondingHeartIsMousedOver;
  boolean bIsCurrentBalloonIndex; 
  boolean b_stillLoading;
  boolean bNewTextAppeared;

  private static final boolean b_useRect = true;
  static final float BALLOON_SHADOW_OFFSET = 3;

  int textColor;
  int bodyColor;
  int edgeColor;
  int shadColor;
  float balloonAlpha;
  float balloonAlphaTarget;
  float balloonAlpha2;
  float balloonAlphaTarget2;

  float balloonPoly[][];
  
  //--------------------------------
  public ParagraphBalloon () {

    b_prepared   = false;
    b_drawShadow = true;
    bIsCurrentBalloonIndex = false;
    b_correspondingHeartIsMousedOver = false;
    b_stillLoading = true;
    bNewTextAppeared = false;

    myParagraph  = new Paragraph();
    breakupId	  = DUMPSTER_INVALID;
    heartId 	  = DUMPSTER_INVALID;

    py = BALLOON_START_Y;
    pw = BALLOON_W;
    px = BALLOON_X;
    ph = 64;
    targety = py;

    margL = 12;
    margR = 15; 
    margT = 17;
    margB = 0;
    paragraphWidth = pw - (margL+margR);

    textColor = color (0, 0, 0);
    bodyColor = color (BALLOON_BODY_R, BALLOON_BODY_G, BALLOON_BODY_B);
    edgeColor = color (192, 150, 150);
    shadColor = color (  0, 0, 0, 50);

    balloonAlpha = 0.0f;
    balloonAlphaTarget = 0.0f;
    balloonAlpha2 = 0.0f;
    balloonAlphaTarget2 = 0.0f;

    if (!b_useRect) { 
      rad = 10;
      balloonPoly = new float[16][2];
    }
  }

  //--------------------------------
  public void setFont (PFont pF) {
    paraFont = pF;
  }

  //--------------------------------
  public void setStringAndComputeLayout ( String aBreakupString, int bid, boolean bOnlyLoading) {
    breakupId = bid;
    myParagraph.setStringAndComputeLayout (aBreakupString, paraFont, paragraphWidth); 
    int nLines  = myParagraph.nLines;
    int leading = myParagraph.myLeading;
    float paraHeight = (nLines)*leading;
    ph = (float)ceil(paraHeight + margT + margB);

    b_prepared = true;

    if (bOnlyLoading) {
      b_stillLoading = true;
      balloonAlpha  = 0.0f;
      balloonAlpha2 = 0.0f;
    } 
    else {
      b_stillLoading = false;
    }

    bNewTextAppeared = true;
  }

  //--------------------------------
  public void informOfCurrency (boolean c) {
    bIsCurrentBalloonIndex = c;
  }



  //--------------------------------
  public void setPositionY (float y) {
    py = y;
    targety = y;
  }

  public void setTargetY (float y) {
    targety = y;
  }

  public void updatePositionY () {
    py = 0.8f*py + 0.2f*targety;
    if (abs(py - targety) < 1.0f) {
      py = targety;
    }
  }



  //--------------------------------
  public void render (boolean mouseIsOver) {

    if (b_prepared) {


      int bcr = BALLOON_BODY_R;
      int bcg = BALLOON_BODY_G;
      int bcb = BALLOON_BODY_B;

      int tcr = (int) red  (textColor);
      int tcg = (int) green(textColor);
      int tcb = (int) blue (textColor);
      int cornerCol = (int) color(60,30,30); //103, 68, 68); 

      if (mouseIsOver) { 
        tcr = 32;
      }


      float pyfrac = (py - HEART_WALL_T) / HEART_AREA_H;
      if ((pyfrac < 1.0f) && (pyfrac >= 0.0)) {

        float dh = min(ph, HEART_WALL_B - py);

        pyfrac = 1.0f - pyfrac;
        float ball_alp = (float)(255.0f * pow(pyfrac, 0.625f));
        float text_alp = (float)(255.0f * pow(pyfrac, 0.050f));
        if (mouseIsOver || b_correspondingHeartIsMousedOver) { 
          ball_alp = min(255, ball_alp + BALLOON_OVER_ALPDELTA);
          if (b_stillLoading == false) {
            balloonAlpha = ball_alp;
          }
        }
        balloonAlphaTarget = ball_alp;
        balloonAlpha = BALLOON_ALP_BLURA*balloonAlpha + BALLOON_ALP_BLURB*balloonAlphaTarget;
        int alpi = (int)round(balloonAlpha);


        if (BALLOON_FADE_QUADS == false) {
          // draw the balloons as a solid field

          boolean BALLOON_SOLID_QUADS = false;
          if (BALLOON_SOLID_QUADS) {
            fill (bcr, bcg, bcb);
          } 
          else {
            if (alpi >= 254) {
              fill (bcr, bcg, bcb);
            } 
            else {
              fill (bcr, bcg, bcb, alpi);
            }
          }

          rect(px, py, pw, dh);
        } 
        else {
          // draw the balloons as a fading field, which is more complicated.
          float qyfrac = 1.0f - ((py+dh) - HEART_WALL_T) / HEART_AREA_H;
          float ball_alq = (float)(255.0f * pow(qyfrac, 0.625f));
          if (mouseIsOver || b_correspondingHeartIsMousedOver) { 
            ball_alq = min(255, ball_alq + BALLOON_OVER_ALPDELTA);
            if (b_stillLoading == false) {
              balloonAlpha2 = ball_alq;
            }
          }
          balloonAlphaTarget2 = ball_alq;
          balloonAlpha2 = BALLOON_ALP_BLURA*balloonAlpha2 + BALLOON_ALP_BLURB*balloonAlphaTarget2;
          int alpi2 = (int)round(balloonAlpha2);

          if ((alpi >= 254) && (alpi2 >= 254)) {
            fill (bcr, bcg, bcb);
            rect(px, py, pw, dh);
          } 
          else {
            beginShape(QUADS);
            fill (bcr, bcg, bcb, alpi);
            vertex(px, py);
            vertex(px+pw, py);
            fill (bcr, bcg, bcb, (int)balloonAlpha2);
            vertex(px+pw, py+dh);
            vertex(px, py+dh);
            endShape();
          }
        }

        // draw the balloon's shadow
        float sy = py+dh;
        if ((sy < HEART_WALL_B) && b_drawShadow) {
          fill(shadColor);
          rect(px, sy, BALLOON_SHADOW_OFFSET, 1);
          rect(px+BALLOON_SHADOW_OFFSET, sy, pw-BALLOON_SHADOW_OFFSET, BALLOON_SHADOW_OFFSET);
          if (false) { // draw right-hand shadow. not worth it.
            rect(px+pw, py+BALLOON_SHADOW_OFFSET, BALLOON_SHADOW_OFFSET, dh);
          }
        }

        // draw the paragraph of text
        fill (tcr, tcg, tcb, text_alp);
        myParagraph.render(px + margL, py + margT);

        // draw little points on the corners to make it appear rounded\
        float pyf = py-0.5f;//(bIsCurrentBalloonIndex) ? py+0.5f : py;
        stroke(cornerCol);
        
        point(px, pyf);
        point(px+pw-1, pyf); 
        point(px+pw-1, pyf+dh-1);
        point(px, pyf+dh-1);
        noStroke();
      }
    }
  }



  /*
	
   	else {
   				// no longer supported.
   				push();
   				translate(px, py); 
   
   					if (b_drawShadow){
   						push();
   						translate(BALLOON_SHADOW_OFFSET,BALLOON_SHADOW_OFFSET,-0.1f);
   						fill (shadColor);  // draw shadow
   						noStroke();
   						beginShape(POLYGON);
   						for (int i=0; i<16; i++) {
   							vertex(balloonPoly[i][0], balloonPoly[i][1]);
   						}
   						endShape();
   						pop();
   					}
   
   					push();
   						translate(0,0,-0.1f);
   						int alp = (int)(255-py);
   						fill   (bcr, bcg, bcb, alp);
   						stroke (edgeColor);
   						beginShape(POLYGON);
   						for (int i=0; i<16; i++) {
   							vertex(balloonPoly[i][0], balloonPoly[i][1]);
   						}
   						endShape();
   					pop();
   					
   					push();
   					translate(0,0, 1.01f);
   						fill (textColor);
   						myParagraph.render(margL, margT);
   					pop();
   					
   				pop();
   			}
   			
   	  if (!b_useRect) cachePoly(); 
   		 
   	  private void cachePoly(){
   		float r = rad;
   		float s3 = (float)(r * sin(30.0*DEG_TO_RAD));
   		float s6 = (float)(r * sin(60.0*DEG_TO_RAD));
   		balloonPoly[ 0][0] = r;         
   		balloonPoly[ 0][1] = 0;
   		balloonPoly[ 1][0] = pw-r;      
   		balloonPoly[ 1][1] = 0;
   		balloonPoly[ 2][0] = pw-r+s3;   
   		balloonPoly[ 2][1] = r-s6;
   		balloonPoly[ 3][0] = pw-r+s6;   
   		balloonPoly[ 3][1] = r-s3;
   		balloonPoly[ 4][0] = pw;        
   		balloonPoly[ 4][1] = r;
   		balloonPoly[ 5][0] = pw;        
   		balloonPoly[ 5][1] = ph-r;
   		balloonPoly[ 6][0] = pw-r+s6;   
   		balloonPoly[ 6][1] = ph-r+s3;
   		balloonPoly[ 7][0] = pw-r+s3;   
   		balloonPoly[ 7][1] = ph-r+s6;
   		balloonPoly[ 8][0] = pw-r;      
   		balloonPoly[ 8][1] = ph;
   		balloonPoly[ 9][0] = r;         
   		balloonPoly[ 9][1] = ph;
   		balloonPoly[10][0] = r-s3;      
   		balloonPoly[10][1] = ph-r+s6;
   		balloonPoly[11][0] = r-s6;      
   		balloonPoly[11][1] = ph-r+s3;
   		balloonPoly[12][0] = 0;         
   		balloonPoly[12][1] = ph-r;
   		balloonPoly[13][0] = 0;         
   		balloonPoly[13][1] = r;
   		balloonPoly[14][0] = r-s6;      
   		balloonPoly[14][1] = r-s3;
   		balloonPoly[15][0] = r-s3;      
   		balloonPoly[15][1] = r-s6;
   }
   */
}



/*
  // Thank god java works
 println("---------");
 Object oarray[] = new Object[3];
 for (int i=0; i<3; i++){
 	 oarray[i] = new Object();
 	 println(oarray[i]);
 }
 println("-----");
 Object o1 = oarray[1];
 oarray[1] = oarray[2];
 oarray[2] = o1;
 for (int i=0; i<3; i++){
 	 println(oarray[i]);
 }
 */
