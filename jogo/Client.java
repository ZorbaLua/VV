import java.io.*;
import java.net.*;
import java.util.Scanner;

class Receiver extends Thread {
	BufferedReader in; 
	public Receiver (Socket s){
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
                String res = in.readLine();
                System.out.println(res);
                System.out.flush();
            }catch(Exception e){
                e.printStackTrace();
                System.exit(0);
            }
        }
	}
}

class Sender extends Thread {
    PrintWriter out;
    Scanner sc;
	public Sender (Socket s){
        try{
            this.out = new PrintWriter(s.getOutputStream());
        }catch(Exception e){
            e.printStackTrace();
            System.exit(0);
        }
        this.sc = new Scanner(System.in);
	}
	public void run(){
        while(true){
            try{
                while(sc.hasNextLine()){
                    out.println(sc.nextLine());
                    out.flush();
                }
            }catch(Exception e){
                e.printStackTrace();
                System.exit(0);
            }
        }
	}
}

public class Client {
    public static void main(String[] args) {
        try{
            if(args.length<2)
                System.exit(1);
            String host = args[0];
            int port = Integer.parseInt(args[1]);
            Socket s = new Socket(host, port);
            Receiver re = new Receiver(s);
            Sender se = new Sender(s);
            se.start();
            re.start();
            se.join();
            re.join();
        }catch(Exception e){
            e.printStackTrace();
            System.exit(0);
        }
    }
}
