PShape t;

void setup() {
  size(1024, 512);

}

void draw() {
  background(100);
  translate(width/2, height/2);
  
  scale(100);
  noStroke();
  beginShape();
  vertex(-1,1/sqrt(3));
  vertex(1,1/sqrt(3));
  vertex(0,-2/sqrt(3));
  beginContour();
  vertex(-0.5,0.5/sqrt(3));
  vertex(0,-1/sqrt(3));
  vertex(0.5,0.5/sqrt(3));
  endContour();
  endShape();

 
  triangle(-1, 1/sqrt(3), 1, 1/sqrt(3), 0, -2/sqrt(3) );
}