float x = 0;
float y = 0;

void setup(){
  size(860,640);
}

void draw(){
  background(100);
  translate(width/2,height/2);
  Ball[] balls = {
    new Ball(-400, -30, 20, 1),
    new Ball(20, 30, 10, 1)
  };
  
  for (Ball b : balls) {
     b.drawBall(); 
  }
}

class Ball {
   PVector position;
   PVector velocity;
   float mass;
   float radius;
   
   Ball(float x, float y, float r, float m) {
     position = new PVector(x,y);
     mass = m;
     radius = r;
   }
   
   void drawBall() {
     pushStyle();
     fill(0);
     ellipse(position.x, position.y, radius*2, radius*2);
     popStyle();
   }
   
}
