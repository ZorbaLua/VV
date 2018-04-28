
ArrayList <Ponto> pontos = new ArrayList <Ponto> ();
Jogador[] jogadores = new Jogador[2];

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

  background(255);
  if (frameCount % 60 == 0) { pontos.add(new Ponto()); }
  for (int i = pontos.size()-1; i>=0; i--) {
    Ponto m = pontos.get(i);
    m.update();
    m.display();
  }

  for (int i = 0; i<1; i++) {
    jogadores[i].update();
    jogadores[i].display();
  }
  drawPlayersStats();
}

void drawPlayersStats() {
  for (int i = 0; i<2; i++) { // Para todos os jogadores
    for (int ii = 0; ii<jogadores[i].vida; ii++) { // Para todas as vidas
        drawHeart(0+50*ii,0+50*i);
    }
    for (int ii = 0; ii<jogadores[i].energia; ii++) { // Para todas as vidas
        ellipse(ii*3+200,25+50*i,5,5);
    }
  }
}

void drawHeart(int x, int y) {
  beginShape();
    vertex(50+x, 15+y);
    bezierVertex(50+x, -5+y, 90+x, 5+y, 50+x, 40+y);
    vertex(50+x, 15+y);
    bezierVertex(50+x, -5+y, 10+x, 5+y, 50+x, 40+y);
  endShape();
}

// -------------------------------------------------------------------------- //

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
    topspeed = 1;
  }

  void update() {

    PVector dir = new PVector(jogadores[0].location.x, jogadores[0].location.y);
    PVector acceleration = PVector.sub(dir,location);
    acceleration.setMag(0.5);

    if ( sqrt(pow(location.x - jogadores[0].location.x, 2) + pow(location.y - jogadores[0].location.y, 2)) < 15 ) {
      jogadores[0].vida -= 1;
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
    ellipse(location.x,location.y,25,25);
  }
}

// -------------------------------------------------------------------------- //

void keyPressed() {
  jogadores[0].setMove(keyCode, true);
}

void keyReleased() {
  jogadores[0].setMove(keyCode, false);
}

class Jogador extends Ponto {

  int energia;
  int vida;
  int rotation;
  boolean andar;

  Jogador() {
    energia = 50;
    location = new PVector(10,10);
    velocity = new PVector(0,0);
    topspeed = 1.5;
    vida = 3;
  }

  void update() {

    if (rotation > 360) { rotation -= 360; }
    if (energia < 100) { energia += 1; }
    PVector dir = new PVector(location.x, location.y);

    if (andar) {
      if (energia >= 30) {
        dir.x += sin(rotation)*30;
        dir.y += cos(rotation)*30;
        energia -= 30;
      }
    }

    PVector acceleration = PVector.sub(dir,location);
    acceleration.setMag(0.3);

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
    ellipse( sin(rotation)*30+location.x, cos(rotation)*30+location.y,10,10);
  }

boolean setMove(int key, boolean b) {
  switch (key) {
    case 'W':
    case UP:    return andar = b;
    case 'S':
    case DOWN:  jogadores[0].rotation += 1; return b;
    case 'A':
    case LEFT:  jogadores[0].rotation += 1; return b;
    case 'D':
    case RIGHT: jogadores[0].rotation -= 1; return b;

  default: return b;
    }
  }
}

// -------------------------------------------------------------------------- //


class Vaga extends Ponto {

  int Classe;

  Vaga() {
    location = new PVector(10,10);
    velocity = new PVector(0,0);
    topspeed = 1.5;
  }

  void update() {

    PVector dir = new PVector(jogadores[0].location.x, jogadores[0].location.y);
    PVector acceleration = PVector.sub(dir,location);
    acceleration.setMag(0.5);

    if ( sqrt(pow(location.x - jogadores[0].location.x, 2) + pow(location.y - jogadores[0].location.y, 2)) < 15 ) {
      jogadores[0].vida -= 1;
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
    ellipse(location.x,location.y,25,25);
  }
}
