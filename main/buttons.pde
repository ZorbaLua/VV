
void startButtons() {
  btn[0] = new Button("Procurar Partida", 20, 20 , 120, 50);
  btn[1] = new Button("Resolucao",        20, 80 , 120, 50);
  btn[2] = new Button("Exit",             20, 140, 120, 50);
  btn[3] = new Button("Register",         20, 200, 120, 50);
  btn[4] = new Button("Login",            20, 260, 120, 50);
}

void keyPressed() {
    client.send(keyCode, true);
}

void keyReleased() {
    client.send(keyCode, true);
}

void mousePressed() {
  if      (btn[0].MouseIsOver()) { if(play()); menuState = 2; }
  else if (btn[1].MouseIsOver()) { scale(0.5, 0.5); surface.setSize(400, 300); }
  else if (btn[2].MouseIsOver()) { exit(); }
  else if (btn[3].MouseIsOver()) { signin(); }
  else if (btn[4].MouseIsOver()) { if(login()); menuState = 1; }
}
