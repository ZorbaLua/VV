
import static javax.swing.JOptionPane.*;
import javax.swing.JPasswordField;

final StringDict accounts = new StringDict(
  new String[] { "adriano", "artur", "vasco" }, new String[] {"z", "z", "z"});

final JPasswordField pwd = new JPasswordField(); { println(accounts); }


Button[] btn = new Button[4];
ArrayList <Player> pls = new ArrayList <Player> ();
int rJX = 800, rJY = 600, menu = 0;
Boolean procura = false, started = true;

ArrayList <Vaga> pontos = new ArrayList <Vaga> ();
Jogador[] jogadores = new Jogador[2];

void setup() {
  size(800,600);
  if (frame != null) { surface.setResizable(true); }
  smooth(4);
  frameRate(60);

  startMenu();
}

void startMenu() {
  btn[0] = new Button("Procurar Partida", 20, 20 , 120, 50);
  btn[1] = new Button("Local Game",       20, 80 , 120, 50);
  btn[2] = new Button("Resolucao",        20, 140, 120, 50);
  btn[3] = new Button("Exit",             20, 200, 120, 50);

  for (int i=0; i<10; i++) { pls.add(new Player("zorba", 650, 50 + pls.size()* 30, 99)); }
}

void startGame() {
  jogadores[0] = new Jogador(0); pontos.add(new Vaga(1));
  jogadores[1] = new Jogador(1); pontos.add(new Vaga(1));
}

void endGame() {
  for (int i = pontos.size()-1; i>=0; i--) { Vaga m = pontos.get(i); pontos.remove(m); }
}

void drawLogin(){
  String user = askUser();
  if (user == null) confirmQuit(); else if (!"".equals(user))  askPass(user);
}


void draw() {
  switch (menu) {
            case 0:  drawLogin(); break;
            case 1:  drawMenu(); break;
            case 2:  drawGame(); break;
  }
}

void drawGameCoutdown() {
  // FAZER COUTDOWN DO INICIO DO JOGO?
}

void drawGame() {
  background(255);

  for (Jogador jog: jogadores) { if (jog.vida == 0) { endGame(); menu = 1; } }
  if (frameCount % (3*60) == 0) { pontos.add(new Vaga(0)); }

  for (int i = pontos.size()-1; i>=0; i--) { Vaga m = pontos.get(i); m.update(); m.display(); }

  for (Jogador jog: jogadores) { jog.update(); jog.display(); }
  drawPlayersStats();
}

void drawMenu() {
  if      (btn[0].MouseIsOver()) { fill(color(50)); rect(btn[0].x-2, btn[0].y-2, btn[0].w+4, btn[0].h+4, 10); }
  else if (btn[1].MouseIsOver()) { fill(color(50)); rect(btn[1].x-2, btn[1].y-2, btn[1].w+4, btn[1].h+4, 10); }
  else if (btn[2].MouseIsOver()) { fill(color(50)); rect(btn[2].x-2, btn[2].y-2, btn[2].w+4, btn[2].h+4, 10); }
  else    { background(30); }

  fill(255);
  textAlign(RIGHT);
  String res = String.format("%s x %s", rJX, rJY);
  text(res, 780, 20);
  textAlign(CENTER);

  if (procura) {
    int a = 25 + (int)(Math.random() * ((35 - 25) + 1));
    ellipse(180,45,a,a);
  }

  for (int i = pls.size()-1; i>=0; i--) {
    Player m = pls.get(i);
    //m.update();
    m.Draw();
  }
  for (Button b: btn) { b.Draw(); }
}

void startProcura() {
  procura = true;
  for (int i = pls.size()-1; i >= 0; i--) { Player m = pls.get(i); m.invED = true; }
}

void endProcura() {
  procura = false;
  for (int i = pls.size()-1; i >= 0; i--) { Player m = pls.get(i); m.invED = false; }
}

void mousePressed() {
  if      (btn[0].MouseIsOver()) { if(procura) {endProcura();} else {startProcura();} }
  else if (btn[1].MouseIsOver()) { startGame(); menu = 2; }
  else if (btn[2].MouseIsOver()) { scale(0.5, 0.5); surface.setSize(400, 300); }
  else if (btn[3].MouseIsOver()) { exit(); }

  for (int i = pls.size()-1; i >= 0; i--) {
    Player m = pls.get(i);
    if (m.MouseIsOver()) { if(m.invED) { m.invED = false; } else { m.invED = true; } }
  }
}
