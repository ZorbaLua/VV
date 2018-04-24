
ArrayList <Ponto> pontos = new ArrayList <Ponto> ();
Jogador[] jogadores = new Jogador[2];

int pop = 10;

void setup() {
  size(800,600);
  smooth(4);
  frameRate(60);
  textAlign(CENTER, CENTER);
  ellipseMode(CENTER);

  jogadores[0] = new Jogador();
  jogadores[1] = new Jogador();
}

void draw() {
  background(0);

  if (frameCount % 60 == 0) {
    pontos.add(new Ponto());
  }
  for (int i = pontos.size()-1; i>=0; i--) {
    Ponto m = pontos.get(i);
    m.update();
    m.display();
  }

  for (int i = 0; i<2; i++) {
    jogadores[i].update();
    jogadores[i].display();
  }
}

class Ponto {
  static final color INK = #008000, OUTLINE = 0;
  static final float BOLD = 2.0;

  PVector location;
  PVector velocity;
  PVector acceleration;

  float topspeed;

  Ponto() {
    location = new PVector(width/2,height/2);
    velocity = new PVector(0,0);
    topspeed = 5;
  }

  void update() {
    PVector dir = new PVector(mouseX, mouseY);
    PVector acceleration = PVector.sub(dir,location);
    acceleration.setMag(0.2);

    if ( sqrt(pow(location.x - mouseX, 2) + pow(location.y - mouseY, 2)) < 10 ) {
      pontos.remove(this);
    }

    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
  }

  void display() {
    stroke(255);
    strokeWeight(2);
    fill(127);
    ellipse(location.x,location.y,48,48);
  }
}


class Jogador extends Ponto {

  float Energia;
  float Vida;
  float A; float B;

  void update() {
    PVector dir = new PVector(2, 2);
    PVector acceleration = PVector.sub(dir,location);
    acceleration.setMag(0.2);

    if ( sqrt(pow(location.x - mouseX, 2) + pow(location.y - mouseY, 2)) < 10 ) {
      pontos.remove(this);
    }

    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
  }

  void display() {
    stroke(255);
    strokeWeight(2);
    fill(127);
    ellipse(location.x,location.y,48,48);
  }


  float teclado(int key, boolean b) {
    switch (key) {
    case 'W':
    case UP:    return B = (location.y - 5.0);
    case 'S':
    case DOWN:  return B = (location.y + 5.0);
    case 'A':
    case LEFT:  return A = (location.x - 5.0);
    case 'D':
    case RIGHT: return A = (location.x + 5.0);

    default: return 0;
    }
  }
}
