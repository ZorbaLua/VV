import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.concurrent.ArrayBlockingQueue;


class Receiver implements Runnable{
    BufferedReader in; 
    ArrayBlockingQueue<GameState> buf;

	public Receiver (Socket s, ArrayBlockingQueue<GameState> buffer){
        this.buf = buffer;
        try{
            this.in = new BufferedReader(new InputStreamReader( s.getInputStream()));
        }catch(Exception e){
            e.printStackTrace();
            System.exit(0);
        }
	}
	public void run(){
        while(true){
            try{
                String gameGameStateString = in.readLine();
                buf.put(new GameState(gameGameStateString));
            }catch(Exception e){
                e.printStackTrace();
                System.exit(0);
            }
        }
	}
}

class Sender implements Runnable{
    PrintWriter out;
    ArrayBlockingQueue<GameState> buf;

	public Sender(Socket s, ArrayBlockingQueue<GameState> buffer){
        try{
            this.out = new PrintWriter(s.getOutputStream(), true);
        }catch(Exception e){
            e.printStackTrace();
            System.exit(0);
        }
	}

	public void run(){
        while(true){
            try{
                GameState st;
                while(true){
                    st = buf.take();
                    out.println(st.toString()); 
                }
            }catch(Exception e){
                e.printStackTrace();
                System.exit(0);
            }
        }
	}
}

public class Client {
    private final int BUFFCAP = 20;
    ArrayBlockingQueue<GameState> sender;
    ArrayBlockingQueue<GameState> receiver;

    Client(String ipAddress, int port){
        this.sender = new ArrayBlockingQueue<GameState>(BUFFCAP);
        this.receiver = new ArrayBlockingQueue<GameState>(BUFFCAP);
        try{
            Socket s = new Socket(ipAddress, port);
            new Thread(new Receiver(s, receiver)).start();
            new Thread(new Sender(s, sender)).start();
        }catch(Exception e){
            e.printStackTrace();
            System.exit(0);
        }
    }
}
