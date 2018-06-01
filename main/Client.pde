
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
        catch(Exception e){ showMessageDialog(null, "Erro Login Falhado", "Erro Login Falhado",ERROR_MESSAGE); e.printStackTrace(); System.exit(0); }
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

    public void logout(){
        out.println("logout");
        System.out.println("logout");
    }

    public String[] top3level() {
        String[] topPlayers = new String[0];
        try{
            out.println("top3level");
            System.out.println("top3level");
            String line = in.readLine();
            topPlayers = line.split(" ");
            //System.out.println(topPlayers[1]);
        }
        catch(Exception e){ e.printStackTrace(); System.exit(0); }
        return topPlayers;
    }


    public String[] info() {
        String[] info = new String[0];
        try{
            out.println("info");
            System.out.println("info");
            String line = in.readLine();
            info = line.split(" ");
            //System.out.println(info[1]);
        }
        catch(Exception e){ e.printStackTrace(); System.exit(0); }
        return info;
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

    public void send(int keycode, String type){
        if(gameState == null) return;
        try{
            switch (keyCode) {
                case UP:    out.println(type + "up");     break;
                case DOWN:  out.println(type + "down");   break;
                case LEFT:  out.println(type + "left");   break;
                case RIGHT: out.println(type + "right");  break;
                default: break;
            }
        }
        catch(Exception e){
            e.printStackTrace();
            System.exit(0);
        }
    }
}
