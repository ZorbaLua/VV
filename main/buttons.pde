
void startButtons() {
  btn[0] = new Button("Procurar Partida", 20, 20 , 120, 50);
  btn[1] = new Button("Update Ranks",     20, 80 , 120, 50);
  btn[2] = new Button("LogOut",           20, 200, 120, 50);
  btn[3] = new Button("Jogo Local",       20, 140, 120, 50);
  btn[4] = new Button("Exit",             20, 260, 120, 50);
  btn[5] = new Button("Login",            20, 20 , 120, 50);
  btn[6] = new Button("Register",         20, 80 , 120, 50);
}

void keyPressed() {
    client.send(keyCode, "press ");
}

void keyReleased() {
    client.send(keyCode, "release ");
}

void mousePressed() {
  if      (btn[0].MouseIsOver() && menuState == 1) { if(play()); menuState = 2; }
  else if (btn[1].MouseIsOver() && menuState == 1) { client.updateInfo(); }
  else if (btn[2].MouseIsOver() && menuState == 1) { /*login*/ menuState = 0; }
  else if (btn[3].MouseIsOver() )                  { /*menuState = 2;*/ }
  else if (btn[4].MouseIsOver() )                  { exit(); }
  else if (btn[5].MouseIsOver() && menuState == 0) { if(login()) { menuState = 1; /*client.updateInfo();*/ }}
  else if (btn[6].MouseIsOver() && menuState == 0) { if(signin()) menuState = 1; }
}
