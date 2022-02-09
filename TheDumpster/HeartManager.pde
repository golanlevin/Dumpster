import java.applet.*; 
import java.awt.*; 
import java.awt.image.*; 
import java.awt.event.*; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 


public class HeartManager {

  KnowerOfSelections KOS; 

  float 	myMouseX;
  float	myMouseY;
  boolean	bMousePressed;
  FPoint 	handyPoint;

  Heart 	hearts[]; 

  int 		mouseOverHeartID     = -1;
  int 		mouseClickedHeartID 	= -1;
  int 		mouseSelectedHeartID = -1;
  boolean 	bCurrentlyDraggingSelectedHeart;

  BreakupManager BM;
  TheDumpster mom;

  //====================================================================
  HeartManager (KnowerOfSelections kos, BreakupManager bm, TheDumpster td) {

    bMousePressed = false;
    myMouseX = myMouseY = 0;
    KOS = kos;
    BM = bm;
    mom = td;

    handyPoint = new FPoint();
    hearts = new Heart[MAX_N_HEARTS];
    for (int i=0; i<MAX_N_HEARTS; i++) {
      hearts[i] = new Heart(i, BM, td);
    }
  }




  //====================================================================
  void decimateCurrentHeartPopulation() {

    ParagraphBalloonManager PBM = mom.PBM;
    int nExtantBalloons = PBM.nExtantBalloons;

    int nToKill = 10;
    for (int i=0; i< nToKill; i++) {
      int randId = (int)(Math.random() * MAX_N_HEARTS);
      if ((hearts[randId].mouseState == STATE_MOUSE_IGNORE) && 
        (hearts[randId].existState == STATE_HEART_EXISTS)) {

        boolean bRandIdOk = true;
        for (int b=0; b<nExtantBalloons; b++) {
          int heartId = PBM.balloons[b].heartId;
          if (randId == heartId) {
            bRandIdOk = false;
          }
        }
        if (bRandIdOk) {
          hearts[randId].initiateDisappearance();
        }
      }
    }
  }



  //====================================================================
  int addSelectedBreakupFromOutsideAndGetNewHeartId (int newBreakupIndex) {
    // Note that this calls causeHeartToBecomeTheMainSelection();

    int newHeartId = DUMPSTER_INVALID;

    // first, check to see if there is already a heart present containing this breakup. 
    boolean bBreakupAlreadyPresent = false;
    int indexOfHeartAlreadyContainingNewBreakupIndex = DUMPSTER_INVALID;
    for (int i=0; i<MAX_N_HEARTS; i++) {
      Heart Hi = hearts[i];
      if (Hi.existState == STATE_HEART_EXISTS) {
        if (newBreakupIndex == Hi.breakupId) {
          bBreakupAlreadyPresent = true;
          indexOfHeartAlreadyContainingNewBreakupIndex = i;
        }
      }
    }

    // if the breakup is already present, all we have to do is select that heart.
    // otherwise, add it from the outside, and then select it.
    if (bBreakupAlreadyPresent == true) {

      // now SELECT that heart, indexOfHeartAlreadyContainingNewBreakupIndex!
      if (indexOfHeartAlreadyContainingNewBreakupIndex != mouseSelectedHeartID) {
        causeHeartToBecomeTheMainSelection (indexOfHeartAlreadyContainingNewBreakupIndex);
        newHeartId = indexOfHeartAlreadyContainingNewBreakupIndex;
      }
    } 
    else if (bBreakupAlreadyPresent == false) {
      // the breakup is not already present. 
      // therefore in order to add it, we have to remove one. 
      // we may need to do it on-the-spot, 
      // and not wait for a hole to appear. 
      ParagraphBalloonManager PBM = mom.PBM;
      int nExtantBalloons = PBM.nExtantBalloons;

      // first, check to see if there is a hole available. 
      int j=0;
      int indexOfAvailableHeart = DUMPSTER_INVALID;
      boolean bFoundOne = false;
      while ( (bFoundOne == false) && (j<MAX_N_HEARTS)) {
        Heart Hi = hearts[j];
        if (Hi.existState == STATE_HEART_GONE) { 
          indexOfAvailableHeart = j;
          bFoundOne = true;
        } 
        j++;
      }

      // if there is no blank heart available, we're going to have to kill one
      // with extreme prejudice. Let's kill the one with the least similarity.
      // make sure that it's not attached to an active ballon. 
      if (indexOfAvailableHeart == DUMPSTER_INVALID) {
        float leastSimilarity = 1.0f;
        int heartIdWithLeastSimilarity = DUMPSTER_INVALID;
        for (int i=0; i<MAX_N_HEARTS; i++) {
          int hBupid = hearts[i].breakupId;
          float hSim = BM.SIMILARITIES[hBupid];

          if (hSim < leastSimilarity) {
            // make sure the heart is not attached to an active balloon
            boolean bNotAttachedToBalloon = true;
            for (int b=0; b<nExtantBalloons; b++) {
              int heartId = PBM.balloons[b].heartId;
              if (i == heartId) { 
                bNotAttachedToBalloon = false;
              }
            }
            if (bNotAttachedToBalloon) {
              hSim = leastSimilarity;
              heartIdWithLeastSimilarity = i;
            }
          }
        }
        if (heartIdWithLeastSimilarity != DUMPSTER_INVALID) {
          // take the heart with the least similarity, that is not attached to a balloon.
          indexOfAvailableHeart = heartIdWithLeastSimilarity;
        } 
        else {
          // total emergency fallback. take the first heart not attached to a balloon.
          for (int i=0; i<MAX_N_HEARTS; i++) {
            int hBupid = hearts[i].breakupId;
            boolean bNotAttachedToBalloon = true;
            for (int b=0; b<nExtantBalloons; b++) {
              int heartId = PBM.balloons[b].heartId;
              if (i == heartId) { 
                bNotAttachedToBalloon = false;
              }
            }
            if (bNotAttachedToBalloon) {
              indexOfAvailableHeart = i;
              break;
            }
          }
        }
      }

      // we should now have an indexOfAvailableHeart.
      if (indexOfAvailableHeart != DUMPSTER_INVALID) {
        // if we've found an available heart index, 
        // replace it with a heart that has the newBreakupIndex.
        float similarityOfRandomBreakup = 1.0f;// BM.SIMILARITIES[newBreakupIndex]; 
        hearts[indexOfAvailableHeart].initiate (newBreakupIndex, similarityOfRandomBreakup);

        // now SELECT that heart, indexOfAvailableHeart!
        if (indexOfAvailableHeart != mouseSelectedHeartID) {
          causeHeartToBecomeTheMainSelection (indexOfAvailableHeart);
          newHeartId = indexOfAvailableHeart;
        }
      }
    }

    return newHeartId;
  }



  //====================================================================
  void causeHeartToBecomeTheMainSelection (int heartId) {
    // this is only visual, it just visually selects a heart

    if ((heartId > DUMPSTER_INVALID) && (heartId < MAX_N_HEARTS)) {
      if (hearts[heartId].existState != STATE_HEART_GONE) { 

        // if there is already a current selection, and its not == heartId,
        // then set that current selection to STATE_MOUSE_IGNORE.
        if ((heartId != mouseSelectedHeartID) && (mouseSelectedHeartID != DUMPSTER_INVALID)) {
          hearts[mouseSelectedHeartID].setMouseState (STATE_MOUSE_IGNORE);
        }

        mouseSelectedHeartID = heartId;
        mouseClickedHeartID  = heartId;
        hearts[mouseSelectedHeartID].setMouseState (STATE_MOUSE_SELECT);
        bCurrentlyDraggingSelectedHeart = false;

        int clickedHeartBreakupID = hearts[mouseClickedHeartID].breakupId;
        KOS.currentSelectedBreakupId = clickedHeartBreakupID; ///KOS
      }
    }
  }




  //====================================================================
  float computeMeanSimilarity() {
    // calculate the mean similarity of hearts to the current heart.
    // we will ensure to remove a heart whose similarity is less than average, 
    // and will ensure to add a heart whose similarity is above average.
    float nExtant = 0;
    float meanSimilarity = 0;
    for (int i=0; i<MAX_N_HEARTS; i++) {
      if (hearts[i].existState == STATE_HEART_EXISTS) {
        float sim = hearts[i].similarityToSelected;
        meanSimilarity += sim;
        nExtant++;
      }
    }
    meanSimilarity /= nExtant;
    return meanSimilarity;
  }

  //====================================================================
  void removeBadMatchingHeartRandomly (float meanSimilarity) {

    // remove old ones on a random schedule.
    float randomChanceOut = (float)Math.random();
    if (randomChanceOut < HM_SHUFFLE_PROBABILITY) {

      ParagraphBalloonManager PBM = mom.PBM;
      int nExtantBalloons = PBM.nExtantBalloons;

      // threshold is 10% higher than meanSimilarity
      float slop = HM_SHUFFLE_SLOP;
      float A = 1.0f - slop;
      float B = slop;
      float similarityThreshold = (A*meanSimilarity) + (B * 1.0f); 


      boolean bFoundBelowAverageHeart = false;
      int randHeartId = (int)(Math.random() * MAX_N_HEARTS);
      float similarityOfRandHeartId = 1.0f;
      int nTriesToFindSafetyCheck = 0;

      do {
        // pick a random heart.
        randHeartId = (int)(Math.random() * MAX_N_HEARTS);

        // make sure the heart exists and is not currently in focus;
        if ((hearts[randHeartId].mouseState == STATE_MOUSE_IGNORE) && 
          (hearts[randHeartId].existState == STATE_HEART_EXISTS)) {

          // make sure the heart's similarity is lower than average;
          similarityOfRandHeartId = hearts[randHeartId].similarityToSelected;
          if ((similarityOfRandHeartId <= similarityThreshold) || (meanSimilarity < 0.01f)) {

            // make sure the heart is not attached to an active balloon
            boolean bRandIdOk = true;
            for (int b=0; b<nExtantBalloons; b++) {
              int heartId = PBM.balloons[b].heartId;
              if (randHeartId == heartId) { 
                bRandIdOk = false;
              }
            }

            // if it's not attached, and below average, we found it.
            if (bRandIdOk) {
              bFoundBelowAverageHeart = true;
            }
          }
        }
        nTriesToFindSafetyCheck++;
      } 
      while ( (bFoundBelowAverageHeart == false) && (nTriesToFindSafetyCheck < 20));

      if (bFoundBelowAverageHeart) {
        hearts[randHeartId].initiateDisappearance();
      }
    }
  }


  //====================================================================
  void addWellMatchingHeartRandomly (float meanSimilarity) {

    // make a new one to replace missing hearts.
    float randomChanceIn = (float)Math.random();
    if (randomChanceIn < 0.975f) {

      // find the missing hole;
      int j=0;
      boolean bFoundOne = false;
      int indexOfAvailableHeart = DUMPSTER_INVALID;
      while ( (bFoundOne == false) && (j<MAX_N_HEARTS)) {
        Heart Hi = hearts[j];
        if (Hi.existState == STATE_HEART_GONE) { 
          indexOfAvailableHeart = j;
          bFoundOne = true;
        }
        j++;
      }

      // if we found a heart which is available; 
      if (indexOfAvailableHeart != DUMPSTER_INVALID) {

        // threshold is 10% lower than meanSimilarity
        float slop = HM_SHUFFLE_SLOP;
        float A = 1.0f - slop;
        float B = slop;
        float similarityThreshold = (A*meanSimilarity) + (B * 0.0f); 

        int nTries = 0;
        int newBreakupIndex = (int)(Math.random()*(float)N_BREAKUP_DATABASE_RECORDS_20K);
        float similarityOfRandomBreakup = 0.0f;

        int nRealTries = 0;
        if (meanSimilarity < 0.10f) {
          similarityOfRandomBreakup = BM.SIMILARITIES[newBreakupIndex];
        } 
        else {

          do {
            boolean bRandomBreakupIsAlreadyRepresented = false;
            boolean bRandomBreakupIsBadData = false;
            do {
              // now find a breakup which is not 
              // already represented among the active hearts,
              // and make sure it has better than average similarity;
              bRandomBreakupIsAlreadyRepresented = false;
              bRandomBreakupIsBadData = false;

              newBreakupIndex = (int)(Math.random()*(float)N_BREAKUP_DATABASE_RECORDS_20K);
              for (int i=0; i<MAX_N_HEARTS; i++) {
                if (newBreakupIndex == hearts[i].breakupId) {
                  bRandomBreakupIsAlreadyRepresented = true;
                }
              }
              if (BM.bups[newBreakupIndex].VALID == false) {
                bRandomBreakupIsBadData = true;
              }
            } 
            while ( (bRandomBreakupIsAlreadyRepresented == true) || (bRandomBreakupIsBadData == true)); 

            similarityOfRandomBreakup = BM.SIMILARITIES[newBreakupIndex];
            nTries++;
          } 
          while ( (similarityOfRandomBreakup < similarityThreshold) && (nTries < 80));
        }

        // System.out.println(nTries + " mean = " + meanSimilarity);
        hearts[indexOfAvailableHeart].initiate (newBreakupIndex, similarityOfRandomBreakup);
      }
    }
  }




  //====================================================================
  void performScheduledShuffling() {

    float meanSimilarity = computeMeanSimilarity();
    removeBadMatchingHeartRandomly (meanSimilarity);
    addWellMatchingHeartRandomly   (meanSimilarity);
  }


  //====================================================================
  int getHeartIdWithBreakupId (int whichBreakup) {
    int resultHeartId = DUMPSTER_INVALID; 
    if ((whichBreakup >= 0) && (whichBreakup < N_BREAKUP_DATABASE_RECORDS)) {

      for (int i=0; i<MAX_N_HEARTS; i++) {
        Heart hi = hearts[i];

        if (hi.breakupId == whichBreakup) {
          if (hi.existState != STATE_HEART_GONE) {
            resultHeartId = hi.heartId;
          }
        }
      }
    }
    return resultHeartId;
  }

  //====================================================================
  FPoint getHeartLoc (int whichHeartId) {
    handyPoint.px = DUMPSTER_INVALID;
    handyPoint.py = DUMPSTER_INVALID;
    if ((whichHeartId >= 0) && (whichHeartId < MAX_N_HEARTS)) {
      Heart hi = hearts[whichHeartId];
      if (hi.existState != STATE_HEART_GONE) {
        handyPoint.px = hi.px;
        handyPoint.py = hi.py;
      }
    }
    return handyPoint;
  }


  //====================================================================
  void informOfMouse (float mx, float my, boolean bm) {
    bMousePressed = bm;
    myMouseX = mx;
    myMouseY = my;
  }

  //====================================================================
  void mousePressed() {
    mouseClickedHeartID = DUMPSTER_INVALID;
    bCurrentlyDraggingSelectedHeart = false;
    int whichClicked = whichHeartIsMouseInside();

    if    (whichClicked != DUMPSTER_INVALID) {
      if ((whichClicked != mouseSelectedHeartID) && (mouseSelectedHeartID != -1)) {
        hearts[mouseSelectedHeartID].setMouseState (STATE_MOUSE_IGNORE);
      }
      mouseSelectedHeartID = whichClicked;
      mouseClickedHeartID  = whichClicked;
      hearts[mouseSelectedHeartID].setMouseState (STATE_MOUSE_DRAG);
      bCurrentlyDraggingSelectedHeart = true;

      //----------- KOS 
      if (mouseClickedHeartID != DUMPSTER_INVALID) {
        int clickedHeartBreakupID = hearts[mouseClickedHeartID].breakupId;
        KOS.currentSelectedBreakupId = clickedHeartBreakupID;
      }
    }
  }

  //====================================================================
  void refreshHeartColors (BreakupManager BM, int clickedHeartBreakupID) {
    if ((clickedHeartBreakupID > DUMPSTER_INVALID) &&
      (clickedHeartBreakupID < N_BREAKUP_DATABASE_RECORDS)) {

      float sim; 
      int heartBupId;

      for (int i=0; i<MAX_N_HEARTS; i++) {
        heartBupId = hearts[i].breakupId;
        if (heartBupId != DUMPSTER_INVALID) {
          sim = BM.SIMILARITIES[heartBupId];
          hearts[i].setSimilarityToSelected(sim);
        }
      }
    }
  }

  //====================================================================
  void mouseReleased() {
    bCurrentlyDraggingSelectedHeart = false;
  }


  //====================================================================
  void renderHeartObjects() {


    ellipseMode (CENTER);
    // noSmooth();
    noStroke();
    // smooth(); 

    for (int i=0; i<MAX_N_HEARTS; i++) {
      hearts[i].render();
    } // render the bulk of hearts.
    if ((mouseOverHeartID != DUMPSTER_INVALID) && (mouseOverHeartID != mouseSelectedHeartID)) {
      hearts[mouseOverHeartID].renderMouseOver();
    } // render the hover heart.
    if (mouseSelectedHeartID != DUMPSTER_INVALID) {
      hearts[mouseSelectedHeartID].renderMouseSelected();
    } // render the selected heart.

    // noSmooth();
  }


  //====================================================================
  int whichHeartIsMouseInside () {
    int result = -1;
    if ((myMouseX > HEART_WALL_L) && (myMouseX < HEART_WALL_R) && (myMouseY > HEART_WALL_T) && (myMouseY < HEART_WALL_B)) {
      int mxbin = (int)(7.99999f * (myMouseX-HEART_WALL_L)/HEART_AREA_W);
      int mybin = (int)(7.99999f * (myMouseY-HEART_WALL_T)/HEART_AREA_H);
      short myMouseXbins = bindices[mxbin];
      short myMouseYbins = bindices[mybin];
      Heart Hi;
      float dx, dy, dh2;

      for (int i=0; i<MAX_N_HEARTS; i++) {
        Hi = hearts[i];
        if (Hi.existState != STATE_HEART_GONE) {
          if (((myMouseXbins & Hi.xbins)>0) && ((myMouseYbins & Hi.ybins)>0)) {
            if ((myMouseX >= Hi.xMin) && (myMouseX <= Hi.xMax) && (myMouseY >= Hi.yMin) && (myMouseY <=  Hi.yMax)) {
              dx = Hi.px - myMouseX;
              dy = Hi.py - myMouseY;
              dh2 = (dx*dx + dy*dy);
              if (dh2 < Hi.rad_sq) {
                result = i;
                break;
              }
            }
          }
        }
      }
    }
    return result;
  }




  //====================================================================
  void mouseTestHearts() {

    mouseOverHeartID = whichHeartIsMouseInside();

    // reset all hearts to default mode;
    for (int i=0; i<MAX_N_HEARTS; i++) {
      hearts[i].setMouseState (STATE_MOUSE_IGNORE);
    }

    // highlight the mouseOver heart
    if (mouseOverHeartID != -1) { // if there is a current mouseOver
      if (bMousePressed) {  // if the mouse is pressed
        if (bCurrentlyDraggingSelectedHeart == false) {
          if (mouseOverHeartID != mouseSelectedHeartID) {
            hearts[mouseOverHeartID].setMouseState (STATE_MOUSE_OVER);
          }
        }
      } 
      else { // if not mousePressed
        if (mouseOverHeartID != mouseSelectedHeartID) {
          // if the mouseOver is not the selected one
          hearts[mouseOverHeartID].setMouseState (STATE_MOUSE_OVER);
        } 
        else if (mouseOverHeartID == mouseSelectedHeartID) {
          // if we're over the selected one, but not pressed,
          hearts[mouseSelectedHeartID].setMouseState (STATE_MOUSE_SELECT);
        }
      }
    }


    // always refresh the selected one's knowledge of its state.
    if (mouseSelectedHeartID != -1) {
      hearts[mouseSelectedHeartID].setMouseState (STATE_MOUSE_SELECT);
    

      if ( (mouseOverHeartID == mouseSelectedHeartID) && bMousePressed) {
        if (bCurrentlyDraggingSelectedHeart == true) {
          hearts[mouseSelectedHeartID].setMouseState (STATE_MOUSE_DRAG);
        }
      }
    }

    if (mouseOverHeartID != -1) {
      Heart Hi = hearts[mouseOverHeartID];
      
      //if (bMousePressed) {
      //  hearts[mouseOverHeartID].px = myMouseX;
      //  hearts[mouseOverHeartID].py = myMouseY;
      //  hearts[mouseSelectedHeartID].setMouseState (STATE_MOUSE_DRAG);
      //} 
      //else {

        float dx = Hi.px - myMouseX;
        float dy = Hi.py - myMouseY;
        float dh2 = (dx*dx + dy*dy);
        if (dh2 < Hi.rad_sq) {

          float fx = HEART_MOUSE_K * dx;
          float fy = HEART_MOUSE_K * dy;
          hearts[mouseOverHeartID].accumulateForce (fx, fy);
        }
      
    }

    //----------- KOS
    if (mouseOverHeartID != DUMPSTER_INVALID) {
      int mouseoverHeartBreakupID = hearts[mouseOverHeartID].breakupId;
      KOS.currentMouseoverBreakupId = mouseoverHeartBreakupID;
    } 
    else if (mouseOverHeartID == DUMPSTER_INVALID) {
      if ((myMouseX >= HEART_WALL_L) && (myMouseX < HEART_WALL_R) && 
        (myMouseY >= HEART_WALL_T) && (myMouseY < HEART_WALL_B)) {
        KOS.currentMouseoverBreakupId = DUMPSTER_INVALID;
      }
    }
  }


  //====================================================================
  void updateHearts() {
    Heart Hi;
    Heart Hj;
    float xi, yi;
    float imassInv, jmassInv;
    float irad, jrad;
    float ixMin, ixMax, iyMin, iyMax;
    float dx, dy, dh2, dh;
    float fx, fy;
    float overlap;
    float lapforce;
    short ixbins, iybins;

    hearts[0].setMouseInformation (bCurrentlyDraggingSelectedHeart, myMouseX, myMouseY);


    // environmental forces.
    for (int i=0; i<MAX_N_HEARTS; i++) {
      Hi = hearts[i];
      Hi.accumulateGravityForce();
      Hi.accumulateCentralizingForce();
    }

    // attraction force to cursor.
    if (mouseSelectedHeartID != -1) {
      Hi = hearts[mouseSelectedHeartID];
      float spx = Hi.px;
      float spy = Hi.py;
      float spr = Hi.rad;
      for (int i=0; i<MAX_N_HEARTS; i++) {
        if (i!=mouseSelectedHeartID) {
          hearts[i].accumulateAttractionForceToSelected (spx, spy, spr);
        } 
        else {
          if (bMousePressed){
            hearts[mouseSelectedHeartID].px = myMouseX;
            hearts[mouseSelectedHeartID].py = myMouseY;
            hearts[mouseSelectedHeartID].setMouseState (STATE_MOUSE_DRAG);
          }
          //println(millis() + ": " + mouseSelectedHeartID + " is " + hearts[mouseSelectedHeartID].mouseState);
        }
      }
    }

    // inter-heart forces.
    for (int i=0; i<MAX_N_HEARTS; i++) {
      Hi = hearts[i];
      if (Hi.existState != STATE_HEART_GONE) {
        xi = Hi.px;
        yi = Hi.py;

        ixMin = Hi.xMin;
        ixMax = Hi.xMax;
        iyMin = Hi.yMin;
        iyMax = Hi.yMax;
        irad =  Hi.rad;
        ixbins = Hi.xbins;
        iybins = Hi.ybins;

        for (int j=0; j<i; j++) {
          Hj = hearts[j];
          if (Hj.existState != STATE_HEART_GONE) {
            if (((ixbins & Hj.xbins) > 0) && ((iybins & Hj.ybins) > 0)) {

              // accumulate intersection-penalty spring force if overlap
              if (((ixMin > Hj.xMax) || (Hj.xMin > ixMax) || (iyMin > Hj.yMax) || (Hj.yMin > iyMax)) == false) {
                dx = xi- Hj.px;
                dy = yi- Hj.py;
                dh2 = (dx*dx + dy*dy);
                dh = (float)Math.sqrt (dh2);
                overlap = dh - (irad + Hj.rad);

                if (overlap < HEART_MIN_OVERLAP_DIST) {
                  lapforce = HEART_COLLISION_K * overlap;
                  fx = dx*lapforce;
                  fy = dy*lapforce;
                  imassInv = 1.0f/Hi.mass;
                  jmassInv = 1.0f/Hj.mass;
                  Hi.vx = HEART_COLLISION_DAMPING * (Hi.vx + fx*imassInv); // accumForce then damp
                  Hi.vy = HEART_COLLISION_DAMPING * (Hi.vx + fy*imassInv);
                  Hj.vx = HEART_COLLISION_DAMPING * (Hj.vx - fx*jmassInv);
                  Hj.vy = HEART_COLLISION_DAMPING * (Hj.vy - fy*jmassInv);
                }
              }
            }
          }
        }
      }
    }

    for (int i=0; i<MAX_N_HEARTS; i++) {
      hearts[i].update();
    }
  }
}
