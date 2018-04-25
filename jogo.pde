
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
  drawPlayersHP();
}

void drawPlayersHP() {
  for (int i = 0; i<2; i++) { // Para todos os jogadores
    for (int ii = 0; ii<jogadores[i].Vida; ii++) { // Para todas as vidas
        drawHeart(0+50*ii,0+50*i);
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
    topspeed = 2;
  }

  void update() {

    PVector dir = new PVector(jogadores[0].location.x, jogadores[0].location.y);
    PVector acceleration = PVector.sub(dir,location);
    acceleration.setMag(0.2);

    if ( sqrt(pow(location.x - jogadores[0].location.x, 2) + pow(location.y - jogadores[0].location.y, 2)) < 15 ) {
      jogadores[0].Vida -= 1;
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

void keyPressed() {
  jogadores[0].setMove(keyCode, true);
}

void keyReleased() {
  jogadores[0].setMove(keyCode, false);
}

class Jogador extends Ponto {

  float Energia;
  int Vida;
  int rotation;

  Jogador() {
    location = new PVector(10,10);
    velocity = new PVector(0,0);
    topspeed = 3;
    Vida = 3;
  }


  void update() {

    if (rotation > 360) { rotation -= 360;}

    PVector dir = new PVector(sin(rotation)*30+location.x, cos(rotation)*30+location.y);
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
    ellipse( sin(rotation)*30+location.x, cos(rotation)*30+location.y,10,10);
  }


  float setMove(int key, boolean b) {
    switch (key) {
    case 'W':
    case UP:    return rotation += 1;
    case 'S':
    case DOWN:  return rotation += 1;
    case 'A':
    case LEFT:  return rotation -= 1;
    case 'D':
    case RIGHT: return rotation += 1;

    default: return 0;
    }
  }
}
