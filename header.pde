import java.util.*;
final static int NODESIZE = 5;
final static float SPRING = 0;
final static float REPULSE = -10000;
final static float TIMESCALE = 0.01;
final static float TRESHOLD = 100;
boolean updating = true;
abstract class Distribution{
  float eval(PVector position){}
  
  void display(){
    fill(0, 0, 0);
    noStroke();
    PVector position = new PVector(0,0);
    float f;
    int resolution = 5;
    for(int i = 0; i < width; i+=resolution){
      for(int j = 0; j < height; j+=resolution){
        position.x = i;
        position.y = j;
        f = eval(position);
        if(f > 0)
          fill(255 * f / 100);
        else
          fill(0, 0, 255 * -f);
        
        ellipse(i, j, resolution, resolution);
      }
    }
  }
}

class Border extends Distribution{
  int xsize;
  int ysize;
  float margin;
  Border(float margin){
    xsize = width;
    ysize = height;
    this.margin = margin;
  }
  float eval(PVector position){
    if((width - position.x) < margin){
      return -1000 / (width - position.x);
    }
    if((height - position.y) < margin){
      return -1000 / (height - position.y);
    }
    if(position.x < margin){
      return -1000 / (position.x);
    }
    if(position.y < margin){
      return -1000 / (position.y);
    }
    else{
      return 0;
    }
  }
}

class DisplayField extends Distribution{
  float coeff1;
  float coeff2;
  PVector center;
  DisplayField(PVector center, float coeff1, float coeff2){
    this.center = center;
    this.coeff1 = coeff1;
    this.coeff2 = coeff2;
  }
  float eval(PVector position){
    if(position.equals(center)){
      return -10;
    }
    else{
      return coeff1 * position.dist(center) * (log(position.dist(center)) - 1) + coeff2 / position.dist(center);
    }
  }
}

class Gaussian extends Distribution{
  PVector center;
  float std_dev;
  float dbl_std_dev_sq;
  float amplitude;
  float threshold;
  float argThreshold;
  
  Gaussian(PVector gauss_center, float gauss_dev, float gauss_amplitude, float argThresh){
    center = gauss_center;
    std_dev = gauss_dev;
    dbl_std_dev_sq = std_dev * std_dev * 2;
    amplitude = gauss_amplitude;
    argThreshold = argThresh;
    threshold = argThreshold * dbl_std_dev_sq;
  }
  
  float eval(PVector position){
    float dist_sq = PVector.sub(position, center).magSq();
    return amplitude * exp(-dist_sq/dbl_std_dev_sq);
  }
  
  void setAmplitude(float amp){
    amplitude = amp;
  }
  
  void setStdDev(float dev){
    std_dev = dev;
    dbl_std_dev_sq = 2 * dev * dev;
    threshold = argThreshold * dbl_std_dev_sq;
  }
  
  void setPosition(PVector position){
    this.center = position;
  }
}



class Field extends Distribution{
  ArrayList<Distribution> dists;
  Field(){
    dists = new ArrayList<Distribution>();
  }
  
  void add(Distribution dist){
    dists.add(dist);
  }  
  
  float eval(PVector position){
    float value = 0;

    for(Iterator<Distribution> i = dists.iterator(); i.hasNext();){
      value += i.next().eval(position, this, i);
    }
    return value;
  }
  
  
  void remove(Distribution g){
    dists.remove(g);
  }
}
float directionalDerivative(Distribution d, PVector position, PVector dx){
    float x = (d.eval(PVector.add(position, dx)) - d.eval(PVector.sub(position, dx)))/dx.mag();
	return x;
}


// void removeValue(IntList list, int value){
//   int size = list.size();
//   for(int i = 0; i < size; i++){
//     if(list.get(i) == value){
//       list.remove(i);
//     }
//   }
// }

/*****************************
******PERMUTATION CLASS*******
*****************************/

class Permutation{
   private ArrayList<Integer> permutation;
   private int size;

  // Permutation(int... elements){
  //   permutation = new ArrayList<Integer>();
  //   for(int i: elements){
  //    permutation.add(i);
  //   }
  //   size = permutation.size();
  // }
  
  Permutation(ArrayList<Integer> tempPermutation){
    permutation = new ArrayList<Integer>();
    for(int i = 0; i < tempPermutation.size(); i++){
     permutation.add(tempPermutation.get(i));
    }
    //permutation = tempPermutation;
    size = tempPermutation.size();
  }
  

  /**
    Returns the number of elements permuted
   **/
  int order(){
    return size;
  }
  /**
    Returns the image of i under the permutation
   **/
  int operate(int i){
    if( i > size){
      return i;
    }
    return permutation.get(i - 1);
  }
  
  /**
    Returns ba, where a is this permutatation 
   **/
  Permutation compose(Permutation b){
    int productOrder = order() > b.order() ? order() : b.order();

    ArrayList<Integer> product =  new ArrayList<Integer>();
    
     for(int i = 1; i <= productOrder; i++){
        product.add(b.operate(operate(i)));
     }
    Permutation otherProduct = new Permutation(product);
     return otherProduct;
  }
  
  Permutation invert(){
    ArrayList<Integer> inverse = new ArrayList<Integer>(size);
    for(int i = 1; i <= size; i++){
      inverse.set(operate(i) - 1, i); 
    }
    return new Permutation(inverse);
  }
  
  boolean equals(Permutation perm){
    int larger = perm.order() > size ? perm.order() : size;
     for(int i = 1; i <= larger; i++){
       if(perm.operate(i) != operate(i)){
         return false;
       } 
     }
     return true;
  }
  
  String toString(){
  	print("size: ");
  	println(size);
     for(int i = 1; i <= size; i++){
     	print(operate(i));
     }
    return "new Permutation";
  }
}


/*****************************
******Permutation Node CLASS*******
*****************************/
class PermutationNode{
  Permutation permutation;
  ArrayList<PermutationNode> neighbors;
  
  DisplayField displayField;
  Field visionField;
  
  PVector position;
  PVector velocity;
  PVector acceleration;
  
   PermutationNode(Permutation perm, CayleyGraph graph){
    permutation = perm;
    neighbors = new ArrayList();
    
    graph.add(this);
    
    PermutationNode neighbor;
    Permutation composition;
   
    position = new PVector(random(XMARGIN, XSIZE + XMARGIN), random(YMARGIN, YSIZE + YMARGIN));
    
    visionField = new Field();
    displayField = new DisplayField(position, 0.001, 20);
    visionField.add(graph.center);
    
      for(Permutation i: graph.generators){
     	composition = perm.compose(i);
       if(graph.findIn(composition)){
         neighbor = graph.getNeighbor(composition);
         neighbors.add(neighbor);
         neighbor.add(this);
         visionField.add(neighbor.displayField);
       }
      else{
        neighbor = new PermutationNode(composition, graph);
        neighbors.add(neighbor);
        neighbor.add(this);
        visionField.add(neighbor.displayField);
      }
      }
    
    velocity = new PVector(0,0);
    acceleration = new PVector(0,0);
    }
  
  void add(PermutationNode neighbor){
    neighbors.add(neighbor);
  }
  
  String toString(){
    return permutation.toString();
  }
  void updatePosition(CayleyGraph graph){

      PVector dx = new PVector(1, 0);
      PVector dy = new PVector(0, 1);
      acceleration.x = -directionalDerivative(visionField, position, dx);
      acceleration.y = -directionalDerivative(visionField, position, dy);

     velocity.add(acceleration);
     velocity.normalize();
     position.add(PVector.mult(velocity, 1));
    /*Vector dforce;
    for(PermutationNode i: neighbors){
      dforce = position.vectorTo(i.position, SPRING * log(position.distance(i.position)));
      acceleration.vectorAdd(dforce);
    }
    for(PermutationNode i: graph.vertices){
      if(position.distanceSquared(i.position) != 0){
        dforce = position.vectorTo(i.position, REPULSE / position.distance(i.position));
        acceleration.vectorAdd(dforce);
      }
    }
    velocity.vectorAdd(acceleration.scalarMultiply(TIMESCALE));
    position.vectorAdd(velocity.scalarMultiply(TIMESCALE));
    */
  }
  void display(){
    fill(230, 200, 200);
    stroke(230, 200, 200);
    for(PermutationNode i: neighbors){
      line(position.x, position.y, i.position.x, i.position.y);
    }
    ellipse(position.x, position.y, NODESIZE, NODESIZE);
    //visionField.display();
    
    textSize(10);
//    text(permutation.toString(), position.x - NODESIZE, position.y - NODESIZE);
    //strokeWeight(10);
    //println(permutation.toString() + " x: ", acceleration.x, "y:", acceleration.y);
   // line(position.x, position.y, acceleration.x * 1000 + position.x, acceleration.y * 100 + position.y);
  }
}




/*****************************
******Cayley Graph CLASS*******
*****************************/
class CayleyGraph{
  ArrayList<PermutationNode> vertices;
  ArrayList<Permutation> generators;
  Gaussian center;
  
  CayleyGraph(ArrayList<Permutation> tempgenerators){
    generators = tempgenerators;
    vertices = new ArrayList();
    center = new Gaussian(new PVector(XSIZE / 2.0 + XMARGIN, YSIZE / 2.0 + YMARGIN), 5, -1, 0);
    ArrayList<Integer> id = new ArrayList<Integer>();
    id.add(1);
    new PermutationNode(new Permutation(id), this);
  }
  
  boolean findIn(Permutation perm){
    for(PermutationNode i : vertices){
      if(perm.equals(i.permutation)){
        return true;
      }
    }
    return false;
  }
  PVector centerOfMass(){
  	PVector com = new PVector(0, 0);
    for(PermutationNode i :vertices){
      com.add(i.position);
    } 
    return PVector.mult(com, 1.0/vertices.size());
  }
  PermutationNode getNeighbor(Permutation perm){
    for(PermutationNode i : vertices){
      if(perm.equals(i.permutation)){
        return i;
      }
    }
    return null;
  }
  
  void display(){
    fill(0);
    pushMatrix();
    PVector com = this.centerOfMass();
    translate(-com.x + XSIZE / 2.0 + XMARGIN, -com.y + YSIZE / 2.0 + YMARGIN);
    for(PermutationNode i: vertices){
      i.display();
    }
    popMatrix();
  }
  void add(PermutationNode vertex){
    vertices.add(vertex);
  }
  
  void updatePositions(){
    for(PermutationNode i : vertices){
      i.updatePosition(this);
    }
  }
}

 CayleyGraph graph;
void setup(){
//	size(1000, 1000);
    size(XSIZE + 2 * XMARGIN, YSIZE + 2 * YMARGIN);
// // //
ArrayList<Integer> perm = new ArrayList<Integer>();
perm.add(2);
perm.add(3);
perm.add(1);
  Permutation b = new Permutation(perm);
perm = new ArrayList<Integer>();
perm.add(5);
perm.add(1);
perm.add(2);
perm.add(3);
perm.add(4);
   Permutation a = new Permutation(perm);
  
   ArrayList<Permutation> generators = new ArrayList();
   generators.add(b);
   generators.add(a);
//   background(40, 40, 40);
  
   graph = new CayleyGraph(generators);
    graph.display();
    graph.updatePositions();
}
void draw(){
	updating = false;
	background(255);
    graph.updatePositions();
    graph.display();
}