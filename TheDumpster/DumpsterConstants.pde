



 final boolean KIOSK_MODE = true;

 final int   DUMPSTER_INVALID  = -1;
 final float DUMPSTER_APP_W    = 1280;
 final float DUMPSTER_APP_H    = 800;


 final int   MAX_N_BALLOONS    = 14;
 final float HISTOGRAM_SPACE_OCCUPANCY = 0.85f;
 final int   DUMPSTER_LONELY_TIME = 5000;

 final float HM_SHUFFLE_PROBABILITY   = 0.0925f;

 final float HD_TEXT_BLURA        = 0.5f;
 final float HD_TEXT_BLURB        = (1.0f- HD_TEXT_BLURA);
 final float DH_BLURA            = 0.7f;
 final float DH_BLURB            = (1.0f- DH_BLURA);

//-------------------------------------------------------------
 final int   N_BREAKUP_LANGUAGE_DESCRIPTORS = 7;
 final int   N_BREAKUP_LANGUAGE_BITFLAGS = 4;
 final int   PIXELVIEW_H      = 222; // DUMPSTER_APP_H - HISTOGRAM_H;
 final int   PIXELVIEW_W      = 90;  // HEART_WALL_L
 final int   PIXELVIEW_L      = 1;
 final int   PIXELVIEW_T      = 1;
 final int   PIXELVIEW_SCALE  = 3;
 final int   MALE_BLUE_AMOUNT  = 45;
 final float HISTOGRAM_H       = DUMPSTER_APP_H - PIXELVIEW_H*PIXELVIEW_SCALE; //79;
//-------------------------------------------------------------
 final float HEART_WALL_L       = PIXELVIEW_W*PIXELVIEW_SCALE +2;
 final float HEART_WALL_R       = DUMPSTER_APP_W-2;
 final float HEART_WALL_T       = 1;
 final float HEART_WALL_B       = DUMPSTER_APP_H - HISTOGRAM_H;
 final float HEART_AREA_W       = HEART_WALL_R - HEART_WALL_L;
 final float HEART_AREA_H       = HEART_WALL_B - HEART_WALL_T;
 final float opt_8dHA_W         = 7.99999f/HEART_AREA_W; // an optimization
 final float opt_8dHA_H         = 7.99999f/HEART_AREA_H;
 final float HEART_HEAP_CENTERX = HEART_WALL_L + HEART_AREA_W/4.0f;
 final float HEART_HEAP_CENTERY = HEART_WALL_B;

//-------------------------------------------------------------
 final float BALLOON_START_Y    =  7;
 final float BALLOON_APPMARGIN_R = 7;
 final float BALLOON_SPACING_Y  = 6;
 final float BALLOON_W        = min(90*4, ((int)(HEART_AREA_W / 2.0f)) - BALLOON_APPMARGIN_R);
 final float BALLOON_X        = DUMPSTER_APP_W - BALLOON_W - BALLOON_APPMARGIN_R;
 final float CONNECTOR_BEZ_DIF  = HEART_AREA_W/5.0f;

 final int   BALLOON_BODY_R    = 255;
 final int   BALLOON_BODY_G    = 200;
 final int   BALLOON_BODY_B    = 200;

 final int   BALLOON_BODY_R2    = 255;
 final int   BALLOON_BODY_G2    = 210;
 final int   BALLOON_BODY_B2    = 210;
 final int   BALLOON_OVER_ALPDELTA = 28;
 final float BALLOON_ALP_BLURA  = 0.85f;
 final float BALLOON_ALP_BLURB  = (1.0f - BALLOON_ALP_BLURA);
 final boolean BALLOON_FADE_QUADS = false;
 String BALLOON_LOADING_STRING =  "Connecting ...";

//-------------------------------------------------------------
 final int   N_BREAKUP_DATABASE_RECORDS = 20038;
 final int   N_BREAKUP_DATABASE_RECORDS_20K = (222*90); //19980 20000;
 final int   MAX_N_HEARTS       = 720;
 final float HM_SHUFFLE_SLOP    = 0.135f;

 final float HEART_MIN_RAD      = 4.5f;
 final float HEART_MIN_RADp1    = HEART_MIN_RAD + 1;
 final float HEART_MAX_RAD      = 14;
 final float HEART_AVG_RAD      = (HEART_MIN_RAD + HEART_MAX_RAD)/2.0f;
 final float HEART_OVER_RADIUS   = 20;
 final float HEART_SELECT_RADIUS = 28;
 final float HEART_DRAG_RADIUS   = 36;
 final float HEART_MIN_OVERLAP_DIST = 0.0f;
 final float HEART_NEIGHBORHOOD = (HEART_MAX_RAD * 4);
 final float HEART_NEIGHBORHOOD_SQ = (HEART_NEIGHBORHOOD*HEART_NEIGHBORHOOD);

 final float HEART_MASS_CONSTANT = 1.0f/(HEART_AVG_RAD*HEART_AVG_RAD);
 final float HEART_GRAVITY      = 0.030f;
 final float HEART_DAMPING      = 0.99f;
 final float HEART_COLLISION_DAMPING = 0.925f;
 final float HEART_HEAPING_K    = 0.03f;
 final float HEART_COLLISION_K  = -0.04f;
 final float HEART_MOUSE_K      = -0.35f;

 final float HEART_MAX_VEL      = 6.0f;
 final float HEART_MAX_VELd2    = HEART_MAX_VEL /2.0f;
 final float HEART_DIAM_SHAVE   = 1.49f;

 final float HEART_BLUR_CA      = 0.885f;
 final float HEART_BLUR_CB      = (1.00f-HEART_BLUR_CA);
 final float HEART_BLUR_RA      = 0.90f;
 final float HEART_BLUR_RB      = (1.00f-HEART_BLUR_RA);

 final int STATE_MOUSE_IGNORE   = 0; // i'm ignoring it.
 final int STATE_MOUSE_OVER     = 1; // i'm hovering over it
 final int STATE_MOUSE_SELECT   = 2; // it's just selected, but i'm not over it
 final int STATE_MOUSE_DRAG     = 3; // im dragging it around, and it's selected

 final int STATE_HEART_GONE     = -1;
 final int STATE_HEART_FADING   = 0;
 final int STATE_HEART_EXISTS   = 1;


// see http://www.opengl.org/resources/tutorials/advanced/advanced98/notes/node185.html
// http://www.sgi.com/misc/grafica/interp/
 final float LUMINANCES[] = {
  0.3086f, 0.6094f, 0.0820f
};
 final float LUMINANCES_R = LUMINANCES[0];
 final float LUMINANCES_G = LUMINANCES[1];
 final float LUMINANCES_B = LUMINANCES[2];
 final float HEART_SATURATE_A = 1.5f;
 final float HEART_SATURATE_B = 1.0f - HEART_SATURATE_A;

 final short bindices[] = {
  3, 7, 14, 28, 56, 112, 224, 192
};


 final int   BUP_COMPARE_AGE    = 0;
 final int   BUP_COMPARE_SEX    = 1;
 final int   BUP_COMPARE_INSTIG  = 2;
 final int   BUP_COMPARE_LANG     = 3;

//-------------------------------------------------------------
 final float mean_egon = 0.204022240f;
 final float stdv_egon = 0.097832600f;

 final float mean_exon = 0.060806002f; 
 final float stdv_exon = 0.090450930f;

 final float mean_fukn = 0.013498707f; 
 final float stdv_fukn = 0.056290355f;

 final float mean_capn = 0.044475384f; 
 final float stdv_capn = 0.109096274f;

 final float mean_excn = 0.030499335f; 
 final float stdv_excn = 0.068099186f;

 final float mean_quen = 0.003471169f;
 final float stdv_quen = 0.018286707f;

 final float mean_pern = 0.093191720f; 
 final float stdv_pern = 0.083592765f;

 final float mean_age  = 16.62996500f; 
 final float stdv_age  = 3.329887200f;

 final float LANG_MEANS[] = {
  mean_egon, 
  mean_exon, 
  mean_fukn, 
  mean_capn, 
  mean_excn, 
  mean_quen, 
  mean_pern
};

 final float LANG_STDVS[] = {
  stdv_egon, 
  stdv_exon, 
  stdv_fukn, 
  stdv_capn, 
  stdv_excn, 
  stdv_quen, 
  stdv_pern
};



/*
 final boolean KIOSK_MODE = true;

 final int   DUMPSTER_INVALID	= -1;
 final float DUMPSTER_APP_W		= 1024;
 final float DUMPSTER_APP_H		= 768;
 final float HISTOGRAM_H 			= 79;

 final int   MAX_N_BALLOONS  	= 8;
 final float HISTOGRAM_SPACE_OCCUPANCY = 0.85f;
 final int   DUMPSTER_LONELY_TIME = 5000;

 final float HM_SHUFFLE_PROBABILITY 	= 0.0925f;

 final float HD_TEXT_BLURA				= 0.5f;
 final float HD_TEXT_BLURB				= (1.0f- HD_TEXT_BLURA);
 final float DH_BLURA						= 0.7f;
 final float DH_BLURB						= (1.0f- DH_BLURA);

//-------------------------------------------------------------
 final int   N_BREAKUP_LANGUAGE_DESCRIPTORS = 7;
 final int   N_BREAKUP_LANGUAGE_BITFLAGS = 4;
 final int   PIXELVIEW_H			= 400; // DUMPSTER_APP_H - HISTOGRAM_H;
 final int	  PIXELVIEW_W			= 50;  // HEART_WALL_L
 final int   PIXELVIEW_L			= 1;
 final int   PIXELVIEW_T			= 1;
 final int   MALE_BLUE_AMOUNT	= 45;

//-------------------------------------------------------------
 final float HEART_WALL_L       = PIXELVIEW_W+2;
 final float HEART_WALL_R       = DUMPSTER_APP_W-2;
 final float HEART_WALL_T       = 1;
 final float HEART_WALL_B       = DUMPSTER_APP_H - HISTOGRAM_H;
 final float HEART_AREA_W       = HEART_WALL_R - HEART_WALL_L;
 final float HEART_AREA_H       = HEART_WALL_B - HEART_WALL_T;
 final float opt_8dHA_W         = 7.99999f/HEART_AREA_W; // an optimization
 final float opt_8dHA_H         = 7.99999f/HEART_AREA_H;
 final float HEART_HEAP_CENTERX = HEART_WALL_L + HEART_AREA_W/4.0f;
 final float HEART_HEAP_CENTERY = HEART_WALL_B;

//-------------------------------------------------------------
 final float BALLOON_START_Y		=  7;
 final float BALLOON_APPMARGIN_R = 7;
 final float BALLOON_SPACING_Y  = 6;
 final float BALLOON_W 			= ((int)(HEART_AREA_W / 2.0f)) - BALLOON_APPMARGIN_R;
 final float BALLOON_X				= DUMPSTER_APP_W - BALLOON_W - BALLOON_APPMARGIN_R;
 final float CONNECTOR_BEZ_DIF	= HEART_AREA_W/5.0f;

 final int   BALLOON_BODY_R		= 255;
 final int   BALLOON_BODY_G		= 200;
 final int   BALLOON_BODY_B		= 200;

 final int   BALLOON_BODY_R2		= 255;
 final int   BALLOON_BODY_G2		= 210;
 final int   BALLOON_BODY_B2		= 210;
 final int   BALLOON_OVER_ALPDELTA = 28;
 final float BALLOON_ALP_BLURA	= 0.85f;
 final float BALLOON_ALP_BLURB	= (1.0f - BALLOON_ALP_BLURA);
 final boolean BALLOON_FADE_QUADS = false;
 String BALLOON_LOADING_STRING =  "Connecting ...";

//-------------------------------------------------------------
 final int   N_BREAKUP_DATABASE_RECORDS = 20038;
 final int   N_BREAKUP_DATABASE_RECORDS_20K = 20000;
 final int   MAX_N_HEARTS       = 220;
 final float HM_SHUFFLE_SLOP		= 0.135f;

 final float HEART_MIN_RAD      = 4.5f;
 final float HEART_MIN_RADp1    = HEART_MIN_RAD + 1;
 final float HEART_MAX_RAD      = 14;
 final float HEART_AVG_RAD      = (HEART_MIN_RAD + HEART_MAX_RAD)/2.0f;
 final float HEART_OVER_RADIUS   = 20;
 final float HEART_SELECT_RADIUS = 28;
 final float HEART_DRAG_RADIUS   = 36;
 final float HEART_MIN_OVERLAP_DIST = 0.0f;
 final float HEART_NEIGHBORHOOD = (HEART_MAX_RAD * 4);
 final float HEART_NEIGHBORHOOD_SQ = (HEART_NEIGHBORHOOD*HEART_NEIGHBORHOOD);

 final float HEART_MASS_CONSTANT = 1.0f/(HEART_AVG_RAD*HEART_AVG_RAD);
 final float HEART_GRAVITY      = 0.030f;
 final float HEART_DAMPING      = 0.99f;
 final float HEART_COLLISION_DAMPING = 0.925f;
 final float HEART_HEAPING_K    = 0.03f;
 final float HEART_COLLISION_K  = -0.04f;
 final float HEART_MOUSE_K      = -0.35f;

 final float HEART_MAX_VEL      = 6.0f;
 final float HEART_MAX_VELd2    = HEART_MAX_VEL /2.0f;
 final float HEART_DIAM_SHAVE   = 1.49f;

 final float HEART_BLUR_CA      = 0.885f;
 final float HEART_BLUR_CB      = (1.00f-HEART_BLUR_CA);
 final float HEART_BLUR_RA      = 0.90f;
 final float HEART_BLUR_RB      = (1.00f-HEART_BLUR_RA);

 final int STATE_MOUSE_IGNORE   = 0; // i'm ignoring it.
 final int STATE_MOUSE_OVER     = 1; // i'm hovering over it
 final int STATE_MOUSE_SELECT   = 2; // it's just selected, but i'm not over it
 final int STATE_MOUSE_DRAG     = 3; // im dragging it around, and it's selected

 final int STATE_HEART_GONE     = -1;
 final int STATE_HEART_FADING   = 0;
 final int STATE_HEART_EXISTS   = 1;


// see http://www.opengl.org/resources/tutorials/advanced/advanced98/notes/node185.html
// http://www.sgi.com/misc/grafica/interp/
 final float LUMINANCES[] = {
  0.3086f, 0.6094f, 0.0820f
};
 final float LUMINANCES_R = LUMINANCES[0];
 final float LUMINANCES_G = LUMINANCES[1];
 final float LUMINANCES_B = LUMINANCES[2];
 final float HEART_SATURATE_A = 1.5f;
 final float HEART_SATURATE_B = 1.0f - HEART_SATURATE_A;

 final short bindices[] = {
  3, 7, 14, 28, 56, 112, 224, 192
};


 final int 	BUP_COMPARE_AGE		= 0;
 final int 	BUP_COMPARE_SEX		= 1;
 final int 	BUP_COMPARE_INSTIG	= 2;
 final int 	BUP_COMPARE_LANG 		= 3;

//-------------------------------------------------------------
 final float mean_egon = 0.204022240f;
 final float stdv_egon = 0.097832600f;

 final float mean_exon = 0.060806002f; 
 final float stdv_exon = 0.090450930f;

 final float mean_fukn = 0.013498707f; 
 final float stdv_fukn = 0.056290355f;

 final float mean_capn = 0.044475384f; 
 final float stdv_capn = 0.109096274f;

 final float mean_excn = 0.030499335f; 
 final float stdv_excn = 0.068099186f;

 final float mean_quen = 0.003471169f;
 final float stdv_quen = 0.018286707f;

 final float mean_pern = 0.093191720f; 
 final float stdv_pern = 0.083592765f;

 final float mean_age  = 16.62996500f; 
 final float stdv_age  = 3.329887200f;

 final float LANG_MEANS[] = {
  mean_egon, 
  mean_exon, 
  mean_fukn, 
  mean_capn, 
  mean_excn, 
  mean_quen, 
  mean_pern
};

 final float LANG_STDVS[] = {
  stdv_egon, 
  stdv_exon, 
  stdv_fukn, 
  stdv_capn, 
  stdv_excn, 
  stdv_quen, 
  stdv_pern
};

*/
