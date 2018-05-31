import java.util.ArrayList;
import java.util.regex.*;

ArrayList<Berrie> stringToListVagas(String s){
        ArrayList<Berrie> ret = new ArrayList<Berrie>();

        if(s.length() <= 2) return ret;
        s = s.substring(2, s.length()-2);
        String[] m = s.split("\\};\\{");
        for(String stringBerrie:m) ret.add(new Berrie(stringBerrie));

        return ret;
}


class Berrie{
    final float radius = 12;
    PVector pos;

    Berrie(String s) {
       Pattern r = Pattern.compile("([^,]*),([^,]*)");
       Matcher m = r.matcher(s);

       if(m.find()){
            System.out.println("reconheceu Berrie\n");
            this.pos = new PVector(Float.parseFloat(m.group(1)), Float.parseFloat(m.group(2)));
       }
    }

    void display(boolean isRed) {
        stroke(255);
        strokeWeight(2);
        if(isRed) fill(255,0,0);
        else fill(0,255,0);
        ellipse(this.pos.x * rJX, this.pos.y * rJY, 2*radius, 2*radius);
  }

}

class Champion{
    final float radius = 24;
    PVector pos, vel;
    float ace;
    float angle, velAng, aceAng;
    int health;
    int stamina;

    Champion(float x, float y ,float vx, float vy, float ace, float angle, float va, float aa, int health, int stamina){
        this.pos    = new PVector(x,y);
        this.vel    = new PVector(vx,vy);
        this.ace    = ace;
        this.angle  = angle; 
        this.velAng = va; 
        this.aceAng = aa;    
        this.health = health;    
        this.stamina= stamina;
    }

    Champion(float x, float y, float angle){
        this.pos = new PVector(x, y);
        this.vel = new PVector(0.0, 0.0);
        this.ace = 0.0;
        this.angle = 0.0;
        this.velAng = 0.0;
        this.aceAng = 0.0;
        this.health = 0;
        this.stamina =0;
    }

    Champion(String s){
        Pattern r = Pattern.compile("\\{([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^\\}]*)\\}");
        Matcher m = r.matcher(s);

        if(m.find()){
            //System.out.println("reconheceu Champion\n");
            this.pos    = new PVector(Float.parseFloat(m.group(1)), Float.parseFloat(m.group(2)));
            this.vel    = new PVector(Float.parseFloat(m.group(3)), Float.parseFloat(m.group(4)));
            this.ace    = Float.parseFloat(m.group(5));
            this.angle  = Float.parseFloat(m.group(6));
            this.velAng = Float.parseFloat(m.group(7));
            this.aceAng = Float.parseFloat(m.group(8));
            this.health = Integer.parseInt(m.group(9));
            this.stamina= Integer.parseInt(m.group(10));
        }
    }

    void display(boolean isFirst){

        if (this == client.gameState.champs[0]) {drawHP(50,50,health,stamina);} else {drawHP(50,150,health,stamina);}

        // vida
        float dx = this.pos.x * rJX;
        float dy = this.pos.y * rJY;
        stroke(255);
        strokeWeight(2);
        fill(127);
        ellipse(dx,dy,2*radius,2*radius);
        fill(255);
        ellipse( sin(this.angle+0.3)*20+dx, cos(this.angle+0.3)*20+dy,20,20);
        ellipse( sin(this.angle-0.3)*20+dx, cos(this.angle-0.3)*20+dy,20,20);
        fill(0);
        ellipse( sin(this.angle+0.3)*20+dx, cos(this.angle+0.3)*20+dy,10,10);
        ellipse( sin(this.angle-0.3)*20+dx, cos(this.angle-0.3)*20+dy,10,10);
    }
}

class GameState{
    Champion[] champs = new Champion[2];
    ArrayList<Berrie> redBerries;
    ArrayList<Berrie> greenBerries;

    GameState(){
        this.champs[0] = new Champion(2,2,90); // 0
        this.champs[1] = new Champion(-2,2,270); // 180
        this.redBerries = new ArrayList<Berrie>();
        this.greenBerries = new ArrayList<Berrie>();
    }

    synchronized void update(String s){
        Pattern r = Pattern.compile("([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*)");
        Matcher m = r.matcher(s);

        if(m.find()){
            //System.out.println("reconheceu gamestate\n");
            this.champs[0] = new Champion(m.group(1));
            this.champs[1] = new Champion(m.group(2));
            this.redBerries = stringToListVagas(m.group(3));
            this.greenBerries = stringToListVagas(m.group(4));
        }
    }

    synchronized void display(){
        boolean isFirst = true;
        for(Champion champ: this.champs){
            champ.display(isFirst);
            isFirst = false;
        }
        for(Berrie rb: redBerries) rb.display(true);
        for(Berrie gb: greenBerries) gb.display(false);
    }


}
