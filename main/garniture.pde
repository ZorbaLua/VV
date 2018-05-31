
class Ranks {
    String label;
    float x, y;
    Player a, b, c;


    // ----------------------------------------------------------------------- //
  Ranks(String labelB, float xpos, float ypos) {
    label = labelB;
    x = xpos;
    y = ypos;
  }

  // ----------------------------------------------------------------------- //
  void display() {
    fill(218);
    stroke(141);
    rect(x, y, 10, 10, 10);
    textAlign(CENTER, CENTER);
    fill(0);
    text(label, x + (10/2), y + (10/2));
  }

}

class Button {
    String label;
    float x, y, w, h;

    // ----------------------------------------------------------------------- //
  Button(String labelB, float xpos, float ypos, float widthB, float heightB) {
    label = labelB;
    x = xpos;
    y = ypos;
    w = widthB;
    h = heightB;
  }

  // ----------------------------------------------------------------------- //
  void display() {
    fill(218);
    stroke(141);
    rect(x, y, w, h, 10);
    textAlign(CENTER, CENTER);
    fill(0);
    text(label, x + (w/2), y + (h/2));
  }

  // ----------------------------------------------------------------------- //
  boolean MouseIsOver() {
    if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) { return true; }
    else { return false; }
  }
}

// --------------------------------------------------------------------------- //

class Player extends Button {
    int lvl, vic;
    Boolean invED, invER;

  // ----------------------------------------------------------------------- //
  Player(String labelB, float xpos, float ypos, int lev, int vict) {
    super(labelB, xpos, ypos, 120, 25);
    lvl = lev; vic=vict; invED = false; invER = false;
  }

  // ----------------------------------------------------------------------- //
  void display() {
    fill(218);
    stroke(141);
    rect(x, y, w, h, 10);
    textAlign(LEFT);
    fill(0);
    String res = String.format("%s(%s) V:%s", label, lvl, vic);
    text(res, x + 10, y + (h / 2) + 3);
    if (invED) { fill(50,205,50); } else { fill(220,20,60); } ellipse(x+w-20, y+h/2, 8, 8);
    if (invER) { fill(50,205,50); } else { fill(220,20,60); } ellipse(x+w-10, y+h/2, 8, 8);
  }

  // ----------------------------------------------------------------------- //
  boolean MouseIsOver() {
    if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) { return true; }
    else { return false; }
  }
}

class Ponto {
  //cor
  color INK = #008000, OUTLINE = 0;
  float BOLD = 2.0;

  //posicao
  PVector location;
  PVector velocity;
  PVector acceleration;
  float topspeed;
  int radius;

  Ponto() {
    location = new PVector(width/2,height/2);
    velocity = new PVector(0,0);
    acceleration = new PVector(0,0);
    topspeed = 1;
  }

  void update_pos() {
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
  }

}
/*
void drawHeart(int x, int y) {
  beginShape();
    vertex(50+x, 15+y);
    bezierVertex(50+x, -5+y, 90+x, 5+y, 50+x, 40+y);
    vertex(50+x, 15+y);
    bezierVertex(50+x, -5+y, 10+x, 5+y, 50+x, 40+y);
  endShape();
}
*/
// -------------------------------------------------------------------------- //
