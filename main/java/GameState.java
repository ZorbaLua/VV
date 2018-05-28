import java.util.ArrayList;
import processing.core.*;
//import processing.core.PVector;
//import processing.core.PApplet;

class Vector extends PVector{
    Vector(float x, float y){
        super(x, y);
    }
    Vector(String s){
        super(0, 0);
        s = s.substring(1, s.length()-1);
        String[] res = s.split(",");
        this.x = Float.parseFloat(res[0]);
        this.y = Float.parseFloat(res[1]);
    }
}

class Berrie{
    final float radius = 12;
    Vector pos;
    Vector vel;
    Vector acc;

    Berrie(String s) {
        s = s.substring(1, s.length()-1);
        String[] res = s.split(",");
        this.pos = new Vector(res[0]);
        this.vel = new Vector(res[1]);
        this.acc = new Vector(res[2]);
    }

    void display(boolean isRed) {
        stroke(255);
        strokeWeight(2);
        if(isRed) fill(255,0,0);
        else fill(0,255,0);
        ellipse(pos.x,pos.y,2*radius,2*radius);
  }

}

class Champion{
    final float radius = 24;
    Vector pos;
    Vector vel;
    Vector acc;
    float rot;
    int health;
    int stamina;

    Champion(float x, float y, float angle){
        this.pos = new Vector(x,y);
        this.vel = new Vector(0,0);
        this.acc = new Vector(0,0);
        this.rot = rot;
        this.health = 100;
        this.stamina = 100;
    }
    Champion(float x, float y ,float vx, float vy, float ax, float ay, int health, int stamina){
        this.pos = new Vector(x,y);
        this.vel = new Vector(vx, vy);
        this.acc = new Vector(ax, ay);
        this.health = health;
        this.stamina = stamina;
    }
    Champion(String s){
        s = s.substring(1, s.length()-1);
        String[] res = s.split(",");
        this.pos = new Vector(res[0]);
        this.vel = new Vector(res[1]);
        this.acc = new Vector(res[2]);
        this.rot = Float.parseFloat(res[3]);
        this.health = Integer.parseInt(res[4]);
        this.stamina = Integer.parseInt(res[5]);
    }

    void display(){
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

class GameState{
    Champion[] champs = new Champion[2];
    ArrayList<Berrie> redBeries;
    ArrayList<Berrie> greeBerries;

    GameState(){
        this.champs[0] = new Champion(2,2);
        this.champs[1] = new Champion(-2,2);
        this.redBerries = new ArrayList<Vector>();
        this.greeBerries = new ArrayList<Vector>();
    }

    GameState(String s){
        s = s.substring(1, s.length()-1);
        String[] res = s.split(",");
        ArrayList<Vector> aux = new ArrayList<Vector>();
        this.champ1 = new Champion(res[0]);
        this.champ2 = new Champion(res[1]);
        this.redBerries = stringToListVagas(res[2]);
        this.greenBerries = stringToListVagas(res[3]);
    }

    void display(){
        for(Champion champ: this.chmaps) champ.display();
        for(Berrie rb: redBerries) rb.display(1); 
        for(Berrie rg: greeBerries) gb.display(0); 
    }

    private static ArrayList<Vector> stringToListVagas(String s){
        ArrayList<Vector> ret = new ArrayList<Vector>();

        s = s.substring(1, s.length()-1);
        String[] res = s.split(",");
        for(String stringBerrie:res) ret.add(new Berrie(stringBerrie)); 

        return ret;
    } 
}
