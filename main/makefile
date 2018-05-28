COMP=javac
CP=/Applications/Processing.app/Contents/Java/core/library/core.jar

all: Client 
	jar cvfe Client.jar *.class


Client: Client.java
	$(COMP) -cp $(CP) GameState.java Client.java 

#GameState: GameState.java
#	$(COMP) -cp $(CP) GameState.java 




clean: 
	rm -f *.class *.jar
