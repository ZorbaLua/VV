import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.concurrent.ArrayBlockingQueue;

public class Client {
    private final int BUFFCAP = 20;
    Socket s;
    BufferedReader in; 
    PrintWriter out;
    Receiver receiver;
    Sender sender;

    public class Receiver implements Runnable{
        public ArrayBlockingQueue<GameState> buf;

        public Receiver(){
            this.buf = new ArrayBlockingQueue<GameState>(BUFFCAP);
        }

        public void run(){
            while(true){
                try{
                    String gameGameStateString = in.readLine();
                    buf.put(new GameState(gameGameStateString));
                }
                catch(Exception e){
                    e.printStackTrace();
                    System.exit(0);
                }
            }
	    }
    }

    public class Sender implements Runnable{
        public ArrayBlockingQueue<String> buf;

        public Sender(){
            this.buf = new ArrayBlockingQueue<String>(BUFFCAP);
        }

        public void run(){
            while(true){
                try{
                    String key;
                    while(true){
                        key = buf.take();
                        out.println(key); 
                    }
                }
                catch(Exception e){
                    e.printStackTrace();
                    System.exit(0);
                }
            }
        }
        public void send(int keycode, boolean isPress){
            try{
                String type  = isPress ? "press " : "release ";
                switch (keyCode) {
                    case UP:    this.buf.put("$" + type + "up");     break;
                    case DOWN:  this.buf.put("$" + type + "down");   break;
                    case LEFT:  this.buf.put("$" + type + "left");   break;
                    case RIGHT: this.buf.put("$" + type + "right");  break;
                    default: break;
                }
            }
            catch(Exception e){
                e.printStackTrace();
                System.exit(0);
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

    public boolean singin(String user, String pass){
        boolean ret = false;
        out.println("signin " + user + " " + pass);
        try{ 
            System.out.println("singin " + user + " " + pass);
            String line = in.readLine();
            System.out.println(line);
            ret = line.equals("ok"); 
        }
        catch(Exception e){ e.printStackTrace(); System.exit(0); }
        return ret;
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
                this.receiver = new Receiver();
                new Thread(this.receiver).start();
                this.sender = new Sender();
                new Thread(this.sender).start();
            }
        }
        catch(Exception e){ System.out.println("Estou aqui so para  ti"); e.printStackTrace(); System.exit(0); }
        return ret;
    }

    public void send(int keycode, boolean isPress){
        if(this.sender != null) this.sender.send(keycode, isPress);
    }

    public GameState getState(){
        GameState ret=null;
        try{ ret = this.receiver.buf.take(); }
        catch(Exception e){ e.printStackTrace(); System.exit(0); }
        return ret;
    }
}
