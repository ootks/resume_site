import java.util.ArrayList;
int X_WIDTH;
int Y_WIDTH;
boolean display;
static final float TOOCLOSE = 0.0001;
static final int nFunctions = 2;
static String[] currentTransforms = new String[nFunctions];
abstract class Transform{
  abstract PVector transform(PVector p);
  String toString(){
    return "Transformation";
  }
}
class HenionTransform extends Transform{
  float a;
  float b;
  HenionTransform(float x, float y){
    a = x;
    b = y;
  }
  PVector transform(PVector p){
    return new PVector(1 - a * p.x * p.x + p.y, b * p.x);
  }
  String toString(){
    return "Henion " + a + " " + b;
  }
}
class AffineTransform extends Transform{
  Matrix2D matrix;
  PVector translation;
  AffineTransform(float a11, float a12, float a21,  float a22, float b1, float b2){
     matrix = new Matrix2D(a11, a12, a21, a22);
     translation = new PVector(b1, b2);
  }
  AffineTransform(Matrix2D m, PVector t){
    matrix = m;
    translation = t;
  }
  AffineTransform(){
    float a = random(-1, 1);
    float b = random(-1, 1);
    float c = random(-1, 1);
    float d = random(-1, 1);
    float e = random(-1, 1);
    float f = random(-1, 1);
    /*
    float b = random(-1 + a, 1 - a);
    float e = random(-1 + a + b, 1 - a - b);
    float c = random(-1, 1);
    float d = random(-1 + c, 1 - c);
    float f = random(-1 + c + d, 1 - c - d);
    */
    matrix = new Matrix2D(a, b, c, d);
    translation = new PVector(e, f);
  }
  
  //Returns T(p)
  PVector transform(PVector p){
    PVector transformed = matrix.transform(p);
    transformed.add(translation);
    return (transformed);  
  }
  
  String toString(){
    return matrix.toString() + "+" + translation;
  }
}

ArrayList<Transform> generateIFS(int ntransforms){
  ArrayList<Transform> IFS = new ArrayList<Transform>();
  for(int i = 0; i < ntransforms; i++){
     IFS.add(new AffineTransform());
     println(IFS.get(i));
  }
  return IFS;
}

void setup(){
  X_WIDTH = 125;
  Y_WIDTH = 125;
  size(4 * X_WIDTH, 4 * Y_WIDTH);
 /* Matrix2D scale = new Matrix2D(0.5, 0, 0, 0.5);
  PVector pt1 = new PVector(0.5, 1);
  PVector pt2 = new PVector(0, 0);
  PVector pt3 = new PVector(1, 0);
  ArrayList<AffineTransform> IFS;
  ArrayList<Float> probs; 
  IFS = new ArrayList<AffineTransform>();
  IFS.add(new AffineTransform(scale, PVector.add((scale.transform(PVector.mult(pt1, -1))),pt1)));
  IFS.add(new AffineTransform(scale,  PVector.add((scale.transform(PVector.mult(pt2, -1))),pt2)));
  IFS.add(new AffineTransform(scale,  PVector.add((scale.transform(PVector.mult(pt3, -1))),pt3)));
  probs = new ArrayList<Float>();
  probs.add(1.0/3);
  probs.add(2.0/3);
  probs.add(1.0);
  chaosGame(IFS, probs, 20000); */ 
  float x = QUARTER_PI;
  float y = THIRD_PI;
  Matrix2D rotate1 = new Matrix2D(cos(x)/sqrt(2), -sin(x)/sqrt(2), sin(x)/sqrt(2), cos(x)/sqrt(2)); 
  Matrix2D rotate2 = new Matrix2D(cos(y +x)/sqrt(2), -sin(y + x)/sqrt(2), sin(y +x)/sqrt(2),cos(HALF_PI + x)/sqrt(2));
  PVector pt1 = new PVector(1, 0);
  ArrayList<Transform> IFS;
  ArrayList<Float> probs; 
  IFS = new ArrayList<Transform>();
  translate(2 * X_WIDTH, 2 * Y_WIDTH);
  IFS.add(new AffineTransform(rotate1, new PVector(0.0, 0.0)));
  IFS.add(new AffineTransform(rotate2, pt1));
  probs = new ArrayList<Float>();
  probs.add(0.5);
  probs.add(1.0);
//    strokeWeight(0);
  noStroke();
  chaosGame(IFS, probs, 200);
  
  scale(2,2);
}
float x = QUARTER_PI;
float y = THIRD_PI;
ArrayList<Float> probs; 
ArrayList<Transform> IFS;
  float p = 0.5;
PVector pt1 = new PVector(1, 0);
PVector pt2 = new PVector(0, 0);
void draw(){
  //x = mouseX * TWO_PI / width;
  //y = mouseY * TWO_PI / height;
  
  
  x+= 0.01;
  y += 0.02;
  p = 0.5;
  probs = new ArrayList<Float>();
  probs.add(p);
  probs.add(1.0);
  translate(2 * X_WIDTH, 2 * Y_WIDTH);
  background(0,0,0);
  Matrix2D rotate1 = new Matrix2D(cos(x)/sqrt(3), -sin(x)/sqrt(2), sin(x)/sqrt(2), cos(x)/sqrt(2)); 
  Matrix2D rotate2 = new Matrix2D(cos(y +x)/sqrt(2), -sin(y + x)/sqrt(2), sin(y +x)/sqrt(2),cos(HALF_PI + x)/sqrt(2));

  IFS = new ArrayList<Transform>();
  IFS.add(new AffineTransform(rotate1, pt2));
  IFS.add(new AffineTransform(rotate2, pt1));
  chaosGame(IFS, probs, 2000);
}
void mouseClicked(){
  if(mouseX * mouseX + mouseY * mouseY < 100000){
    String name = Integer.toString((int)random(0,150000));
    save(name + ".tif");
    saveStrings(name + ".txt", currentTransforms);
    println("Saved");
  }
  else{
//    background(0,0,0);
    background(75,  100, 10);
    translate(2 * X_WIDTH, 2 * Y_WIDTH);
    chaosGame(generateIFS(nFunctions), generateProbs(nFunctions), 20000);  
  }
}
class Matrix2D{
  float a11;
  float a12;
  float a21;
  float a22;
  Matrix2D(float a11, float a12, float a21,  float a22){
     this.a11 = a11; 
     this.a12 = a12; 
     this.a21 = a21; 
     this.a22 = a22; 
  }
  Matrix2D(){
     this.a11 = random(0,1); 
     this.a12 = random(0,1); 
     this.a21 = random(0,1); 
     this.a22 = random(0,1); 
  }
  //Returns (this matrix).m
  Matrix2D matrix_multiply(Matrix2D m){
    return new Matrix2D(a11 * m.a11 + a12 * m.a21, 
             a11 * m.a12 + a12 * m.a22,
             a21 * m.a11 + a22 * m.a21,
             a21 * m.a12 + a22 * m.a22);
  }
  //Returns (this matrix).p
  PVector transform(PVector p){
    return new PVector(a11 * p.x + a12 * p.y,
           a21 * p.x + a22 * p.y);  
  }
  
  String toString(){
    return "[|" + a11 + " " + a12 + "|\n|" + a21 + " " + a22 + "|]";
  }
}
ArrayList<Float> generateProbs(int nprobs){
  ArrayList<Float> cumProbs = new ArrayList<Float>();
  float cumulative_prob = 0;
  for(int i = 0; i < nprobs - 1; i++){
    cumulative_prob += random(0, 1 - cumulative_prob);
    cumProbs.add(cumulative_prob);
  }
  cumProbs.add(1.0);
  println("CumProbs:", cumProbs);
  
  return cumProbs;
}

void chaosGame(ArrayList<Transform> IFS, ArrayList<Float> probs, int niterations){
  fill(244,244,244);
   for(int i = 0; i < IFS.size(); i++){
     currentTransforms[i] = (IFS.get(i)).toString();
   }
  PVector p = new PVector(1, 1);
  PVector transformed;
  boolean allchosen = false;
  color[] randomColors = new color[probs.size()];
   for(int i = 0; i < randomColors.length; i++){
     randomColors[i] = color(255, 255, 255);
   }

//  randomColors[0] =  color(50, 50, 0);
//  randomColors[1]  = color(100, 200, 100);
  

  for(int i = 0; i < niterations; i++){
    float choice = random(0,1);
    for(int j = 0; j < probs.size(); j++){
      if(choice < probs.get(j)){
        transformed = (IFS.get(j)).transform(p);
        p = transformed;
        //fill(get((int)( p.x * X_WIDTH / 1.5),(int) (p.y * Y_WIDTH / 1.5)) + randomColors[j] % 256);
        fill(randomColors[j]);
        break;
      }
    }
    ellipse(p.x * X_WIDTH / 1.5, p.y * Y_WIDTH / 1.5, 1, 1);
  }
}
