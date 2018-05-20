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
    int lvl;
    Boolean invED, invER;

  // ----------------------------------------------------------------------- //
  Player(String labelB, float xpos, float ypos, int lev) {
    super(labelB, xpos, ypos, 120, 25);
    lvl = lev; invED = false; invER = false;
  }

  // ----------------------------------------------------------------------- //
  void Draw() {
    fill(218);
    stroke(141);
    rect(x, y, w, h, 10);
    textAlign(LEFT);
    fill(0);
    String res = String.format("%s(%s)", label, lvl);
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

void drawHeart(int x, int y) {
  beginShape();
    vertex(50+x, 15+y);
    bezierVertex(50+x, -5+y, 90+x, 5+y, 50+x, 40+y);
    vertex(50+x, 15+y);
    bezierVertex(50+x, -5+y, 10+x, 5+y, 50+x, 40+y);
  endShape();
}

// -------------------------------------------------------------------------- //

void keyPressed() {
  setMove(keyCode, true);
}

void keyReleased() {
  setMove(keyCode, false);
}

class Jogador extends Ponto {

  int energia;
  int vida;
  float rotation;
  float rotation_vel;
  boolean andar;

  Jogador(int ind) {
    energia = 50;

    if (ind == 0) {
      location = new PVector( width/2-100, height/2);
      rotation = PI/2;
    } else {
      location = new PVector( width/2+100, height/2);
      rotation = 3*PI/2;
    }

    velocity = new PVector(0,0);
    acceleration = new PVector(0,0);
    topspeed = 1.5;
    vida = 3;
    radius = 24;
    topspeed = 2;
  }

  void update() {

    if (rotation > 2*PI) { rotation -= 2*PI; }
    if (rotation < 2*PI) { rotation += 2*PI; }

    if (energia < 100) { energia += 1; }
    PVector dir = new PVector(location.x, location.y);

    if ( location.x < 0 || location.x > width || location.y < 0 || location.y > height ) {
      location.x = width/2; location.y = height/2;
      acceleration.x = 0; acceleration.y = 0;
      velocity.x = 0; velocity.y = 0;
      Jogador.this.vida -= 1;
    }

    if (andar && energia >= 30) {
      dir.x += sin(rotation)*30;
      dir.y += cos(rotation)*30;
      energia -= 30;
    }

    this.acceleration = PVector.sub(dir,location);
    acceleration.setMag(0.5);

    this.update_pos();
  }

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
      case 'W':   jogadores[1].andar = b;       break;
      case UP:    jogadores[0].andar = b;       break;
      case 'S':   jogadores[1].rotation += 0.3; break;
      case DOWN:  jogadores[0].rotation += 0.3; break;
      case 'A':   jogadores[1].rotation += 0.3; break;
      case LEFT:  jogadores[0].rotation += 0.3; break;
      case 'D':   jogadores[1].rotation -= 0.3; break;
      case RIGHT: jogadores[0].rotation -= 0.3; break;

      default: break;
    }
}

// -------------------------------------------------------------------------- //


class Vaga extends Ponto {

  int Classe; // 0 - vermelhas; 1 - verdes;

  Vaga(int classe) {
    float x = random(10,width-10),
          y = random(10,height-10);

    location = new PVector(x,y);
    velocity = new PVector(0,0);
    acceleration = new PVector(0,0);
    topspeed = 1.5;
    Classe = classe;
    radius = 12;

  }

  void update() {

    if (Classe == 1) {
      for (Jogador jog: jogadores) {
        if (location.dist(jog.location)<this.radius+jog.radius) {
          jogadores[0].energia = 100;
          pontos.remove(this);
          pontos.add(new Vaga(1));
        }
      }

    } else if(Classe == 0) {
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
