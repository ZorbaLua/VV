lsof -i :12345 | awk '{if(NR==2) print $2}' | xargs kill -9

