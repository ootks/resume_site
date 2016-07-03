final static int NODESIZE = 5;
final static float SPRING = 0;
final static float REPULSE = -10000;
final static float TIMESCALE = 0.01;
final static float TRESHOLD = 100;
  
  public static final PVector dx = new PVector(1, 0);
  public static final PVector dy = new PVector(0, 1);
  public static final PVector dz = new PVector(0, 0, 1);

void removeValue(IntList list, int value){
  int size = list.size();
  for(int i = 0; i < size; i++){
    if(list.get(i) == value){
      list.remove(i);
    }
  }
}

/*****************************
******PERMUTATION CLASS*******
*****************************/

class Permutation{
  private IntList permutation;
  private int size;
  
  Permutation(IntList perm) throws IllegalArgumentException{
    /* Check that perm is a valid permutation */
    IntList temp = perm.copy();
    temp.sort();
    for(int i = 0; i < perm.size(); i++){
      if(temp.get(i) != i + 1){
        throw new IllegalArgumentException();
      }
    }
    permutation = perm.copy();
    size = perm.size();
  }
  
  Permutation(int... elements){
    permutation = new IntList();
    for(int i: elements){
      permutation.append(i);
    }
    
    /* Check that elements is a valid permutation */
    IntList temp = permutation.copy();
    temp.sort();
    for(int i = 0; i < temp.size(); i++){
      if(temp.get(i) != i + 1){
        permutation = null;
        throw new IllegalArgumentException();
      }
    }
    
    size = permutation.size();
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
    IntList product =  new IntList(productOrder);
    
    for(int i = 1; i <= productOrder; i++){
      product.set(i - 1, b.operate(operate(i)));
    }
    
    return new Permutation(product);
  }
  
  Permutation invert(){
    IntList inverse = new IntList(size);
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
    StringBuilder temp = new StringBuilder("c1");
    IntList toDo = permutation.copy();
    toDo.sort();
    toDo.remove(0);
    int currentIndex = operate(1);
    int cycleStarter = 1;
    toDo.sort();
    while(toDo.size() > 0){
      if(currentIndex == cycleStarter){
        temp.append("cd");
        currentIndex = toDo.get(0);
        cycleStarter = currentIndex;
      }
      temp.append(currentIndex);
      removeValue(toDo, currentIndex);
      currentIndex = operate(currentIndex);
    }while(toDo.size() > 0);
    temp.append("d");
    return temp.toString();
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
   
    position = new PVector(random(-XSIZE / 2.0 - XMARGIN, XSIZE / 2.0 + XMARGIN), 
                      random(-YSIZE / 2.0 - YMARGIN, YSIZE / 2.0 + YMARGIN), 
                      random(-1.0, 1.0) );//new PVector(random(0.0, 1.0), random(0.0, 1.0));//
    
    visionField = new Field();
    displayField = new DisplayField(position, .03125, 100);
    //visionField.add(graph.center);
    
    for(Permutation i: graph.generators){
      composition = permutation.compose(i);
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
//      acceleration.x = -directionalDerivative(visionField, position, dx);
//      acceleration.y = -directionalDerivative(visionField, position, dy);
      //acceleration.z = -directionalDerivative(visionField, position, dz);

     //velocity.add(acceleration);
     //velocity.normalize();
     //position.add(velocity);
     //position.add(PVector.mult(acceleration, 1));
     PVector force;
    for(PermutationNode i: neighbors){
      if(position.dist(i.position) != 0){
        force = PVector.sub(position, i.position);
        force.normalize();
        position.add(PVector.mult(force, - 0.5 * log(position.dist(i.position))));   
//   0.0002 * log(position.dist(i.position)))/     
      }
    }
      for(PermutationNode i: graph.vertices){
        if(position.dist(i.position) != 0){
          force = PVector.sub(position, i.position);
          force.normalize();
          position.add(PVector.mult(force, 100 / position.dist(i.position))); 
        }  
  //   0.0002 * log(position.dist(i.position)))/     
      }
//      else{
//        velocity.x = 0;
//        velocity.y = 0; 
//        break;
//      }
    //position.add(velocity);
    //position.add(force.add
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
    fill(0);
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
  //Field center;
  float Xmax;
  float Xmin;
  float Ymax;
  float Ymin;
  CayleyGraph(ArrayList<Permutation> tempgenerators){
    generators = tempgenerators;
    vertices = new ArrayList();
    //center = new Field();
    //center.add(new PotentialWell(new PVector(XSIZE / 2.0 + XMARGIN, YSIZE / 2.0 + YMARGIN), 200));
    //center.add(new Border(20));
    new PermutationNode(new Permutation(1), this);
    Xmax = 0;
    Xmin = 0;
    Ymax = 0;
    Ymin = 0;
  }
  
  boolean findIn(Permutation perm){
    for(PermutationNode i : vertices){
      if(perm.equals(i.permutation)){
        return true;
      }
    }
    return false;
  }
  PVector center(){
    PVector center = new PVector(0,0);
    for(PermutationNode i :vertices){
      center.add(i.position);
    } 
    return PVector.mult(center, 1.0/vertices.size());
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
    pushMatrix();
    PVector center = center();
    translate(-center.x + XSIZE / 2.0 + XMARGIN, -center.y + YSIZE / 2.0 + YMARGIN);
    scale(0.1, 0.1);
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
      if(i.position.x > Xmax){
        Xmax = i.position.x;
      }
      if(i.position.x < Xmin){
        Xmin = i.position.x;
      }
      if(i.position.y > Ymax){
        Ymax = i.position.y;
      }
      if(i.position.x < Ymin){
        Ymin = i.position.y;
      }
    }
  }
  String toSVG(){
    float maxX = 0;
    float minX = 0;
    float maxY = 0;
    float minY = 0;
    for(PermutationNode i : vertices){
      if(i.position.x > maxX){
        maxX = i.position.x;
      }
      if(i.position.x < minX){
        minX = i.position.x;
      }
      if(i.position.y > maxX){
        maxY = i.position.y;
      }
      if(i.position.y < minY){
        minY = i.position.y;
      }
    }
    StringBuilder svg = new StringBuilder();
    svg.append("<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" "
    + "width=\"700px\" height=\"700px\" viewBox=\"");
    
    svg.append(minX - XMARGIN);    
    svg.append(" ");
    svg.append(minY - YMARGIN);
    svg.append(" ");
    svg.append(maxX - minX + 2 * XMARGIN);
    svg.append(" ");
    svg.append(maxY - minY + 2 * YMARGIN);
    
    svg.append("\">\n"
    +"<style type=\"text/css\"><![CDATA[ellipse.node{ fill : blue;}line{stroke : black;stroke-width : 3px;}]]></style>\n");
    
    for(PermutationNode i : vertices){
      svg.append("<ellipse class = \"node\" rx=\"5\" ry=\"5\" cx=\"");
      svg.append(i.position.x);
      svg.append("\" cy=\"");
      svg.append(i.position.y);
      svg.append("\" id=\"");
      svg.append(i.toString());
      svg.append("\"/>\n");
      for(PermutationNode j: i.neighbors){
        svg.append("<line class = \"edge\" x1 =\"");
        svg.append(i.position.x);
        svg.append("\" y1 =\"");
        svg.append(i.position.y);
        svg.append("\" x2 =\"");
        svg.append(j.position.x);
        svg.append("\" y2 =\"");
        svg.append(j.position.y);
        if(j.permutation.equals(i.permutation.compose(generators.get(0))) ||
           i.permutation.equals(j.permutation.compose(generators.get(0)))){ 
            svg.append("\" style = \"stroke : red\"/>\n");
           }
         else{
            svg.append("\"/>\n");
         }
           
      }
    }
    svg.append("</svg>");
    return svg.toString();
  }
  String toJavascript(){
    StringBuilder javascript = new StringBuilder();
    
    for(PermutationNode i : vertices){
      javascript.append("var " + i.toString());
      javascript.append("= new Node(");
      javascript.append(i.position.x);
      javascript.append(", ");
      javascript.append(i.position.y);
      javascript.append(");\n");
    }
    for(PermutationNode i : vertices){
      for(PermutationNode j: i.neighbors){
        javascript.append(i.toString() + ".addNeighbor(" + j.toString() + ");\n");
      }
      javascript.append("\n");
    }
    javascript.append("var cayleyGraph = new CayleyGraph();\n");
    for(PermutationNode i : vertices){
        javascript.append("cayleyGraph.addNode(" + i.toString() + ");\n");
      javascript.append("\n");
    }
    return javascript.toString();
  }
}


CayleyGraph graph;
boolean updating = true;
void setup(){
  size(500, 500);
  background(255);
  translate(XSIZE / 2.0 + XMARGIN, YSIZE / 2.0 + YMARGIN);
//
  Permutation b = new Permutation(2, 3, 4, 1);
//  Permutation b = new Permutation(2, 3, 1);
  Permutation a = new Permutation(2, 1);
  
  ArrayList<Permutation> generators = new ArrayList();
  generators.add(b);
  generators.add(a);
  
  graph = new CayleyGraph(generators);
  for(int i = 0; i < 2500; i++){
    graph.updatePositions();    
  }
  //graph.display();
  graph.display();
  //noLoop();
    
//DisplayField field = new DisplayField(new PVector(width/2, height/2), 1, 1000);
//print(field.eval(new PVector(width/2, height/2)));
//field.display();
  
}

void draw(){
    background(255);
    graph.updatePositions();
    graph.display();
}
void mouseClicked(){
  String[] javascript = {graph.toJavascript()};
  saveStrings("CayleyGraph.svg", javascript);
}
