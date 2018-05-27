import java.util.concurrent.ArrayBlockingQueue;

class Receiver implements Runnable{
    BufferedReader in; 
    ArrayBlockingQueue buf;

	public Receiver (Socket s, ArrayBlockingQueue buffer){
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
                String gameStateString = in.readLine();
                buf.put(new State(gameStateString));
            }catch(Exception e){
                e.printStackTrace();
                System.exit(0);
            }
        }
	}
}

class Sender implements Runnable{
    PrintWriter out;
    ArrayBlockingQueue buf;

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
                State st;
                while(st = buf.take()){
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
    Client(String ip_address, int port, ArrayBlockingQueue bufferRec, ArrayBlockingQueue bufferSend){
        try{
            Socket s = new Socket(host, port);
            new Thread(new Receiver(s, bufferRec)).start();
            new Thread(new Sender(s, bufferSend)).start();
        }catch(Exception e){
            e.printStackTrace();
            System.exit(0);
        }
    }
}
