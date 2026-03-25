int NUM_ORBS = 10;
int MIN_SIZE = 10;
int MAX_SIZE = 60;
float MIN_MASS = 10;
float MAX_MASS = 100;
float G_CONSTANT = 1;
float D_COEF = 0.1;
float F_COEF_GG = 0.4;
float F_COEF_II = 0.03;
float F_COEF_WW = 0.2;

int SPRING_LENGTH = 50;
float  SPRING_K = 0.005;

int MOVING = 0;
int BOUNCE = 1;
int GRAVITY = 2;
int DRAGF = 3;
int FRICTION = 4;
int COMBINATION = 5;
int GG = 0;
int II= 1;
int WW = 2;
boolean[] toggles = new boolean[6];
boolean[] togglesF = new boolean[3];

String[] modes = {"Moving", "Bounce", "Gravity", "Drag", "Friction", "Combination"};

FixedOrb earth;
Orb[] orbs;
Orb[] forbs;
int orbCount;
int orbfCount;

void setup()
{
  size(600, 600);
  makeOrbs(true);
  earth = new FixedOrb(width/2, height/2, 50, 1000);
}//setup


void draw() {
  background(255);
  displayMode();

  if (toggles[COMBINATION]) {
    for (int o = 0; o < orbCount; o++) {
      orbs[o].display();
      if (o < orbCount - 1) {
        drawSpring(orbs[o], orbs[o + 1]);
      }
    }
  }//if combination is toggled true, then display orbs w/ strings

  //draw the orbs and springs
  if (!toggles[FRICTION]) {
    for (int o=0; o < orbCount; o++) {
      orbs[o].display();
      if (o < orbCount - 1) {
        drawSpring(orbs[o], orbs[o + 1]);
      }
    }
  }//if friction is NOT TOGGLED, display everything

  if (toggles[FRICTION]) {
    for (int i=0; i < orbfCount; i++) {
      forbs[i].display();
    }
  }//if friction is toggled true, display our orbs

  if (toggles[MOVING]) {
    applySprings();

    for (int i=0; i < orbCount; i++) {
      Orb o = orbs[i];
      if (toggles[GRAVITY]) {
        PVector gravity = o.getGravity(earth, G_CONSTANT);
        o.applyForce(gravity);
      }
      if (toggles[DRAGF]) {
        PVector dragf = o.getDragForce(D_COEF);
        o.applyForce(dragf);
      }
    }

    for (int num=0; num < orbfCount; num++) {
      Orb f = forbs[num];
      if (toggles[DRAGF]) {
        PVector dragf = f.getDragForce(D_COEF);
        f.applyForce(dragf);
      }
    }

    if (toggles[COMBINATION]) {
      applySprings(); //spring force
      for (int i = 0; i < orbCount; i++) {
        Orb o = orbs[i];

        if (o.center.y >= height - 100) {
          PVector friction = new PVector(0, 0);
          if (togglesF[GG]) {
            friction = o.getFriction(F_COEF_GG);
          }
          if (togglesF[II]) {
            friction = o.getFriction(F_COEF_II);
          }
          if (togglesF[WW]) {
            friction = o.getFriction(F_COEF_WW);
          }
          o.applyForce(friction);
        }
      }
    } else if (toggles[FRICTION]) {
      applyFriction();
    }//if friction is true, apply friction

    if (!toggles[FRICTION]) {
      for (int o=0; o < orbCount; o++) {
        orbs[o].move(toggles[BOUNCE]);
      }
    }//apply bounce on each orb if no friction

    for (int num = 0; num < orbfCount; num++) {
      forbs[num].move(toggles[BOUNCE]);
    }//apply bounce on the friction orbs
  }//moving
}//draw


/**
 makeOrbs(boolean ordered)
 creates orbs connected with springs!
 */
void makeOrbs(boolean ordered)
{
  orbCount = NUM_ORBS;

  orbs = new Orb[orbCount];
  orbs[0] = new FixedOrb(); //first orb = FixedOrb


  float x = 0;
  float y = 0;
  if (ordered == true) {
    for (int i = 1; i < orbCount; i++) {
      orbs[i] = new Orb(x + SPRING_LENGTH, y + SPRING_LENGTH, int(random(MIN_SIZE, MAX_SIZE)), int(random(MIN_MASS, MAX_MASS)) );
      x += SPRING_LENGTH;
      y += SPRING_LENGTH;
    }
  }
  if (ordered == false) {
    for (int i = 1; i < orbCount; i++) {
      orbs[i] = new Orb(int(random(width)), int(random(height)), int(random(MIN_SIZE, MAX_SIZE)), int(random(MIN_MASS, MAX_MASS)) );
    }
  }
}//makeOrbs

void frictionMode() {
  orbfCount = 6;
  forbs = new Orb[orbfCount];
  float y = height - 100;
  float x = width - 500;
  for (int num = 0; num < orbfCount; num++) {
    forbs[num] = new Orb(x, y, int(random(MIN_SIZE, MAX_SIZE)), int(random(MIN_MASS, MAX_MASS)));
    forbs[num].velocity = new PVector(random(-3, 3), 0); //velocity in the x axis!!!
    x += 70;
  }
}

void combinationForce() {
  orbCount = 6;
  orbs = new Orb[orbCount];
  float y = height - 100;
  float x = 100;
  for (int i = 0; i < orbCount; i++) {
    orbs[i] = new Orb(x, y, int(random(MIN_SIZE, MAX_SIZE)), int(random(MIN_MASS, MAX_MASS)));
    orbs[i].velocity = new PVector(random(-3, 3), 0);
    x += SPRING_LENGTH;
  }
}

/**
 drawSpring(Orb o0, Orb o1)
 
 Draw a line between the two Orbs.
 Line color should change as follows:
 red: The spring is stretched.
 green: The spring is compressed.
 black: The spring is at its normal length
 */
void drawSpring(Orb o0, Orb o1)
{
  float distance = o0.center.dist(o1.center);
  if (distance > SPRING_LENGTH) {
    stroke(255, 0, 0); //red if stretched
  } else if (distance < SPRING_LENGTH) {
    stroke(0, 255, 0); //green if compressed
  } else {
    stroke(0); //black if normal length
  }
  line(o0.center.x, o0.center.y, o1.center.x, o1.center.y);
}//drawSpring


/**
 applySprings()
 
 The resulting force should pull the calling object towards
 other if the spring is extended past springLength and should
 push the calling object away from o if the spring is compressed
 to be less than springLength.
 */
void applySprings()
{
  for (int i = 1; i < orbCount - 1; i++) {
    Orb o0 = orbs[i]; //calling object
    Orb o1 = orbs[i + 1]; //other object

    PVector force1 = o0.getSpring(o1, SPRING_LENGTH, SPRING_K);
    o0.applyForce(force1); //apply force on calling object

    PVector force2 = force1.copy();
    force2.mult(-1); //opposite, change dxn if necessary
    o1.applyForce(force2);
  }
}//applySprings

void applyFriction() {
  for (int num = 0; num < orbfCount; num++) {
    Orb o0 = forbs[num]; //calling object
    PVector friction = new PVector(0, 0);

    if (o0.center.y >= height - 100 /* - o0.bsize/2 - 1*/) { //orbs on the ground
      if (togglesF[GG]) {
        friction = o0.getFriction(F_COEF_GG).add(o0.getDragForce(D_COEF));
      }
      if (togglesF[II]) {
        friction = o0.getFriction(F_COEF_II).add(o0.getDragForce(D_COEF));
      }
      if (togglesF[WW]) {
        friction = o0.getFriction(F_COEF_WW).add(o0.getDragForce(D_COEF));
      }
    }
    o0.applyForce(friction);
  }
}//applyFriction --> uses getFriction to calculate fk and applies it onto each orb.


/**
 addOrb()
 Add an orb to the arry of orbs.
 */
void addOrb()
{
  if (orbCount == orbs.length) {//if array is full
    Orb[] newArr = new Orb[orbCount * 2];
    arrayCopy(orbs, newArr);
    orbs = newArr;
  }
}//addOrb


void keyPressed()
{
  if (key == ' ') {
    toggles[MOVING]  = !toggles[MOVING];
  }
  if (key == 'g') {
    toggles[GRAVITY] = !toggles[GRAVITY];
  }
  if (key == 'b') {
    toggles[BOUNCE]  = !toggles[BOUNCE];
  }
  if (key == 'd') {
    toggles[DRAGF]   = !toggles[DRAGF];
  }
  if (key == 'f') {
    toggles[FRICTION] = !toggles[FRICTION];
    if (toggles[FRICTION]) {
      frictionMode();
    } else {
      makeOrbs(true); //goes back to original setup
    }
  }
  if (key == 'c') {
    toggles[COMBINATION] = !toggles[COMBINATION];
    if (toggles[COMBINATION]) {
      combinationForce();
    } else {
      makeOrbs(true); //goes back to original setup
    }
  }
  if (key == 'r') {
    togglesF[GG] = !togglesF[GG];
    //frictionMode();
  }
  if (key == 'w') {
    togglesF[WW] = !togglesF[WW];
    //frictionMode();
  }
  if (key == 'i') {
    togglesF[II] = !togglesF[II];
    //frictionMode();
  }
  if (key == '1') {
    makeOrbs(true);
  }
  if (key == '2') {
    makeOrbs(false);
  }

  if (key == '-') {
    //Part 4: Write code to remove an orb from the array
    if (orbCount > 1) { //doesnt remove earth
      orbCount--;
      Orb[] newArr = new Orb[orbCount];
      //arrayCopy(src, srcPosition, dst, dstPosition, length)
      arrayCopy(orbs, 0, newArr, 0, orbCount);
      orbs = newArr; //update value
    }
  }//removal
  if (key == '=' || key == '+') {
    //Part 4: Write addOrb() below
    addOrb();
  }//addition
}//keyPressed



void displayMode()
{
  textAlign(LEFT, TOP);
  textSize(20);
  noStroke();
  int spacing = 85;
  int x = 0;

  for (int m=0; m<toggles.length; m++) {
    //set box color
    if (toggles[m]) {
      fill(0, 255, 0);
    } else {
      fill(255, 0, 0);
    }

    float w = textWidth(modes[m]);
    rect(x, 0, w+5, 20);
    fill(0);
    text(modes[m], x+2, 2);
    x+= w+5;
  }
  if (toggles[FRICTION] || toggles[COMBINATION]) {
    textSize(15);
    if (togglesF[GG]) {
      fill(190, 196, 198);
      rect(0, height-100, width, 100);

      fill(0);
      textAlign(LEFT);
      text("Glass on glass friction", 460, 590);
    } else if (togglesF[WW]) {
      fill(144, 129, 115);
      rect(0, height-100, width, 100);

      fill(0);
      textAlign(LEFT);
      text("Wood on wood friction", 460, 590);
    } else if (togglesF[II]) {
      fill(133, 201, 227);
      rect(0, height-100, width, 100);

      fill(0);
      textAlign(LEFT);
      text("Ice on ice friction", 460, 590);
    }
    fill(0);
    textSize(15);
    textAlign(RIGHT);
    text("Press 'r', 'w', or 'i' for different types of friction.", 300, 590);
  }
}//display
