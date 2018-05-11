
Button[] btn = new Button[3];
ArrayList <Player> pls = new ArrayList <Player> ();
int rJX = 800, rJY = 600;

void setup() {
  size(800,600);
  if (frame != null) { surface.setResizable(true); }
  smooth(4);
  frameRate(60);

  btn[0] = new Button("Click Me",  20, 20 , 100, 50);
  btn[1] = new Button("Click Me",  20, 80 , 100, 50);
  btn[2] = new Button("Resolucao", 20, 140, 100, 50);
}

void draw() {
  if      (btn[0].MouseIsOver()) { fill(color(50)); rect(btn[0].x-2, btn[0].y-2, btn[0].w+4, btn[0].h+4, 10); }
  else if (btn[1].MouseIsOver()) { fill(color(50)); rect(btn[1].x-2, btn[1].y-2, btn[1].w+4, btn[1].h+4, 10); }
  else if (btn[2].MouseIsOver()) { fill(color(50)); rect(btn[2].x-2, btn[2].y-2, btn[2].w+4, btn[2].h+4, 10); }
  else    { background(30); }

  fill(255);
  textAlign(RIGHT);
  String res = String.format("%s x %s", rJX, rJY);
  text(res, 780, 20);
  textAlign(CENTER);

  if (frameCount % (1*60) == 0) { pls.add(new Player("zorba",700, 50 + pls.size()* 30, 99)); }

  for (int i = pls.size()-1; i>=0; i--) {
    Player m = pls.get(i);
    //m.update();
    m.Draw();
  }

  for (Button b: btn) { b.Draw(); }
}

void mousePressed() {
  if      (btn[0].MouseIsOver()) { ; }
  else if (btn[1].MouseIsOver()) { ; }
  else if (btn[2].MouseIsOver()) { surface.setSize(400, 300); }
}

  // --------------------------------------------------------------------------- //
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
  void Draw() {
    fill(218);
    stroke(141);
    rect(x, y, w, h, 10);
    textAlign(CENTER, CENTER);
    fill(0);
    text(label, x + (w / 2), y + (h / 2));
  }

  // ----------------------------------------------------------------------- //
  boolean MouseIsOver() {
    if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) { return true; }
    else { return false; }
  }
}

// --------------------------------------------------------------------------- //

class Player extends Button {
    int lvl;
    Boolean invED, invER;

  // ----------------------------------------------------------------------- //
  Player(String labelB, float xpos, float ypos, int lev) {
    super(labelB, xpos, ypos, 20, 20);
    lvl = lev; invED = false; invER = false;
  }

  // ----------------------------------------------------------------------- //
  void Draw() {
    fill(218);
    stroke(141);
    rect(x, y, w, h, 10);
    textAlign(LEFT, CENTER);
    fill(0);
    text(label, x + (w / 2), y + (h / 2));
  }

  // ----------------------------------------------------------------------- //
  boolean MouseIsOver() {
    if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) { return true; }
    else { return false; }
  }
}
