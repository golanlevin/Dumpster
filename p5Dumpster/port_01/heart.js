class Heart {

    //-----------------------------
    constructor (h_id, bm) {

        //----------------
        // Initial declarations
        this.heartId = 0;
        this.breakupId = 0;
      
        this.ox = 0; this.oy = 0; // previous location
        this.qx = 0; this.qy = 0; // possible future location
        this.px = 0; this.py = 0; // current position
        this.vx = 0; this.vy = 0; this.vh = 0;
        this.xMin = 0; this.xMax = 0;
        this.yMin = 0; this.yMax = 0;
        this.mass = 0;
        this.rad = 0; this.diam = 0; this.diamShave = 0;
        this.rad_sq = 0;
        this.rad_target = 0; this.rad_backup = 0;
        this.my_wall_L = 0; 
        this.my_wall_R = 0;
        this.my_wall_T = 0; 
        this.my_wall_B = 0;
        this.mouseState = STATE_MOUSE_IGNORE;
        this.existState = STATE_HEART_GONE;
        this.xbins = 0;
        this.ybins = 0;
        this.bupString = "dfgkljhdflkjdfkjhdfkjdfkjdflkjhdflkgjdfgkljdfgkljhdfgkjdfgkjhdffgkjhdffglgkjh";
        this.similarityToSelected = 0;
      
        this.col = 0;
        this.colr = 0; this.colg = 0; this.colb = 0;    // current color components
        this.colrb = 0; this.colgb = 0; this.colbb = 0; // backup color components
        this.colrt = 0; this.colgt = 0; this.colbt = 0; // target color components
      
        this.BM = null;
        this.bCurrentlyDraggingSelectedHeart = false;
        this.myMouseX = 0;
        this.myMouseY = 0;
        this.bWasSpecificallyClicked = false;

        this.innerColorOver     = color (255, 100, 180);
        this.innerColorSelected = color (255, 245, 0);
        this.innerColorHeart    = color (255, 180, 90);
        //----------------
    

        this.BM = bm;
        this.breakupId = int(random(0, 1)* N_BREAKUP_DATABASE_RECORDS_20K);
        this.xbins = 0;
        this.ybins = 0;
        this.heartId = h_id;
  
        this.rad = pow(random(0,1), 3.0);
        this.rad = HEART_MIN_RAD + this.rad*(HEART_MAX_RAD - HEART_MIN_RAD); // bogus
  
        // rad = BM.bups[breakupId].heartRadius; // FIX - PUT BACK IN LATER WHEN BM EXISTS
        this.rad_sq = this.rad * this.rad;
        this.mass  = (1.0 + this.rad_sq) * HEART_MASS_CONSTANT;
        this.diamShave = (this.rad > HEART_MIN_RADp1) ? HEART_DIAM_SHAVE : 0;
        this.diam  = this.rad*2.0 - this.diamShave;
  
        this.rad_backup  = this.rad;
        this.rad_target  = this.rad;
        this.mouseState  = STATE_MOUSE_IGNORE;
        this.existState  = STATE_HEART_EXISTS;
  
        this.my_wall_L = HEART_WALL_L + this.rad;
        this.my_wall_R = HEART_WALL_R - this.rad;
        this.my_wall_T = HEART_WALL_T + this.rad;
        this.my_wall_B = HEART_WALL_B - this.rad;
  
        this.px = random(this.my_wall_L, this.my_wall_R);
        this.py = random(this.my_wall_T, this.my_wall_B);
        this.xMin = this.px - this.rad;
        this.xMax = this.px + this.rad;
        this.yMin = this.py - this.rad;
        this.yMax = this.py + this.rad;
        this.vx = random(-1,1);
        this.vy = random(-1,1);
        this.similarityToSelected = (random(0, 1));

        this.colrt = this.colrb = this.colr = this.similarityToSelected*200.0;
        this.colgt = this.colgb = this.colg = 32;//255.0*pow((heartId%256)/255.0, 2.0);
        this.colbt = this.colbb = this.colb = 32;//255-heartId%256;
        this.col = color(this.colr, this.colg, this.colb);
        this.saturateColors();
    }
  
  
    //-----------------------------
    initiate ( newBreakupIndex, sim) {
        this.breakupId = newBreakupIndex;
        this.xbins = 0;
        this.ybins = 0;

        this.rad = BM.bups[this.breakupId].heartRadius;
        this.rad_sq = this.rad * this.rad;
        this.mass  = (1 + this.rad_sq) * HEART_MASS_CONSTANT;
        this.diamShave = (this.rad > HEART_MIN_RADp1) ? HEART_DIAM_SHAVE : 0;
        this.diam  = rad*2.0 - this.diamShave;
  
        this.rad_backup  = this.rad;
        this.rad_target  = this.rad;
        this.mouseState  = STATE_MOUSE_IGNORE;
        this.existState  = STATE_HEART_EXISTS;

        this.my_wall_L = HEART_WALL_L + this.rad;
        this.my_wall_R = HEART_WALL_R - this.rad;
        this.my_wall_T = HEART_WALL_T + this.rad;
        this.my_wall_B = HEART_WALL_B - this.rad;
  
        if (sim == 1.0) {
            if (mousePressed) {
                this.px = HEART_WALL_L;
                this.py = min(HEART_WALL_B, max(HEART_WALL_T, this.myMouseY));
            } 
            else {
                this.px = random(HEART_WALL_L, (HEART_WALL_L+HEART_WALL_R)/2.0);
                this.py = HEART_WALL_T;
            }
        }
        else {
            if (random(0, 1) < 0.5) {
                var rxf = 0.50 * pow(random(0, 1), 1.50);
                px = this.my_wall_L + rxf*(this.my_wall_R-this.my_wall_L);
                py = HEART_WALL_T;
            } 
            else {
                var ryf = random(0, 1);
                px = HEART_WALL_R;
                py = this.my_wall_T + ryf*(this.my_wall_B-this.my_wall_T);
            }
        }
  
        this.xMin = this.px - this.rad;
        this.xMax = this.px + this.rad;
        this.yMin = this.py - this.rad;
        this.yMax = this.py + this.rad;
        this.vx = 0.8 * (random(0, 1)-0.5);
        this.vy = 2.5 + 2.0*(random(0, 1));
  
        this.similarityToSelected = sim; 
        var simCol = pow(sim, 0.9); 
  
        this.colrt = this.colrb = this.colr = simCol*200.0;
        this.colgt = this.colgb = this.colg = 32;//255.0*pow((heartId%256)/255.0, 2.0);
        this.colbt = this.colbb = this.colb = 32;//255-heartId%256;
        this.col = color(this.colr, this.colg, this.colb);
        this.saturateColors();
    }
  
  
    //-----------------------------
    setSimilarityToSelected (sim) {
      if (existState != STATE_HEART_GONE) {
  
        this.similarityToSelected = sim;
        var simCol = pow(sim, 0.9); 
  
        //similarityToSelected = (float) pow(random(0,1), 2.0f);
        this.colrb = simCol*200.0;
        this.colgb = 32;
        this.colbb = 32;
        this.saturateColors();
      }
    }
  

    //-----------------------------
    saturateColors() {
        var lumr = this.colrb * LUMINANCES_R;
        var lumg = this.colgb * LUMINANCES_G;
        var lumb = this.colbb * LUMINANCES_B;
        this.colrt = this.colrb = max(0, min(255, HEART_SATURATE_B*lumr + HEART_SATURATE_A*this.colrb));
        this.colgt = this.colgb = max(0, min(255, HEART_SATURATE_B*lumg + HEART_SATURATE_A*this.colgb));
        this.colbt = this.colbb = max(0, min(255, HEART_SATURATE_B*lumb + HEART_SATURATE_A*this.colbb));
    }
  
    
    //-----------------------------
    accumulateForce (fx, fy) {
        this.vx += fx/this.mass;
        this.vy += fy/this.mass;
    }
    //-----------------------------
    accumulateGravityForce () {
        this.vy += HEART_GRAVITY;
    }
    //-----------------------------
    accumulateAttractionForceToSelected (spx, spy, spr) {
      if (this.existState != STATE_HEART_GONE) {
        var dx = spx - this.px;
        var dy = spy - this.py;
        var dh = sqrt(dx*dx + dy*dy) - spr;
        if (dh > 0) {
            var f =  0.15 * (this.similarityToSelected-0.33) / (dh+1.0);
            this.vx += f * dx;
            this.vy += f * dy;
        }
      }
    }
  
    //-----------------------------
    accumulateCentralizingForce() {
        if (this.existState != STATE_HEART_GONE) {
            var dx = HEART_HEAP_CENTERX - this.px;
            var dy = HEART_HEAP_CENTERY - this.py;
            var dh = (dx*dx + dy*dy);
            if (dh > HEART_NEIGHBORHOOD_SQ) {
                dh = HEART_HEAPING_K / sqrt(dh);
                dx *= dh;
                dy *= dh;
                this.vx += this.dx;
                this.vy += this.dy/this.mass;
            }
        }
    }
  
    //-----------------------------
    setMouseInformation (bdrag, mx, my) {
        this.bCurrentlyDraggingSelectedHeart = bdrag;
        this.myMouseX = mx;
        this.myMouseY = my;
    }
  
    //-----------------------------
    update () {
  
        if (existState != STATE_HEART_GONE) {
    
            // update color if target is sufficiently different from current.
            var dcolr = abs (this.colrt - this.colr);
            var dcolg = abs (this.colgt - this.colg);
            var dcolb = abs (this.colbt - this.colb);
            if ((dcolr+dcolg+dcolb) > 0.50) {
                this.colr = HEART_BLUR_CA*this.colr + HEART_BLUR_CB*this.colrt;
                this.colg = HEART_BLUR_CA*this.colg + HEART_BLUR_CB*this.colgt;
                this.colb = HEART_BLUR_CA*this.colb + HEART_BLUR_CB*this.colbt;
            }
  
            // update radius and related variables.
            if (abs (this.rad - this.rad_target) > 0.25) {
                this.rad    = HEART_BLUR_RA*this.rad + HEART_BLUR_RB*this.rad_target;
                this.rad_sq = this.rad*this.rad;
                this.mass   = (1.0 + this.rad_sq) * HEART_MASS_CONSTANT;
                this.diamShave = (this.rad > HEART_MIN_RADp1) ? HEART_DIAM_SHAVE : 0;
                this.diam   = this.rad*2.0 - this.diamShave;
                this.my_wall_L = HEART_WALL_L + this.rad; // could be optimized out if L=0
                this.my_wall_T = HEART_WALL_T + this.rad; // could be optimized out if T=0.
                this.my_wall_R = HEART_WALL_R - this.rad;
                this.my_wall_B = HEART_WALL_B - this.rad;

                if (abs (this.rad-this.rad_target) < 0.25) {
                    this.rad = this.rad_target;
                    if ((this.existState == STATE_HEART_FADING) && (this.rad == 0)) {
                        this.existState = STATE_HEART_GONE;
                    }
                }
            }

            // test to see if new position intersects wall; collide if so.
            this.ox = this.px;
            this.oy = this.py;
            this.vx *= HEART_DAMPING;
            this.vy *= HEART_DAMPING;
    
            if (this.bCurrentlyDraggingSelectedHeart) {
            // println("bCurrentlyDraggingSelectedHeart! " + millis() +  " " + mouseState);
            }
    
    
            if (this.bCurrentlyDraggingSelectedHeart && 
                ((this.mouseState == STATE_MOUSE_DRAG)||(this.mouseState == STATE_MOUSE_SELECT))) {
                // drag the selected one, blurring in the mouse coords.
                this.qx = 0.20*this.px + 0.80*this.myMouseX;
                this.qy = 0.20*this.py + 0.80*this.myMouseY;
                this.vx = this.qx - this.px;
                this.vy = this.qy - this.py;
            } 
            else {
                this.qx = this.ox + this.vx;
                this.qy = this.oy + this.vy;
    
                if (this.xbins == 3) {
                    if ((this.ox >= this.my_wall_L) && (this.qx < this.my_wall_L)) {      // if cross left wall
                        this.qx = this.my_wall_L + (this.my_wall_L - this.qx);
                        this.vx = -this.vx;
                        this.vx *= HEART_COLLISION_DAMPING;
                        this.vy *= HEART_COLLISION_DAMPING;
                    }
                } 
                else if (this.xbins == 192) {
                    if ((this.ox < this.my_wall_R) && (this.qx >= this.my_wall_R)) {      // or if cross right wall
                        this.qx = this.my_wall_R - (this.qx - this.my_wall_R);
                        this.vx = -this.vx;
                        this.vx *= HEART_COLLISION_DAMPING;
                        this.vy *= HEART_COLLISION_DAMPING;
                    }
                }
                if (this.ybins == 192) {
                    if ((this.oy < this.my_wall_B) && (this.qy >= this.my_wall_B)) {      // if cross bottom wall
                        this.qy = this.my_wall_B - (this.qy - this.my_wall_B);
                        this.vy = -this.vy;
                        this.vx *= HEART_COLLISION_DAMPING;
                        this.vy *= HEART_COLLISION_DAMPING;
                    }
                } 
                else if (this.ybins == 3) {
                    if ((this.oy >= this.my_wall_T) && (this.qy < this.my_wall_T)) {      // else if cross top wall
                        this.qy = this.my_wall_T + (this.my_wall_T - this.qy);
                        this.vy = -this.vy;
                        this.vx *= HEART_COLLISION_DAMPING;
                        this.vy *= HEART_COLLISION_DAMPING;
                    }
                }
            }
    
            // clamp positions
            this.px = min(this.my_wall_R, max(this.my_wall_L, this.qx));
            this.py = min(this.my_wall_B, max(this.my_wall_T, this.qy));
            this.xMin = this.px - this.rad;
            this.xMax = this.px + this.rad;
            this.yMin = this.py - this.rad;
            this.yMax = this.py + this.rad;
    
            // clamp velocities.
            if ((abs(this.vx) > HEART_MAX_VELd2) || (abs(this.vy) > HEART_MAX_VELd2)) {
                this.vh = sqrt(this.vx*this.vx + this.vy*this.vy);
                if (this.vh > HEART_MAX_VEL) {
                    var frac = HEART_MAX_VEL / this.vh;
                    this.vh = HEART_MAX_VEL;
                    this.vx *= frac;
                    this.vy *= frac;
                }
            }
    
            this.xbins = bindices[int(opt_8dHA_W * (this.px-HEART_WALL_L))];
            this.ybins = bindices[int(opt_8dHA_H * (this.py-HEART_WALL_T))];
        }
    }
  
    //-----------------------------
    initiateDisappearance() {
        if (this.mouseState == STATE_MOUSE_IGNORE) {
            this.existState  = STATE_HEART_FADING;
            this.rad_target  = 0;
        }
    }
  
    //------------------------------
    setMouseState (mState) {
        this.mouseState = mState;
        if (this.existState != STATE_HEART_GONE) {
            switch(this.mouseState) {
    
            case STATE_MOUSE_DRAG: 
                this.existState = STATE_HEART_EXISTS;
                this.rad_target = HEART_DRAG_RADIUS;
                this.colr = this.colrt = 255;
                this.colg = this.colgt = 128;
                this.colb = this.colbt = 0;
                break;
    
            case STATE_MOUSE_SELECT:
                this.existState = STATE_HEART_EXISTS;
                this.rad_target = HEART_SELECT_RADIUS;
                this.colr = this.colrt = 255;
                this.colg = this.colgt = 100;
                this.colb = this.colbt = 0;
                break;
    
            case STATE_MOUSE_OVER:
                this.existState = STATE_HEART_EXISTS;
                this.rad_target = HEART_OVER_RADIUS;
                this.colr = this.colrt = 0;//255;
                this.colg = this.colgt = 0;
                this.colb = this.colbt = 255;//64;
                break;
    
            case STATE_MOUSE_IGNORE:
                if (this.existState == STATE_HEART_EXISTS) {
                    this.rad_target = this.rad_backup;
                } 
                else { // if existState == STATE_HEART_FADING || existState == STATE_HEART_GONE
                    this.rad_target = 0;
                }
                this.colrt = colrb;
                this.colgt = colgb;
                this.colbt = colbb;
                break;
            }
        }
    }
  
    //-----------------------------
    render () {
        if (existState != STATE_HEART_GONE) {
            fill (colr, colg, colb);
            ellipse (px, py, diam, diam);
        }
    }
  
    //---------------------------------------------------
    renderMouseOver () {
        noStroke();
        fill(this.colr, this.colg, this.colb);
        ellipse (this.px, this.py, this.diam, this.diam);
        fill(this.innerColorOver);
        ellipse (this.px, this.py, this.diam-12, this.diam-12);
    }
  
    //---------------------------------------------------
    renderMouseSelected () {
        stroke(0, 0, 0);
        fill(this.colr, this.colg, this.colb);
        ellipse (this.px, this.py, this.diam, this.diam);
        noStroke();
        fill(this.innerColorSelected);
        ellipse (this.px, this.py, this.diam-12, this.diam-12);
    }
}