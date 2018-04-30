
ArrayList <Vaga> pontos = new ArrayList <Vaga> ();
Jogador[] jogadores = new Jogador[2];

// --------------------------------------------------------------------------- //

void setup() {
  size(800,600);
  smooth(4);
  frameRate(60);
  textAlign(CENTER, CENTER);
  ellipseMode(CENTER);

  jogadores[0] = new Jogador(0);
  jogadores[1] = new Jogador(1);
}

void draw() {

  background(255);
  if (frameCount % (3*60) == 0) { pontos.add(new Vaga(0)); }

  for (int i = pontos.size()-1; i>=0; i--) {
    Vaga m = pontos.get(i);
    m.update();
    m.display();
  }

  for (Jogador jog: jogadores) {
    jog.update();
    jog.display();
  }

  drawPlayersStats();
}

// --------------------------------------------------------------------------- //

void drawHeart(int x, int y) {
  beginShape();
  vertex(50+x, 15+y);
  bezierVertex(50+x, -5+y, 90+x, 5+y, 50+x, 40+y);
  vertex(50+x, 15+y);
  bezierVertex(50+x, -5+y, 10+x, 5+y, 50+x, 40+y);
  endShape();
}

void drawPlayersStats() {
  int i = 0;
  for (Jogador jog: jogadores) { // Para todos os jogadores
    for (int ii = 0; ii<jog.vida; ii++) { // Para todas as vidas
      fill(255,0,0);
      drawHeart(0+50*ii,0+50*i);
    }
    for (int ii = 0; ii<jog.energia; ii++) { // Para todas as vidas
      fill(0);
      ellipse(ii*3+200,25+50*i,5,5);
    }
    i++;
  }
}

// --------------------------------------------------------------------------- //

class Ponto {
  color INK = #008000, OUTLINE = 0;
  float BOLD = 2.0;

  PVector location;
  PVector velocity;
  PVector acceleration;
  float topspeed;
  int radius;

  // - Construtores ------------------ //

  Ponto() {
    location = new PVector(width/2,height/2);
    velocity = new PVector(0,0);
    acceleration = new PVector(0,0);
    topspeed = 1;
  }

  // - Update ------------------ //

  void update_pos() {
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
  }

}

// --------------------------------------------------------------------------- //

void keyPressed() {
  setMove(keyCode, true);
}

void keyReleased() {
  setMove(keyCode, false);
}

class Jogador extends Ponto {

  int energia;
  int vida;
  boolean andar;

  float rotation;
  float rotation_speed;
  float rotation_accel;

  // - Construtores ------------------ //

  Jogador(int ind) {

    if (ind == 0) {
      location = new PVector( width/2-100, height/2);
      rotation = PI/2;
    } else {
      location = new PVector( width/2+100, height/2);
      rotation = 3*PI/2;
    }

    energia = 50;
    velocity = new PVector(0,0);
    acceleration = new PVector(0,0);
    topspeed = 1.5;
    vida = 3;
    radius = 24;
    topspeed = 2;
  }

  // - Update ------------------------ //

  void update() {

    // - Fora da Janela -------------- //
    if ( location.x < 0 || location.x > width || location.y < 0 || location.y > height ) {
      location.x = width/2; location.y = height/2;
      acceleration.x = 0; acceleration.y = 0;
      velocity.x = 0; velocity.y = 0;
      Jogador.this.vida -= 1;
    }

    // - Rotacao --------------------- //
    if (rotation > 2*PI) { rotation -= 2*PI; }
    if (rotation < 2*PI) { rotation += 2*PI; }

    rotation_speed += rotation_accel;
    if (rotation_speed >  5) { rotation_speed =  5; }
    if (rotation_speed < -5) { rotation_speed = -5; }

    rotation += rotation_speed * 0.5 * PI

    // - Movimento ------------------- //
    PVector dir = new PVector(location.x, location.y);
    if (energia < 100 &&  frameCount % 4 == 0) { energia += 1; }

    if (andar && energia >= 5) {
      dir.x += sin(rotation)*30;
      dir.y += cos(rotation)*30;
      energia -= 2;
    }

    this.acceleration = PVector.sub(dir,location);
    acceleration.setMag(0.5);

    this.update_pos();
  }

  // - Display ----------------------- //
  void display() {
    stroke(255);
    strokeWeight(2);
    fill(127);
    ellipse(location.x,location.y,2*radius,2*radius);
    fill(255);
    ellipse( sin(rotation+0.3)*20+location.x, cos(rotation+0.3)*20+location.y,20,20);
    ellipse( sin(rotation-0.3)*20+location.x, cos(rotation-0.3)*20+location.y,20,20);
    fill(0);
    ellipse( sin(rotation+0.3)*20+location.x, cos(rotation+0.3)*20+location.y,10,10);
    ellipse( sin(rotation-0.3)*20+location.x, cos(rotation-0.3)*20+location.y,10,10);
  }
}

void setMove(int key, boolean b) {
  switch (key) {
    case 'W':   jogadores[1].andar = b; break;
    case UP:    jogadores[0].andar = b; break;
    case 'A':   if (rotation_accel >= 0) then { jogadores[1].rotation_accel += 0.3; } else { rotation_accel = 0} break;
    case LEFT:  if (rotation_accel >= 0) then { jogadores[0].rotation_accel += 0.3; } else { rotation_accel = 0} break;
    case 'D':   if (rotation_accel <= 0) then { jogadores[1].rotation_accel -= 0.3; } else { rotation_accel = 0} break;
    case RIGHT: if (rotation_accel <= 0) then { jogadores[0].rotation_accel -= 0.3; } else { rotation_accel = 0} break;

  //case 'S':   if (rotation_accel <= 0) then { jogadores[1].rotation_accel -= 0.3; } else { rotation_accel = 0} break;
  //case DOWN:  if (rotation_accel <= 0) then { jogadores[1].rotation_accel -= 0.3; } else { rotation_accel = 0} break;

    default: break;
  }
}

// --------------------------------------------------------------------------- //

class Vaga extends Ponto {

  int Classe; // 0 - vermelhas; 1 - verdes;

  Vaga(int classe) {
  float x = random(10, width  - 10),
        y = random(10, height - 10);

  location = new PVector(x,y);
  velocity = new PVector(0,0);
  acceleration = new PVector(0,0);
  topspeed = 1.5;
  Classe = classe;
  radius = 12;

  }

  void update() {

    if (Classe == 1) { // Vermelha
      for (Jogador jog: jogadores) {
        if (location.dist(jog.location)<this.radius+jog.radius) {
          jogadores[0].energia = 100;
          pontos.remove(this);
          pontos.add(new Vaga(1));
        }
      }

    } else if(Classe == 0) { // Verde
      PVector nearest;
      if(this.location.dist(jogadores[0].location) < this.location.dist(jogadores[1].location)) {
        nearest = jogadores[0].location;
      } else {
        nearest = jogadores[1].location;
      }
      this.acceleration = PVector.sub(nearest,location);
      acceleration.setMag(0.5);

      for(Jogador jog: jogadores) {
        if ( location.dist(jog.location)< this.radius+jog.radius ) {
          jog.vida -= 1;
          pontos.remove(this);
        }
      }

      this.update_pos();
    }

  }

  void display() {
    stroke(255);
    strokeWeight(2);
    if(Classe==0) {
      fill(255,0,0);
    }else{
      fill(0,255,0);
    }

    ellipse(location.x,location.y,2*radius,2*radius);
  }
}

// --------------------------------------------------------------------------- //
