import java.util.ArrayList;

class Vector{
    boolean isPoint;
    float x, y;

    Vector(float x, float y){
        this.x = x;
        this.y = y;
    }
    Vector(String s){
        s = s.substring(1, s.length()-1);
        String[] res = s.split(",");
        this.x = Integer.parseInt(res[0]);
        this.y = Integer.parseInt(res[1]);
    }

    void mult(float scalar){
        this.x = scalar * x;
        this.y = scalar * y;
    }
}

class Champion{
    Vector pos;
    Vector vel;
    Vector acc;
    int health;
    int stamina;

    Champion(float x, float y){
        this.pos = new Vector(x,y);
        this.vel = new Vector(0,0);
        this.acc = new Vector(0,0);
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
        this.health = Integer.parseInt(res[3]);
        this.stamina = Integer.parseInt(res[4]);
    }

    /* 
    * calculos auxiliaeres para por mais frames aqui
    *
    */

}
class GameState{
    Champion champ1;
    Champion champ2;
    ArrayList<Vector> vagasVermelhas;
    ArrayList<Vector> vagasVerdes;


    GameState(){
        this.champ1 = new Champion(2,2);
        this.champ2 = new Champion(-2,2);
        this.vagasVermelhas = new ArrayList<Vector>();
        this.vagasVerdes = new ArrayList<Vector>();
    }

    GameState(String s){
        s = s.substring(1, s.length()-1);
        String[] res = s.split(",");
        ArrayList<Vector> aux = new ArrayList<Vector>();
        this.champ1 = new Champion(res[0]);
        this.champ2 = new Champion(res[1]);
        this.vagasVermelhas = stringToListVagas(res[2]);
        this.vagasVerdes = stringToListVagas(res[3]);
    
    }
    private static ArrayList<Vector> stringToListVagas(String s){
        ArrayList<Vector> ret = new ArrayList<Vector>();

        s = s.substring(1, s.length()-1);
        String[] res = s.split(",");
        for(String vs:res) ret.add(new Vector(vs)); 

        return ret;
    } 
}
