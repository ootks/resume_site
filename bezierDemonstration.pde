//The set of control points
ArrayList<PVector> control;
//The set of points on the curve
ArrayList<PVector> curve;
//Determines whether the 
//program is making the control 
//points or drawing the curve
boolean isSettingUp;
//The time when setup ends
float t0;

/**Initializes things
 */
void setup() {
    strokeJoin(ROUND);
  control = new ArrayList<PVector>();
  curve = new ArrayList<PVector>();
  for(int i = 0; i< 15; i++){
    control.add(new PVector(random(-250, 250) + 250, random(-250, 250) + 250));
  }
  curve.add(control.get(0));
  isSettingUp = false;

  size(500, 500);
  colorMode(HSB, 100);
  fill(0, 0, 0);
  background(0, 0, 250);

  strokeWeight(0);
}

/**Generates new control points
 * if isSettingup
 * or resets everything if is drawing
 */
void mouseClicked() {
  //If we are no longer setting up
  //then the curve is being drawn
  //and a click means that the user
  //wants a fresh canvas
  if (isSettingUp == false) {
    //Reset all of the variables
    control = new ArrayList<PVector>(); 
    curve = new ArrayList<PVector>();  
    t0 = millis();
    isSettingUp = true;
  }

  //Find the point where the 
  //user clicks
  float x = mouseX; 
  float y = mouseY;
  PVector clicked = new PVector(x, y);

  //If the user is clicking
  //in the upper left hand corner,
  //then we start drawing
  if (clicked.dist(new PVector(0, 0)) < 100) {
    isSettingUp = false;
    return;
  }

  //Add the clicked point
  control.add(clicked);

  //Draw the points
  background(0, 0, 250);
  for (PVector v : control) {
    ellipse(v.x, v.y, 3, 3);
  }
  ellipse(0, 0, 10, 10);
}

/**Interpolate between the two
 * vectors at time t, if t >= 1
 * just return the endpoint
 */
PVector interpolate(PVector p1, PVector p2, float t) {
  if (t >= 1) {
    return p2;
  }
  return (new PVector(p1.x + t * (p2.x - p1.x), p1.y + t * (p2.y - p1.y)))
}

/** Find all of the intermediate 
 * interpolation points return the 
 * point found on the curve.
 * curr represents the current color
 * (represented as a interpolation point
 * between red and blue in HSB space).
 * inc is the increment which is added to
 * curr every time the function is called.
 */
PVector intermediatePoints(ArrayList<PVector> points, float t, float inc, float curr) {
  //Return some random point if there aren't points in 
  //points
  if (points.size() < 1) {
    return new PVector(0, 0);
  }
  //If there's only one point in points
  //that is the desired point on the bezier
  //curve
  else if (points.size() == 1) {
    return points.get(0);
  }
  //If there is more than one point,
  //then we should find intermediate
  //interpolation points. 
  else {
    //The next set of interpolation points
    ArrayList<PVector> newPoints = new ArrayList<PVector>(points.size() - 1);
    //Generate the new points by interpolating
    //between the old interpolation points
    for (int i = 1; i < points.size(); i++) {
      PVector p = interpolate(points.get(i-1), points.get(i), t);
      newPoints.add(p);

      //Draw the line between the 
      //previous interpolation point
      //(from the last layer) and the
      //one (from the new layer).
      strokeWeight(1);
      stroke(lerpColor(color(50, 100, 50), color(360, 100, 100), curr));
      line(points.get(i-1).x, points.get(i-1).y, points.get(i).x, points.get(i).y);
      strokeWeight(0);
    }
    //Return the point on the curve
    //desired from the next iteration
    return intermediatePoints(newPoints, t, inc, curr+inc);
  }
}
void draw() {
  //If we are still setting up,
  //don't draw anything and
  //update the starting time
  if (isSettingUp) {
    t0 = millis();
    return;
  }
  //Clear the screen
  background(0, 0, 250);
  fill(30, 50, 10);
  //Draw the control points
  for (PVector v : control) {
    ellipse(v.x, v.y, 5, 5);
  }
  //Draw the curve
    strokeWeight(5);
    stroke(50, 100, 50);
    noFill();
    beginShape();
    for (PVector pt : curve) {
        vertex(pt.x, pt.y);
    }
    endShape();
    strokeWeight(0);
  //If t > 1, just return 
  //and do nothing (saves)
  //on space
  if (millis() - t0 > 15000) {
    return;
  }
  //Get the next point,
  //add it to the curve
  PVector next = intermediatePoints(control,
                                    (millis() - t0)/15000.0,
                                    1.0/(control.size()-2), 0
                                    );
  curve.add(next);
}
