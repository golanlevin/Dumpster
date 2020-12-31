

class Heart {

  int   heartId;
  int 	breakupId;

  float ox, oy; // previous location
  float qx, qy; // possible future location
  float px, py; // current position
  float vx, vy, vh;
  float xMin, xMax;
  float yMin, yMax;
  float mass;
  float rad, diam, diamShave;
  float rad_sq;
  float rad_target, rad_backup;
  float my_wall_L, my_wall_R;
  float my_wall_T, my_wall_B;
  int   mouseState;
  int   existState;
  short xbins, ybins;
  String bupString = "dfgkljhdflkjdfkjhdfkjdfkjdflkjhdflkgjdfgkljdfgkljhdfgkjdfgkjhdffgkjhdffglgkjh";

  float similarityToSelected;

  int col;
  float colr, colg, colb;    // current color components
  float colrb, colgb, colbb; // backup color components
  float colrt, colgt, colbt; // target color components

  int innerColorOver;
  int innerColorSelected;
  int innerColorHeart;

  BreakupManager BM;
  boolean bCurrentlyDraggingSelectedHeart = false;
  float myMouseX = 0;
  float myMouseY = 0;
  boolean bWasSpecificallyClicked;


  //-----------------------------
  Heart (int h_id, BreakupManager bm, TheDumpster m) {
    BM = bm;
    breakupId = (int) (random(0, 1)* N_BREAKUP_DATABASE_RECORDS_20K);

    xbins = 0;
    ybins = 0;
    heartId = h_id;

    innerColorOver     = color (255, 100, 180);
    innerColorSelected = color (255, 245, 0);
    innerColorHeart    = color (255, 180, 90);

    // rad = (float)pow(random(0,1), 3.0f);
    // rad = HEART_MIN_RAD + rad*(HEART_MAX_RAD - HEART_MIN_RAD);

    rad = BM.bups[breakupId].heartRadius;
    rad_sq = rad * rad;
    mass  = (1 + rad_sq) * HEART_MASS_CONSTANT;
    diamShave = (rad > HEART_MIN_RADp1) ? HEART_DIAM_SHAVE : 0;
    diam  = rad*2.0f - diamShave;

    rad_backup  = rad;
    rad_target  = rad;
    mouseState  = STATE_MOUSE_IGNORE;
    existState  = STATE_HEART_EXISTS;

    my_wall_L = HEART_WALL_L + rad;
    my_wall_R = HEART_WALL_R - rad;
    my_wall_T = HEART_WALL_T + rad;
    my_wall_B = HEART_WALL_B - rad;

    px = my_wall_L + (float) random(0, 1)*(my_wall_R-my_wall_L); //random(my_wall_L, my_wall_R);
    py = my_wall_T + (float) random(0, 1)*(my_wall_B-my_wall_T); //random(my_wall_T, my_wall_B);
    xMin = px - rad;
    xMax = px + rad;
    yMin = py - rad;
    yMax = py + rad;
    vx = 2.0f* (float) (random(0, 1)-0.5);//(-1,1);
    vy = 2.0f* (float) (random(0, 1)-0.5);//(-1,1);

    similarityToSelected = (float)(random(0, 1));
    float simCol = (float)pow(similarityToSelected, 0.9f); 

    colrt = colrb = colr = similarityToSelected*200.0f;
    colgt = colgb = colg = 32;//255.0*pow((heartId%256)/255.0, 2.0);
    colbt = colbb = colb = 32;//255-heartId%256;
    col = color(colr, colg, colb);
    saturateColors();
  }



  //-----------------------------
  void initiate (int newBreakupIndex, float sim) {
    breakupId = newBreakupIndex;
    xbins = 0;
    ybins = 0;

    rad = BM.bups[breakupId].heartRadius;
    rad_sq = rad * rad;
    mass  = (1 + rad_sq) * HEART_MASS_CONSTANT;
    diamShave = (rad > HEART_MIN_RADp1) ? HEART_DIAM_SHAVE : 0;
    diam  = rad*2.0f - diamShave;

    rad_backup  = rad;
    rad_target  = rad;
    mouseState  = STATE_MOUSE_IGNORE;
    existState  = STATE_HEART_EXISTS;

    my_wall_L = HEART_WALL_L + rad;
    my_wall_R = HEART_WALL_R - rad;
    my_wall_T = HEART_WALL_T + rad;
    my_wall_B = HEART_WALL_B - rad;

    if (sim == 1.0f) {
      if (mousePressed) {
        px = HEART_WALL_L;
        py = min(HEART_WALL_B, max(HEART_WALL_T, myMouseY));
      } 
      else {
        px = random(HEART_WALL_L, (HEART_WALL_L+HEART_WALL_R)/2.0);
        py = HEART_WALL_T;
      }
    } 
    else {

      if (random(0, 1) < 0.5f) {
        float rxf = 0.50f * (float)pow(random(0, 1), 1.50f);
        px = my_wall_L + rxf*(my_wall_R-my_wall_L);
        py = HEART_WALL_T;
      } 
      else {
        float ryf = (float)random(0, 1);
        px = HEART_WALL_R;
        py = my_wall_T + ryf*(my_wall_B-my_wall_T);
      }
    }

    xMin = px - rad;
    xMax = px + rad;
    yMin = py - rad;
    yMax = py + rad;
    vx = 0.8f* (float) (random(0, 1)-0.5);
    vy = 2.5f +  2.0f*(float)(random(0, 1));

    similarityToSelected = sim; 
    float simCol = (float)pow(sim, 0.9f); 

    colrt = colrb = colr = simCol*200.0f;
    colgt = colgb = colg = 32;//255.0*pow((heartId%256)/255.0, 2.0);
    colbt = colbb = colb = 32;//255-heartId%256;
    col = color(colr, colg, colb);
    saturateColors();
  }



  //-----------------------------
  void setSimilarityToSelected (float sim) {
    if (existState != STATE_HEART_GONE) {

      similarityToSelected = sim;
      float simCol = (float)pow(sim, 0.9f); 

      //similarityToSelected = (float) pow(random(0,1), 2.0f);
      colrb = simCol*200.0f;
      colgb = 32;
      colbb = 32;
      saturateColors();
    }
  }


  //-----------------------------
  void saturateColors() {
    float lumr = colrb * LUMINANCES_R;
    float lumg = colgb * LUMINANCES_G;
    float lumb = colbb * LUMINANCES_B;
    colrt = colrb = max(0, min(255, HEART_SATURATE_B*lumr + HEART_SATURATE_A*colrb));
    colgt = colgb = max(0, min(255, HEART_SATURATE_B*lumg + HEART_SATURATE_A*colgb));
    colbt = colbb = max(0, min(255, HEART_SATURATE_B*lumb + HEART_SATURATE_A*colbb));
  }

  //-----------------------------
  void accumulateForce (float fx, float fy) {
    vx += fx/mass;
    vy += fy/mass;
  }
  //-----------------------------
  void accumulateGravityForce () {
    vy += HEART_GRAVITY;
  }
  //-----------------------------
  void accumulateAttractionForceToSelected (float spx, float spy, float spr) {
    if (existState != STATE_HEART_GONE) {
      float dx = spx - px;
      float dy = spy - py;
      float dh = (float)sqrt(dx*dx + dy*dy) - spr;
      if (dh > 0) {
        float f =  0.15f * (similarityToSelected-0.33f) / (dh+1);
        vx += f * dx;
        vy += f * dy;
      }
    }
  }

  //-----------------------------
  void accumulateCentralizingForce() {
    if (existState != STATE_HEART_GONE) {
      float dx = HEART_HEAP_CENTERX - px;
      float dy = HEART_HEAP_CENTERY - py;
      float dh = (dx*dx + dy*dy);
      if (dh > HEART_NEIGHBORHOOD_SQ) {
        dh = HEART_HEAPING_K / (float)sqrt(dh);
        dx *= dh;
        dy *= dh;
        vx += dx;
        vy += dy/mass;
      }
    }
  }

  //-----------------------------
  void setMouseInformation (boolean bdrag, float mx, float my) {
    bCurrentlyDraggingSelectedHeart = bdrag;
    myMouseX = mx;
    myMouseY = my;
  }

  //-----------------------------
  void update () {

    if (existState != STATE_HEART_GONE) {

      // update color if target is sufficiently different from current.
      float dcolr = abs (colrt - colr);
      float dcolg = abs (colgt - colg);
      float dcolb = abs (colbt - colb);
      if ((dcolr+dcolg+dcolb) > 0.50f) {
        colr = HEART_BLUR_CA*colr + HEART_BLUR_CB*colrt;
        colg = HEART_BLUR_CA*colg + HEART_BLUR_CB*colgt;
        colb = HEART_BLUR_CA*colb + HEART_BLUR_CB*colbt;
      }

      // update radius and related variables.
      if (abs (rad - rad_target) > 0.25f) {
        rad    = HEART_BLUR_RA*rad + HEART_BLUR_RB*rad_target;
        rad_sq = rad*rad;
        mass   = (1 + rad_sq) * HEART_MASS_CONSTANT;
        diamShave = (rad > HEART_MIN_RADp1) ? HEART_DIAM_SHAVE : 0;
        diam   = rad*2.0f - diamShave;
        my_wall_L = HEART_WALL_L + rad; // could be optimized out if L=0
        my_wall_T = HEART_WALL_T + rad; // could be optimized out if T=0.
        my_wall_R = HEART_WALL_R - rad;
        my_wall_B = HEART_WALL_B - rad;

        if (abs (rad-rad_target) < 0.25f) {
          rad = rad_target;
          if ((existState == STATE_HEART_FADING) && (rad == 0)) {
            existState = STATE_HEART_GONE;
          }
        }
      }

      // test to see if new position intersects wall; collide if so.
      ox = px;
      oy = py;
      vx *= HEART_DAMPING;
      vy *= HEART_DAMPING;

      if (bCurrentlyDraggingSelectedHeart) {
        // println("bCurrentlyDraggingSelectedHeart! " + millis() +  " " + mouseState);
      }


      if (bCurrentlyDraggingSelectedHeart && ((mouseState == STATE_MOUSE_DRAG)||(mouseState == STATE_MOUSE_SELECT))) {
        // drag the selected one, blurring in the mouse coords.
        qx = 0.20f*px + 0.80f*myMouseX;
        qy = 0.20f*py + 0.80f*myMouseY;
        vx = qx - px;
        vy = qy - py;
      } 
      else {
        qx = ox + vx;
        qy = oy + vy;

        if (xbins == 3) {
          if ((ox >= my_wall_L) && (qx < my_wall_L)) {      // if cross left wall
            qx = my_wall_L + (my_wall_L - qx);
            vx = -vx;
            vx *= HEART_COLLISION_DAMPING;
            vy *= HEART_COLLISION_DAMPING;
          }
        } 
        else if (xbins == 192) {
          if ((ox < my_wall_R) && (qx >= my_wall_R)) {      // or if cross right wall
            qx = my_wall_R - (qx - my_wall_R);
            vx = -vx;
            vx *= HEART_COLLISION_DAMPING;
            vy *= HEART_COLLISION_DAMPING;
          }
        }
        if (ybins == 192) {
          if ((oy < my_wall_B) && (qy >= my_wall_B)) {      // if cross bottom wall
            qy = my_wall_B - (qy - my_wall_B);
            vy = -vy;
            vx *= HEART_COLLISION_DAMPING;
            vy *= HEART_COLLISION_DAMPING;
          }
        } 
        else if (ybins == 3) {
          if ((oy >= my_wall_T) && (qy < my_wall_T)) {      // else if cross top wall
            qy = my_wall_T + (my_wall_T - qy);
            vy = -vy;
            vx *= HEART_COLLISION_DAMPING;
            vy *= HEART_COLLISION_DAMPING;
          }
        }
      }

      // clamp positions
      px = min(my_wall_R, max(my_wall_L, qx));
      py = min(my_wall_B, max(my_wall_T, qy));
      xMin = px - rad;
      xMax = px + rad;
      yMin = py - rad;
      yMax = py + rad;

      // clamp velocities.
      if ((abs(vx) > HEART_MAX_VELd2) || (abs(vy) > HEART_MAX_VELd2)) {
        vh = (float) sqrt(vx*vx + vy*vy);
        if (vh > HEART_MAX_VEL) {
          float frac = HEART_MAX_VEL / vh;
          vh = HEART_MAX_VEL;
          vx *= frac;
          vy *= frac;
        }
      }

      xbins = bindices[(int)(opt_8dHA_W * (px-HEART_WALL_L))];
      ybins = bindices[(int)(opt_8dHA_H * (py-HEART_WALL_T))];
    }
  }

  //-----------------------------
  void initiateDisappearance() {
    if (mouseState == STATE_MOUSE_IGNORE) {
      existState  = STATE_HEART_FADING;
      rad_target  = 0;
    }
  }

  //------------------------------
  void setMouseState (int mState) {
    mouseState = mState;
    if (existState != STATE_HEART_GONE) {
      switch(mouseState) {

      case STATE_MOUSE_DRAG: 
        existState = STATE_HEART_EXISTS;
        rad_target = HEART_DRAG_RADIUS;
        colr = colrt = 255;
        colg = colgt = 128;
        colb = colbt = 0;
        break;

      case STATE_MOUSE_SELECT:
        existState = STATE_HEART_EXISTS;
        rad_target = HEART_SELECT_RADIUS;
        colr = colrt = 255;
        colg = colgt = 100;
        colb = colbt = 0;
        break;

      case STATE_MOUSE_OVER:
        existState = STATE_HEART_EXISTS;
        rad_target = HEART_OVER_RADIUS;
        colr = colrt = 0;//255;
        colg = colgt = 0;
        colb = colbt = 255;//64;
        break;

      case STATE_MOUSE_IGNORE:
        if (existState == STATE_HEART_EXISTS) {
          rad_target = rad_backup;
        } 
        else { // if existState == STATE_HEART_FADING || existState == STATE_HEART_GONE
          rad_target = 0;
        }
        colrt = colrb;
        colgt = colgb;
        colbt = colbb;
        break;
      }
    }
  }

  //-----------------------------
  void render () {
    if (existState != STATE_HEART_GONE) {
      fill ((int)colr, (int)colg, (int)colb);
      ellipse (px, py, diam, diam);
    }
  }

  //---------------------------------------------------
  void renderMouseOver () {
    noStroke();
    fill((int)colr, (int)colg, (int)colb);
    ellipse (px, py, diam, diam);
    fill(innerColorOver);
    ellipse (px, py, diam-12, diam-12);
  }

  //---------------------------------------------------
  void renderMouseSelected () {
    stroke(0, 0, 0);
    fill((int)colr, (int)colg, (int)colb);
    ellipse (px, py, diam, diam);
    noStroke();
    fill(innerColorSelected);
    ellipse (px, py, diam-12, diam-12);
  }
}

