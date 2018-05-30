import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.concurrent.ArrayBlockingQueue;



public class Client {
    Socket s;
    BufferedReader in; 
    PrintWriter out;
    Receiver receiver;
    GameState gameState; 

    class Receiver implements Runnable{
        public void run(){
            String gameGameStateString;
            while(true){
                try{
                    gameGameStateString = in.readLine();
                    if( gameGameStateString.equals("end") ){
                        gameState = null;   
                        break;
                    }
                    gameState.update(gameGameStateString);
                }
                catch(Exception e){
                    e.printStackTrace();
                    System.exit(0);
                }
            }
        }
    }

    Client(String ipAddress, int port){
        try{
            Socket s = new Socket(ipAddress, port);
            this.in = new BufferedReader(new InputStreamReader( s.getInputStream()));
            this.out = new PrintWriter(s.getOutputStream(), true);
        }
        catch(Exception e){
            e.printStackTrace();
            System.exit(0);
        }
    }


    public boolean login(String user, String pass){
        boolean ret = false;
        out.println("login " + user + " "+ pass);
        try{ 
            System.out.println("login " + user + " " + pass);
            String line = in.readLine();
            System.out.println(line);
            ret = line.equals("ok"); 
        }
        catch(Exception e){ e.printStackTrace(); System.exit(0); }
        return ret;
    }

    public boolean signin(String user, String pass){
        boolean ret = false;
        out.println("signin " + user + " " + pass);
        try{ 
            System.out.println("signin " + user + " " + pass);
            String line = in.readLine();
            System.out.println(line);
            ret = line.equals("ok"); 
        }
        catch(Exception e){ e.printStackTrace(); System.exit(0); }
        return ret;
    }
    
    public void singout(){
        out.println("logout");
    }

    public boolean play(){
        boolean ret = false;
        try{
            out.println("play");
            System.out.println("play");
            String line = in.readLine();
            System.out.println(line);
            ret = line.equals("ok"); 
            if(ret){
                this.gameState = new GameState();
                new Thread(new Receiver()).start(); 
            }

        }
        catch(Exception e){ e.printStackTrace(); System.exit(0); }
        return ret;
    }

    public void send(int keycode, boolean isPress){
        if(gameState == null) return;
        try{
            String type  = isPress ? "press " : "release ";
            switch (keyCode) {
                case UP:    out.println("$" + type + "up");     break;
                case DOWN:  out.println("$" + type + "down");   break;
                case LEFT:  out.println("$" + type + "left");   break;
                case RIGHT: out.println("$" + type + "right");  break;
                default: break;
            }
        }
        catch(Exception e){
            e.printStackTrace();
            System.exit(0);
        }
    }
}
