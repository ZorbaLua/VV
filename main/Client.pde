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
    Receiver receiver = new Receiver();
    Sender sender = new Sender();

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
                    System.out.println("R :" + gameGameStateString);
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
                        System.out.println("S :" + key);
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
                switch (keycode) {
                    case UP:    this.buf.put(type + "front");     break;
                    case LEFT:  this.buf.put(type + "left");   break;
                    case RIGHT: this.buf.put(type + "right");  break;
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
        out.println("2");
        out.println(user);
        out.println(pass);
        try{ String a = in.readLine(); ret = a.equals("ok"); System.out.println(a);}
        catch(Exception e){ e.printStackTrace(); System.exit(0); }
        return ret;
    }

    public boolean singin(String user, String pass){
        boolean ret = false;
        out.println("1");
        out.println(user);
        out.println(pass);
        try{ String a = in.readLine(); ret = a.equals("ok"); System.out.println(a);}
        catch(Exception e){ e.printStackTrace(); System.exit(0); }
        return ret;
    }
    
    public void singout(){
        out.println("logout");
    }
    
    public ArrayList<String> reload_rank(){
        ArrayList<String> res = new ArrayList<String>();
        out.println("top3");
        try{
            String a = in.readLine();
            System.out.println(a);
            int quant = Integer.parseInt(a);
            for(int i = 0; i<quant; i++){
                res.add(in.readLine());
            }
        }catch(Exception e){
            e.printStackTrace();
            System.exit(0);
        }
        return res;
    }

    public boolean play(){
        boolean ret = false;
        try{
            out.println("play");
            ret = in.readLine().equals("ok");
            if(ret){
                System.out.println("Correu bem\n");
                this.receiver = new Receiver();
                new Thread(this.receiver).start();
                this.sender = new Sender();
                new Thread(this.sender).start();
            }
        }
        catch(Exception e){ e.printStackTrace(); System.exit(0); }
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
