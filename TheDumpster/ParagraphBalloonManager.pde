//import java.net.MalformedURLException;
//import java.net.URL;

//======================================================================================
//======================================================================================

class ParagraphBalloonManager {

  URL QUOTE_URL; 

  int currentBreakupID;
  int mouseoverBalloonID;

  int nExtantBalloons;
  int currentBalloonIndex;

  float mouseX;
  float mouseY;

  boolean bMousePressed;
  boolean bNewRequestMade;

  PFont paragraphFont;
  ParagraphBalloon balloons[];

  private final PooledExecutor executor = new PooledExecutor(new LinkedQueue(), 4);

  //======================================================================================
  public ParagraphBalloonManager() {
    try {
      QUOTE_URL = new URL("http://artport.whitney.org/commissions/thedumpster/encrypted/");
    } 
    catch (Exception e) {
      ;
    }

    paragraphFont = loadFont("Georgia-Italic-9.vlw");

    nExtantBalloons = 0;
    currentBalloonIndex = DUMPSTER_INVALID;
    mouseoverBalloonID = DUMPSTER_INVALID;

    bNewRequestMade = false;


    boolean bOnlyLoading = true;
    balloons = new ParagraphBalloon[MAX_N_BALLOONS];
    for (int i = 0; i < MAX_N_BALLOONS; i++)
    {
      balloons[i] = new ParagraphBalloon();
      balloons[i].setFont(paragraphFont);
      balloons[i].setStringAndComputeLayout("", DUMPSTER_INVALID, bOnlyLoading);
    }
  }

  //====================================================================
  void informOfMouse(float mx, float my, boolean bm)
  {
    bMousePressed = bm;
    mouseX = mx;
    mouseY = my;
  }

  //-----------------------------
  void execute(int breakupId, int heartId)
  {
    // This is where requests for new breakups are made. 
    // This function is called by the Applet (on mousePressed), which passes
    // in the desired breakupId (message id) and its corresponding Heart blob.


    if ((breakupId < N_BREAKUP_DATABASE_RECORDS) && (breakupId >= 0))
    {

      int alreadyBalloonIndex = findIndexOfBalloonAlreadyContainingBreakupId(breakupId);
      if (alreadyBalloonIndex != DUMPSTER_INVALID)
      {
        // If we have already requested this breakup recently.

        if (alreadyBalloonIndex == currentBalloonIndex)
        {
          // System.out.println("clicked again"); 
          // Don't do anything. The re-clicked balloon is already on top.
        }
        else
        {

          // Store the alreadyData (moving item) as temp. 
          float tempPy = balloons[alreadyBalloonIndex].py;
          ParagraphBalloon tempBalloon = balloons[alreadyBalloonIndex];

          if (alreadyBalloonIndex < currentBalloonIndex)
          { // Case I.

            // Copy (i+1) to (i) for (alreadyBalloonIndex < currentBalloonIndex)
            for (int i = alreadyBalloonIndex; i < currentBalloonIndex; i++) {
              balloons[i] = balloons[(i + 1) % MAX_N_BALLOONS];
            }
            // Copy temp to curr; DON'T advance currentBalloonIndex.
            balloons[currentBalloonIndex] = tempBalloon;

            balloons[currentBalloonIndex].setPositionY(tempPy);
            balloons[currentBalloonIndex].setTargetY(BALLOON_START_Y);

            // Retarget
            float starty = balloons[currentBalloonIndex].targety;
            for (int i = 0; i < nExtantBalloons; i++)
            {
              int bid = (currentBalloonIndex - i + MAX_N_BALLOONS) % MAX_N_BALLOONS;
              balloons[bid].setTargetY(starty);
              starty += balloons[bid].ph + BALLOON_SPACING_Y;
            }
          }
          else if (alreadyBalloonIndex > currentBalloonIndex)
          { // Case II.

            for (int i = (alreadyBalloonIndex - 1); i > currentBalloonIndex; i--) {
              balloons[(i + 1) % MAX_N_BALLOONS] = balloons[i];
            }

            // Copy temp to curr+1
            balloons[(currentBalloonIndex + 1) % MAX_N_BALLOONS] = tempBalloon;

            // Advance.
            currentBalloonIndex = (currentBalloonIndex + 1) % MAX_N_BALLOONS;
            nExtantBalloons = Math.min((nExtantBalloons + 1), MAX_N_BALLOONS);

            balloons[currentBalloonIndex].setPositionY(tempPy);
            balloons[currentBalloonIndex].setTargetY(BALLOON_START_Y);

            // Retarget
            float starty = balloons[currentBalloonIndex].targety;
            for (int i = 0; i < nExtantBalloons; i++)
            {
              int bid = (currentBalloonIndex - i + MAX_N_BALLOONS) % MAX_N_BALLOONS;
              balloons[bid].setTargetY(starty);
              starty += balloons[bid].ph + BALLOON_SPACING_Y;
            }
          }
        }
      }
      else
      {

        currentBalloonIndex = (currentBalloonIndex + 1) % MAX_N_BALLOONS;
        nExtantBalloons = Math.min((nExtantBalloons + 1), MAX_N_BALLOONS);

        String breakupVerb = BALLOON_LOADING_STRING;

        balloons[currentBalloonIndex].setStringAndComputeLayout(breakupVerb, breakupId, true);
        balloons[currentBalloonIndex].setPositionY(BALLOON_START_Y);
        balloons[currentBalloonIndex].heartId = heartId;
        bNewRequestMade = true;

        try {
          executor.execute(new SadnessFetcher(QUOTE_URL, breakupId, balloons[currentBalloonIndex]));
        }
        catch (InterruptedException e) {
          System.err.println(e.toString());
        }
      }
    }
  }

  //======================================================================================
  int findIndexOfBalloonAlreadyContainingBreakupId(int breakupId)
  {
    int alreadyBalloonIndex = DUMPSTER_INVALID;
    for (int i = 0; i < nExtantBalloons; i++)
    {
      int prevBreakupId = balloons[i].breakupId;

      if (breakupId == prevBreakupId)
      {
        alreadyBalloonIndex = i;
        break;
      }
    }
    return alreadyBalloonIndex;
  }

  //======================================================================================
  void render()
  {

    //This is called every frame by the Applet

    update();

    noTint();
    noStroke();
    // noSmooth();

    textMode(MODEL) ;
    textFont(paragraphFont);
    for (int i = 0; i < nExtantBalloons; i++)
    {

      balloons[i].informOfCurrency((i == currentBalloonIndex));

      if (i == mouseoverBalloonID)
      {
        balloons[i].render(true);
      }
      else
      {
        balloons[i].render(false);
      }
    }
  }

  //======================================================================================
  int getMouseContainingBalloon()
  {
    int resultIndex = DUMPSTER_INVALID;
    if ((mouseX > HEART_WALL_L) && (mouseY < HEART_WALL_B) && (mouseX < HEART_WALL_R)
      && (mouseY > HEART_WALL_T))
    {

      for (int i = 0; i < nExtantBalloons; i++)
      {
        float px = balloons[i].px;
        float py = balloons[i].py;
        float pw = balloons[i].pw;
        float ph = balloons[i].ph;
        if ((mouseX > px) && (mouseX < (px + pw)))
        {
          if ((mouseY > py) && (mouseY < (py + ph)))
          {
            resultIndex = i;
            break;
          }
        }
      }
    }
    mouseoverBalloonID = resultIndex;
    return resultIndex;
  }

  //======================================================================================
  void update()
  {
    // This is called every frame by the render() method.

    retargetBalloons();

    //--------------------------------------
    // Update all positions
    for (int i = 0; i < nExtantBalloons; i++)
    {
      balloons[i].updatePositionY();
    }
  }

  //======================================================================================
  private void retargetBalloons()
  {
    // Re-position the balloons spatially, because new text has arrived, 
    // or a new balloon has been added, which means everyone has to move downward.

    if (bNewRequestMade)
    {
      bNewRequestMade = false;
      float starty = balloons[currentBalloonIndex].py;
      starty += balloons[currentBalloonIndex].ph + BALLOON_SPACING_Y;

      if (nExtantBalloons < MAX_N_BALLOONS)
      {
        for (int i = (currentBalloonIndex - 1); i >= 0; i--)
        {
          balloons[i].setTargetY(starty);
          starty += balloons[i].ph + BALLOON_SPACING_Y;
        }
      }
      else if (nExtantBalloons == MAX_N_BALLOONS)
      {
        for (int i = 1; i < MAX_N_BALLOONS; i++)
        {
          int bid = (currentBalloonIndex - i + MAX_N_BALLOONS) % MAX_N_BALLOONS;
          balloons[bid].setTargetY(starty);
          starty += balloons[bid].ph + BALLOON_SPACING_Y;
        }
      }
    }





    for (int b=0; b<nExtantBalloons; b++) {

      if (balloons[b].bNewTextAppeared) {
        balloons[b].bNewTextAppeared = false;
        // Retarget positions if new text has appeared

        int BI = b;
        int ni = BI;
        float starty = balloons[ni].py + balloons[ni].ph + BALLOON_SPACING_Y;

        if (nExtantBalloons < MAX_N_BALLOONS) {
          for (int i = ni - 1; i >= 0; i--) {
            balloons[i].setTargetY(starty);
            starty += balloons[i].ph + BALLOON_SPACING_Y;
          }
        }
        else {
          // the full set of balloons is now in use. 
          if (currentBalloonIndex == BI) {
            // just do the whole batch
            for (int i = 1; i < MAX_N_BALLOONS; i++) {
              int bid = (currentBalloonIndex - i + MAX_N_BALLOONS) % MAX_N_BALLOONS;
              balloons[bid].setTargetY(starty);
              starty += balloons[bid].ph + BALLOON_SPACING_Y;
            }
          }
          else if (currentBalloonIndex > BI) {
            // deal with wraparound.
            for (int i = ni - 1; i >= 0; i--) {
              balloons[i].setTargetY(starty);
              starty += balloons[i].ph + BALLOON_SPACING_Y;
            }
            for (int i = (MAX_N_BALLOONS - 1); i > currentBalloonIndex; i--) {
              balloons[i].setTargetY(starty);
              starty += balloons[i].ph + BALLOON_SPACING_Y;
            }
          }
          else if (currentBalloonIndex < BI) {
            // just count down from ni to curr
            for (int i = ni - 1; i > currentBalloonIndex; i--) {
              balloons[i].setTargetY(starty);
              starty += balloons[i].ph + BALLOON_SPACING_Y;
            }
          }
        }
      }
    }
  }

  //======================================================================================
  public float getTopBalloonCenterY()
  {
    float out = -1;
    if ((nExtantBalloons > 0) && (currentBalloonIndex > -1))
    {
      float py = balloons[currentBalloonIndex].py;
      float ph = balloons[currentBalloonIndex].ph;
      out = py + ph / 2.0f;
    }
    return out;
  }
}
