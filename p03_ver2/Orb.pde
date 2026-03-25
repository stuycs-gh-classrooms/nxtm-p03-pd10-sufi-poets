class Orb
{

  /*
  this class contains the following forces:
   dragForce
   springForce
   Gravity
   Friction
   
   this class contains the following actions:
   applyForce
   collisionCheck
   move
   
   How will we apply friction?
   - when friction is applied, gravity will be automatically applied.
   - when both friction and drag force are applied, they combine to create
   a greater opposing motion (Fnet).
   - will apply using the Formmula Fk = uk * Fn
   - how will we find Fn? Since our objects are default on the ground, the only
   Fn that they feel is from the ground, so Fn = Fg.mult(-1)
   - how will we apply Fspring and Fk together? *need to understand what
   Fspring really does.
   - how will we apply uk?
   - coefficients of uk:
   'WOOD ON WOOD' [μk = 0.2], orb = brown
   'GLASS ON GLASS' [0.4], orb will be grey
   'ICE ON ICE' [0.03], orb will be blue
   - in order to differentiate, we will have colors associated with each material.
   - to apply them, we will use boolean values and calculate it in fxn getFrictionForce
   
   */
  //instance variables
  PVector center;
  PVector velocity;
  PVector acceleration;
  float bsize;
  float mass;
  color c;
  float g = 9.8; //gravity for friction

  boolean frictionStatus;
  int GLASS_ON_GLASS = 0;
  int ICE_ON_ICE = 1;
  int WOOD_ON_WOOD = 2;
  boolean[] toggles = new boolean[3];
  Orb[] orbs;
  /**
   Creates an orb with random x and y coordinates and creates new PVectors as the
   velocity and acceleration.
   */
  Orb()
  {
    bsize = random(10, MAX_SIZE);
    float x = random(bsize/2, width-bsize/2);
    float y = random(bsize/2, height-bsize/2);
    center = new PVector(x, y);
    mass = random(10, 100);
    velocity = new PVector();
    acceleration = new PVector();
    setColor();
  }


  /**
   Overloads Orb and resets the center, velocity, and acceleration.
   */
  Orb(float x, float y, float s, float m)
  {
    bsize = s;
    mass = m;
    center = new PVector(x, y);
    velocity = new PVector();
    acceleration = new PVector();
    setColor();
  }


  /**
   If the orbs move and touch the edges of the screen, it will bounce off.
   Then, we add acceleration to velocity to get the speed, add it to the center
   to move it, and reset acceleration.
   */
  void move(boolean bounce)
  {
    if (bounce) {
      xBounce();
      yBounce();
    }

    velocity.add(acceleration);
    center.add(velocity);
    acceleration.mult(0);

      if (center.y >= height - bsize/2) {
        center.y = height - bsize/2; //stay on ground
        velocity.y = 0; //stop vertical movement
      }
  }//move


  /**
   In order to apply the force on the Orb, we divide it by the mass of the Orb
   add it to the acceleration. (F = ma)
   */
  void applyForce(PVector force)
  {
    PVector scaleForce = force.copy();
    scaleForce.div(mass);
    acceleration.add(scaleForce);
  }


  /**
   Calculates drag force using the formula and .mag() and .normalize()
   .mag() gets length of the vector
   .normalize() makes it a unit vector of length 1.
   We get the direction of the velocity, normalize it, and then multiply by the
   drag magnitude to make it the opposite direction of the object.
   */
  PVector getDragForce(float cd)
  {
    float dragMag = velocity.mag();
    dragMag = -0.5 * dragMag * dragMag * cd;
    PVector dragForce = velocity.copy();
    dragForce.normalize();
    dragForce.mult(dragMag);
    return dragForce;
  }

  /**
   Friction force formula: Fk = uk * Fn
   wood on wood uk: 0.2
   glass on glass uk: 0.4
   ice on ice: 0.03
   friction has both direction and speed.
   in order to get direction, we must normalize it
   in order to get speed, we copy velocity
   
   */
  PVector getFriction(float uk) {
    PVector friction = velocity.copy(); //need friction to be opposing motion, only motion that is applied is velocity
    friction.normalize(); //keeps dxn but removes the speed
    friction.mult(-1); //acting against velocity, so (-) of wtvr dxn velocity is

    if (velocity.mag() == 0) {
      return new PVector (0, 0);
      //to prevent moving back and forth at a super fast pace (aka when velocity is super small) 
      //we set it back equal to 0
    }

    float normalForce = mass * g; //Fn = Fg = mg
    float mag = uk * normalForce; //Fk = uk * Fn
    friction.mult(mag);

    return friction;
  }


  /**
   Calculates the total gravity exerted on the orbs by the formula
   Gm1m2/r^2
   */
  PVector getGravity(Orb other, float G)
  {
    float strength = G * mass*other.mass;
    //dont want to divide by 0!
    float r = max(center.dist(other.center), MIN_SIZE);
    strength = strength/ pow(r, 2);
    PVector force = other.center.copy();
    force.sub(center);
    force.mult(strength);
    return force;
  }

  /**
   getSpring()
   
   This should calculate the force felt on the calling object by
   a spring between the calling object and other.
   
   The resulting force should pull the calling object towards
   other if the spring is extended past springLength and should
   push the calling object away from o if the spring is compressed
   to be less than springLength.
   
   F = kx (ABhat)
   k: Spring constant
   x: displacement, the difference of the distance
   between A and B and the length of the spring.
   (ABhat): The normalized vector from A to B
   */
  PVector getSpring(Orb other, int springLength, float springK)
  {
    PVector direction = other.center.copy(); //dxn of other orb -->
    direction.sub(center); //direction from calling obj to other A <---> B

    float distance = direction.mag(); //extract the length from dxn bc dxn = pvector
    direction.normalize(); //abhat

    float displacement = distance - springLength; //x
    float mag = springK * displacement; //F = kx
    direction.mult(mag); //F * ab(hat)

    return direction;
  }//getSpring


  /**
   If the ball goes on the edges of the screen, bounce back. [vertical position]
   */
  boolean yBounce()
  {
    if (center.y > height - bsize/2) {
      velocity.y *= -1;
      center.y = height - bsize/2;

      return true;
    }//bottom bounce
    else if (center.y < bsize/2) {
      velocity.y*= -1;
      center.y = bsize/2;
      return true;
    }
    return false;
  }//yBounce


  /**
   If the ball goes on the edges of the screen, bounce back. [horizantal position]
   */
  boolean xBounce()
  {
    if (center.x > width - bsize/2) {
      center.x = width - bsize/2;
      velocity.x *= -1;
      return true;
    } else if (center.x < bsize/2) {
      center.x = bsize/2;
      velocity.x *= -1;
      return true;
    }
    return false;
  }//xbounce


  /**
   if the Orb touches another Orb, move the other way.
   */
  boolean collisionCheck(Orb other)
  {
    return ( this.center.dist(other.center)
      <= (this.bsize/2 + other.bsize/2) );
  }//collisionCheck


  /**
   Colors an orb black and the other a greenish blue.
   */
  void setColor()
  {
    color c0 = color(0, 255, 255);
    color c1 = color(0);
    /*
    Creates a 'grid' of colors at a specific increment [third argument].
     */
    c = lerpColor(c0, c1, (mass-MIN_SIZE)/(MAX_MASS-MIN_SIZE));

    if (toggles[WOOD_ON_WOOD]) {
      c = color(144, 129, 115);
    }
    if (toggles[ICE_ON_ICE]) {
      c = color(133, 201, 227);
    }
    if (toggles[GLASS_ON_GLASS]) {
      c = color(190, 196, 198);
    }
  }//setColor


  //visual behavior
  void display()
  {
    noStroke();
    fill(c);
    circle(center.x, center.y, bsize);
    fill(0);
    //text(mass, center.x, center.y);
  }//display
}//Ball
