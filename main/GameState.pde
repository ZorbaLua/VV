import java.util.ArrayList;
import java.util.regex.*;

ArrayList<Berrie> stringToListVagas(String s){
        ArrayList<Berrie> ret = new ArrayList<Berrie>();

        s = s.substring(1, s.length()-1);
        String[] m = s.split(",");
        for(String stringBerrie:m) ret.add(new Berrie(stringBerrie)); 

        return ret;
} 


class Berrie{
    final float radius = 12;
    PVector pos;

    Berrie(String s) {
       // System.out.println("reconhecer Berrie\n");
       // s = s.substring(1, s.length()-1);
       // String[] res = s.split(",");
       // Pattern r = Pattern.compile("{(.*),(.*)}");
       // Matcher m = r.matcher(s);

       // if(m.find()){
       //     System.out.println("reconheceu Berrie\n");
       //     this.pos = new Vector(m.group(0));
       // }
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
    PVector pos;
    float vel, ace;
    float angle, velAng, aceAng;
    int health;
    int stamina;

    Champion(float x, float y ,float vp, float ap, float angle, float va, float aa, int health, int stamina){
        this.pos    = new PVector(x,y);
        this.vel    = vp;
        this.ace    = ap;
        this.angle  = angle; 
        this.velAng = va; 
        this.aceAng = aa;    
        this.health = health;    
        this.stamina= stamina;
    }

    Champion(float x, float y, float angle){
        this.pos = new PVector(x, y);
        this.vel = 0.0;
        this.ace = 0.0;
        this.angle = 0.0;
        this.velAng = 0.0;
        this.aceAng = 0.0;
        this.health = 0;
        this.stamina =0;
    }

    Champion(String s){
        Pattern r = Pattern.compile("\\{([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^\\}]*)\\}");
        Matcher m = r.matcher(s);

        if(m.find()){
            //System.out.println("reconheceu Champion\n");
            this.pos    = new PVector(Float.parseFloat(m.group(1)), Float.parseFloat(m.group(2)));
            this.vel    = Float.parseFloat(m.group(3));
            this.ace    = Float.parseFloat(m.group(4));
            this.angle  = Float.parseFloat(m.group(5));
            this.velAng = Float.parseFloat(m.group(6));
            this.aceAng = Float.parseFloat(m.group(7));
            this.health = Integer.parseInt(m.group(8));
            this.stamina= Integer.parseInt(m.group(9));
        }
    }

    void display(){
        stroke(255);
        strokeWeight(2);
        fill(127);
        ellipse(this.pos.x,this.pos.y,2*radius,2*radius);
        fill(255);
        ellipse( sin(this.angle+0.3)*20+this.pos.x, cos(this.angle+0.3)*20+this.pos.y,20,20);
        ellipse( sin(this.angle-0.3)*20+this.pos.x, cos(this.angle-0.3)*20+this.pos.y,20,20);
        fill(0);
        ellipse( sin(this.angle+0.3)*20+this.pos.x, cos(this.angle+0.3)*20+this.pos.y,10,10);
        ellipse( sin(this.angle-0.3)*20+this.pos.x, cos(this.angle-0.3)*20+this.pos.y,10,10);
    }
}

class GameState{
    Champion[] champs = new Champion[2];
    ArrayList<Berrie> redBerries;
    ArrayList<Berrie> greenBerries;

    GameState(){
        this.champs[0] = new Champion(2,2,0);
        this.champs[1] = new Champion(-2,2,180);
        this.redBerries = new ArrayList<Berrie>();
        this.greenBerries = new ArrayList<Berrie>();
    }

    synchronized void update(String s){
        Pattern r = Pattern.compile("([^ ]*) ([^ ]*) ([^ ]*) ([^ ])");
        Matcher m = r.matcher(s);

        if(m.find()){
            //System.out.println("reconheceu gamestate\n");
            this.champs[0] = new Champion(m.group(0));
            this.champs[1] = new Champion(m.group(1));
            //this.redBerries = stringToListVagas(m.group(2));
            //this.greenBerries = stringToListVagas(m.group(3));
        }
    }

    synchronized void display(){
        for(Champion champ: this.champs) champ.display();
        for(Berrie rb: redBerries) rb.display(true); 
        for(Berrie gb: greenBerries) gb.display(false); 
    }


}
