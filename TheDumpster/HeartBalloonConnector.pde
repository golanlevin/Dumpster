

class HeartBalloonConnector {

  ParagraphBalloonManager PBM;
  HeartManager            HM;

  int nBezSegments;
  int nBezPoints;
  float SPLINE_BIAS;
  float bt[];
  float bt2[];
  float bt3[];
  float onemt[];
  float onemt2[];
  float onemt3[];
  float bto2[];
  float bt2o[];

  float cx[];
  float cy[];
  int nCircPoints;


  //=========================================================================	
  public HeartBalloonConnector (ParagraphBalloonManager pbm, HeartManager hm) {
    PBM = pbm;
    HM  = hm;
    precomputeBezierArrays();
    precomputeCircleArrays();
  }

  //=========================================================================
  void renderConnections() {

    
    // smooth();
    strokeWeight (1.0);  
    
    int mouseSelectedHeartID = HM.mouseSelectedHeartID;
    int mouseoverBalloonId = PBM.getMouseContainingBalloon();
    int mouseOverHeartID   = HM.mouseOverHeartID;

    int nBalloons = PBM.nExtantBalloons;
    for (int b=0; b<nBalloons; b++) {
      int breakupId = PBM.balloons[b].breakupId;
      int heartId   = PBM.balloons[b].heartId;

      if ((breakupId != DUMPSTER_INVALID) && (heartId   != DUMPSTER_INVALID)) {

        FPoint hpt = HM.getHeartLoc(heartId);
        float hx = hpt.px;
        float hy = hpt.py;

        if ((hx != DUMPSTER_INVALID) && (hy != DUMPSTER_INVALID)) {
          Heart Hi = HM.hearts[heartId];
          float Hd = (Hi.diam * 0.5f) + 6;

          float py = PBM.balloons[b].py;
          float ph = PBM.balloons[b].ph;

          float bx = (float)Math.floor(BALLOON_X - 3);
          float by = py + ph/2.0f;

          float ax = bx-CONNECTOR_BEZ_DIF;
          float ay = by;

          float jx = (hx + (bx-CONNECTOR_BEZ_DIF))/2.0f;
          float jy = (hy + by)/2.0f;


          float dx = jx - hx;
          float dy = jy - hy;
          float dh = (float)Math.sqrt(dx*dx+dy*dy);
          if (dh == 0) dh = 1;
          float ix = hx + Hd*dx/dh;
          float iy = hy + Hd*dy/dh;

          //-------------------
          float Hicolr = Hi.colr;
          float Hicolg = Hi.colg;
          float Hicolb = Hi.colb;

          float Hr = (Hicolr + BALLOON_BODY_R)/2.0f;
          float Hg = (Hicolg + BALLOON_BODY_G)/2.0f;
          float Hb = (Hicolb + BALLOON_BODY_B)/2.0f;

          float endr = BALLOON_BODY_R;
          float endg = BALLOON_BODY_G;
          float endb = BALLOON_BODY_B;

          boolean bover = false;
          if (b == mouseoverBalloonId) {
            Hr = Hicolr;
            Hg = Hicolg;
            Hb = 255;
            Hi.colr = Hi.colrt = 0;
            Hi.colg = Hi.colgt = 0;
            Hi.colb = Hi.colbt = 255;
            bover = true;
          }
          if ((heartId == mouseOverHeartID) ||
            (Hi.mouseState == STATE_MOUSE_OVER) ||
            ((HM.bCurrentlyDraggingSelectedHeart) && (heartId == mouseSelectedHeartID))   ) {
            PBM.balloons[b].b_correspondingHeartIsMousedOver = true;
            bover = true;
          } 
          else {
            PBM.balloons[b].b_correspondingHeartIsMousedOver = false;
          }

          if (heartId == mouseSelectedHeartID) {
            Hr = 255;
            Hg = 255;
            Hb = 0;
          }

          drawBezier (ix, iy, jx, jy, ax, ay, bx, by, Hr, Hg, Hb, endr, endg, endb, bover); 
          drawCircleNoBoundaryCheck (hx, hy, Hd, Hr, Hg, Hb, bover);
        }
      }
    }
    
    
    // noSmooth();
    strokeWeight (1.0);  
  }

  //---------------------------------------------------------------------------
  void drawBezier (	float x0, float y0, 
  float x1, float y1, 
  float x2, float y2, 
  float x3, float y3, 
  float r0, float g0, float b0, 
  float r3, float g3, float b3, 
  boolean bover ) {

    float f0, f1, f2, f3;
    float bx, by;
    int r, g, b;

    // int flag = (bover) ? LINE_STRIP : POINTS;
    int skip =  (bover) ? 1:2;

    // optimization:
    if (y3 > HEART_WALL_B) {
      beginShape(POINTS);
      for (int i=0; i<nBezPoints; i+=skip) {
        f0 = onemt3[i];
        f1 = bto2[i];
        f2 = bt2o[i];
        f3 = bt3[i];

        by = (f0*y0 + f1*y1 + f2*y2 + f3*y3);
        if (by < HEART_WALL_B) {
          bx = (f0*x0 + f1*x1 + f2*x2 + f3*x3);

          r = (int)(bt[i]*r3 + onemt[i]*r0);
          g = (int)(bt[i]*g3 + onemt[i]*g0);
          b = (int)(bt[i]*b3 + onemt[i]*b0);
          stroke(r, g, b);
          vertex(bx, by);
        }
      }
      endShape();
    } 
    else {

      beginShape(POINTS);
      for (int i=0; i<nBezPoints; i+=skip) {
        f0 = onemt3[i];
        f1 = bto2[i];
        f2 = bt2o[i];
        f3 = bt3[i];
        by = (f0*y0 + f1*y1 + f2*y2 + f3*y3);
        bx = (f0*x0 + f1*x1 + f2*x2 + f3*x3);
        r = (int)(bt[i]*r3 + onemt[i]*r0);
        g = (int)(bt[i]*g3 + onemt[i]*g0);
        b = (int)(bt[i]*b3 + onemt[i]*b0);
        stroke(r, g, b);
        vertex(bx, by);
      }
      endShape();
    }
    
  }


  //---------------------------------------------------------------------------
  void drawBezierNoBoundaryCheck (	
  float x0, float y0, 
  float x1, float y1, 
  float x2, float y2, 
  float x3, float y3, 
  float r0, float g0, float b0, 
  float r3, float g3, float b3, 
  boolean bover ) {

    float f0, f1, f2, f3;
    float bx, by;
    int r, g, b;

    // int flag = (bover) ? LINE_STRIP : POINTS;
    int skip =  (bover) ? 1:2;

    beginShape(POINTS);
    for (int i=0; i<nBezPoints; i+=skip) {
      f0 = onemt3[i];
      f1 = bto2[i];
      f2 = bt2o[i];
      f3 = bt3[i];

      by = (f0*y0 + f1*y1 + f2*y2 + f3*y3);
      bx = (f0*x0 + f1*x1 + f2*x2 + f3*x3);

      r = (int)(bt[i]*r3 + onemt[i]*r0);
      g = (int)(bt[i]*g3 + onemt[i]*g0);
      b = (int)(bt[i]*b3 + onemt[i]*b0);
      stroke(r, g, b);
      vertex(bx, by);
    }
    endShape();
  }

  //---------------------------------------------------------------------------
  void drawCircle (	float x, float y, float r, 
  float cr, float cg, float cb, 
  boolean bover) {
    float px, py;
    stroke(cr, cg, cb);

    int skip =  (bover) ? 1:2;
    beginShape(POINTS);
    for (int i=0; i<nCircPoints; i+=skip) {
      py = y + r*cy[i];
      if (py < HEART_WALL_B) {
        px = x + r*cx[i];
        if (px > HEART_WALL_L) {
          vertex(px, py);
        }
      }
    }
    endShape();
  }

  //---------------------------------------------------------------------------
  void drawCircleNoBoundaryCheck (	float x, float y, float r, 
  float cr, float cg, float cb, 
  boolean bover) {
    float px, py;
    stroke(cr, cg, cb);

    int skip =  (bover) ? 1:2;
    beginShape(POINTS);
    for (int i=0; i<nCircPoints; i+=skip) {
      py = y + r*cy[i];
      px = x + r*cx[i];
      vertex(px, py);
    }	
    endShape();
  }



  //---------------------------------------------------------------------------
  void precomputeCircleArrays() {
    nCircPoints = 96;
    cx = new float[nCircPoints];
    cy = new float[nCircPoints];
    for (int i=0; i<nCircPoints; i++) {
      float t = (float)Math.PI * 2.0f * ((float)i)/(float)(nCircPoints-1);
      cx[i] = (float)Math.cos(t);
      cy[i] = (float)Math.sin(t);
    }
  }


  //---------------------------------------------------------------------------
  void precomputeBezierArrays() {
    nBezSegments = 127;
    nBezPoints = nBezSegments+1;
    SPLINE_BIAS = 1.0f/4.0f;

    bt			= new float[nBezPoints];
    bt2		= new float[nBezPoints];
    bt3		= new float[nBezPoints];
    onemt		= new float[nBezPoints];
    onemt2	= new float[nBezPoints];
    onemt3	= new float[nBezPoints];
    bto2		= new float[nBezPoints];
    bt2o		= new float[nBezPoints];

    for (int p=0; p<nBezPoints; p++) {
      float t = (float)p/(float)nBezSegments;
      t = pow (t, 1.5);
      bt[p]	        = t;
      bt2[p]		= bt[p] * bt[p];
      bt3[p]		= bt[p] * bt2[p];
      onemt[p]		= 1.0f - bt[p];
      onemt2[p]	= onemt[p] * onemt[p];
      onemt3[p]	= onemt[p] * onemt2[p];
      bto2[p]		= 3.0f*bt[p]*onemt2[p];
      bt2o[p]		= 3.0f*bt2[p]*onemt[p];
    }
  }



  //=========================================================================
  void renderCurrentConnectionOnly() {

    if (HM.mouseSelectedHeartID != -1) {
      if (PBM.currentBalloonIndex != -1) {
        FPoint hpt = HM.getHeartLoc(HM.mouseSelectedHeartID);
        float hx = hpt.px;
        float hy = hpt.py;

        if ((hx != DUMPSTER_INVALID) && (hy != DUMPSTER_INVALID)) {
          float bx = BALLOON_X - 12;
          float by = PBM.getTopBalloonCenterY();

 
          stroke(255, 255, 0);

          float jx = (hx + (bx-CONNECTOR_BEZ_DIF))/2.0f;
          float jy = (hy + by)/2.0f;

          beginShape (POINTS);
          vertex(hx, hy);
          bezierVertex(jx, jy, bx-CONNECTOR_BEZ_DIF, by, bx, by);
          /*
          bezierVertex(hx, hy);
           bezierVertex(jx, jy);
           bezierVertex(bx-CONNECTOR_BEZ_DIF, by);
           bezierVertex(bx, by);
           */
          endShape();

          //Four calls to bezierVertex(x, y) 
          //should instead be a single call to vertex(x, y), 
          //followed by bezierVertex(cx1, cy1, cx2, cy2, x2, y2) 
          //(two control points followed by the destination point).
        }
      }
    }
  }
}
