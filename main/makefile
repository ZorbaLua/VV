COMP=javac

all: Client GameState
	jar cvfe Client.jar *.class


Client: Client.java
	$(COMP) Client.java 

GameState: GameState.java
	$(COMP) GameState.java 




clean: 
	rm -f *.class *.jar
