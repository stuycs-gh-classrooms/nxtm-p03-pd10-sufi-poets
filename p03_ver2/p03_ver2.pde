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

  //Part 0: Write makeOrbs below
  makeOrbs(true);
  frictionMode();
  //Part 3: create earth to simulate gravity
  earth = new FixedOrb(width/2, height/2, 50, 1000);
}//setup


void draw()
{
  background(255);
  displayMode();

  //draw the orbs and springs
  if (toggles[FRICTION]) {
    for (int i=0; i < orbfCount; i++) {
      forbs[i].display();
    }
  }
  for (int o=0; o < orbCount; o++) {
    orbs[o].display();

    if (o < orbCount - 1) {
      drawSpring(orbs[o], orbs[o + 1]);
    }
  }//draw orbs & springs

  if (toggles[MOVING]) {
    applySprings();

    //Apply earth based gravity and drag if those
    //options are turned on.
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
    }//gravity, drag
    for (int i=0; i < orbfCount; i++) {
      if (toggles[FRICTION]) {
        //frictionMode();
        forbs[i].display();
        applyFriction();
      }
    }

    for (int o=0; o < orbCount; o++) {
      orbs[o].move(toggles[BOUNCE]);
    }
  }//moving
}//draw


/**
 makeOrbs(boolean ordered)
 
 Set orbCount to NUM_ORBS
 Initialize and create orbCount Orbs in orbs.
 All orbs should have random mass and size.
 The first orb should be a FixedOrb
 If ordered is true:
 The orbs should be spaced SPRING_LENGTH distance
 apart along the middle of the screen.
 If ordered is false:
 The orbs should be positioned radomly.
 
 Each orb will be "connected" to its neighbors in the array.
 */
void makeOrbs(boolean ordered)
{
  orbCount = NUM_ORBS;
  /*if (toggles[FRICTION]) {
   orbCount = 3; //only want 3 orbs for simplicity
   float y = 500;
   orbs[orbCount - 1] = new Orb(width - 100, y, int(random(MIN_SIZE, MAX_SIZE)), int(random(MIN_MASS, MAX_MASS)));
   } else {
   orbCount = NUM_ORBS;
   }
   */

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
  orbfCount = 2;
  forbs = new Orb[orbfCount];
  if (toggles[FRICTION]) {
    for (int num = 0; num < orbfCount; num++) {
      float y = 500;
      forbs[num] = new Orb(width - 100, y, int(random(MIN_SIZE, MAX_SIZE)), int(random(MIN_MASS, MAX_MASS)));
    }
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
 
 FIRST: Fill in getSpring in the Orb class.
 
 THEN:
 Go through the Orbs array and apply the spring
 force correctly for each orb. We will consider every
 orb as being "connected" via a spring to is
 neighboring orbs in the array.
 */
void applySprings()
{
  /** The resulting force should pull the calling object towards
   other if the spring is extended past springLength and should
   push the calling object away from o if the spring is compressed
   to be less than springLength.*/
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
  PVector friction = new PVector(0, 0);
  for (int num = 0; num < orbfCount; num++) { //subtracvted 1 bc of fixed obj
    Orb o0 = forbs[num]; //calling object
    if (o0.center.y >= height - o0.bsize/2 - 1) { //orbs on the ground
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
}

//draw ground using shape done
//spawn in the orbs on the ground (altering the x and y position) done
//apply the force of friction on that orb (do this by a for loop?) done
//use an if statement for when friction and dragforce are applied at the same time
//in which you add the two forces together.
//work on combo force!!!!!!! :) good luck sufia ily <3


/**
 addOrb()
 
 Add an orb to the arry of orbs.
 
 If the array of orbs is full, make a
 new, larger array that contains all
 the current orbs and the new one.
 (check out arrayCopy() to help)
 */
void addOrb()
{
  if (orbCount == orbs.length) {//if array is full
    Orb[] newArr = new Orb[orbCount * 2];
    arrayCopy(orbs, newArr);
    orbs = newArr;
  }
}//addOrb


/**
 keyPressed()
 
 Toggle the various modes on and off
 Use 1 and 2 to setup model.
 Use - and + to add/remove orbs.
 */
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
    frictionMode();
  }
  if (key == 'c') {
    toggles[COMBINATION] = !toggles[COMBINATION];
  }
  if (key == 'r') {
    togglesF[GG] = !togglesF[GG];
    frictionMode();
  }
  if (key == 'w') {
    togglesF[WW] = !togglesF[WW];
    frictionMode();
  }
  if (key == 'i') {
    togglesF[II] = !togglesF[II];
    frictionMode();
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
  if (toggles[FRICTION]) {
    fill(0);
    textSize(15);
    textAlign(RIGHT);
    text("Press 'r', 'w', or 'i' for different types of friction.", 300, 500);
    if (togglesF[GG]) {
      fill(0);
      textAlign(LEFT);
      text("Glass on glass friction", 460, 500);
      fill(190, 196, 198);
      rect(0, height-100, width, 100);
    }
    if (togglesF[WW]) {
      fill(0);
      textAlign(LEFT);
      text("Wood on wood friction", 460, 500);
      fill(144, 129, 115);
      rect(0, height-100, width, 100);
    }
    if (togglesF[II]) {
      fill(0);
      textAlign(LEFT);
      text("Ice on ice friction", 460, 500);
      fill(133, 201, 227);
      rect(0, height-100, width, 100);
    }
  }
}//display
