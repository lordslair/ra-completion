# RetroAchievements Bot, the project :

This project is mainly a PoC about using the Twitter API, ReroAchievement.org API, and PNG Sprites.  
All of this inside a Docker container for portable purposes.  
Powered up by Kubernetes.  

Actually, as 3.0, it works this way, as soon as you send your RA username to the script via twitter :

 - Fetch Scores, Games recently played, and Achievements RA.org
 - Sort the data and find if you completed a game (100% of achievements)
 - Store information in remote MySQL DB to limit Twitter/RA.org API calls
 - Fetch the Game Icon fom RA.org, and convert it in 64x64
 - Compose the final image by adding PNG layers
 - Reply to your tweet with the PNG as media

### Which script does what ?

```
.
├── code                              |
│   ├── mysql                         | MySQL connector, models and methods
│   ├── ra-completion.py              |  Main script, the Docker endpoint daemon who does all the work
│   ├── raapi.py                      |  module to handle RA.org API
│   ├── sprites.py                    |  module to handle Imagemagick/wand/PIL jobs
│   └── sprites                       |  
│       ├── generated                 |  Folder where will be located the generated images
│       ├── base                      |  
│       │   └── *.png                 |  Base PNG used to generate final images
│       └── icon                      |  Folder used for icon transformation to 64x64
└── k8s-deployment.yaml               |  Deployment file
```

### Tech

I used mainy :

* Python - starting in 3.0 release (Perl before)
* Tweepy - Easy Twitter API implementation
* Wand/PIL - PNG creation from layers
* SQLAlchemy - With SQL driver for the DB
* [docker/docker-ce][docker] to make it easy to maintain
* [Alpine][alpine] - probably the best/lighter base container to work with

And of course GitHub to store all these shenanigans.

### Installation

The core and its dependencies are meant to run in a Docker/k8s environment.  
Could work without it, but more practical to maintain this way.  

Every part is kept in a different k8s file separately for more details.  

```
$ git clone https://github.com/lordslair/ra-completion
$ kubectl apply -f k8s-deployment.yaml
```

This will create :  

```
$ kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
ra-completion-867f8d5464-d8c8p           1/1     Running   0          142m
```

```
$ kubectl logs -f ra-completion-55c96467bd-wrvkv
2022-05-16 16:28:55 | level=INFO     | mysql.initialize:initialize_db:11 - MySQL init: start
2022-05-16 16:28:55 | level=INFO     | mysql.initialize:initialize_db:16 - MySQL init: OK
2022-05-16 16:28:55 | level=INFO     | mysql.initialize:initialize_db:18 - MySQL init: end
2022-05-16 16:28:55 | level=INFO     | __main__:check_mentions:18 - Retrieving mentions
[...]
2022-05-16 16:28:55 | level=DEBUG    | mysql.methods:db_user_get_all:66 - Users Query OK
2022-05-16 16:28:56 | level=DEBUG    | __main__:check_ra_updates:116 - [Lordslair] Game already in DB : [5108] Bomberman Quest (HC:False)
2022-05-16 16:28:56 | level=DEBUG    | __main__:check_ra_updates:116 - [Lordslair] Game already in DB : [1586] Bomberman II (HC:False)
[...]
2022-05-16 16:28:56 | level=INFO     | __main__:check_ra_updates:118 - [Lordslair] Game entry creation TODO ([113] Hellfire)
2022-05-16 16:28:56 | level=INFO     | __main__:check_ra_updates:129 - [Lordslair] Game Icon fetching OK
2022-05-16 16:28:56 | level=INFO     | __main__:check_ra_updates:141 - [Lordslair] Game Score fetching OK
2022-05-16 16:28:57 | level=INFO     | __main__:check_ra_updates:153 - [Lordslair] Game Image creation OK
2022-05-16 16:28:57 | level=INFO     | __main__:check_ra_updates:162 - Tweeting: @Lordslair Kudos. with 9/9 Achievements unlocked, you completed Hellfire (Mega Drive)[113] !
2022-05-16 16:28:57 | level=INFO     | __main__:check_ra_updates:170 - [Lordslair] Kudos send OK (@Lordslair)
2022-05-16 16:28:57 | level=INFO     | __main__:check_ra_updates:178 - [Lordslair] Game entry creation OK
2022-05-16 16:28:57 | level=INFO     | __main__:main:194 - Waiting...
```

#### Disclaimer/Reminder

>There's probably **NULL** interest for anyone to clone it and run the project this way, though.  
>(It's currently hardcoded to use @ra_completion Twitter account I registered)  
>I put the code here mostly for reminder, and to help anyone if they find parts of it useful for their own dev.

### Result

These are the PNG generated and sent, respectfully in Normal and Hardcore mode.  
![119][119-Normal]
![6494][6494-Hardcore]  

And here is the result when sent to Twitter.  
![330][330-Twitter]

### Todos

 - Different backgrounds for softcore/HARDCORE

---
   [docker]: <https://github.com/docker/docker-ce>
   [alpine]: <https://github.com/alpinelinux>

   [119-Normal]: <https://raw.githubusercontent.com/lordslair/ra-completion/master/Screenshot-119-Normal.png>
   [6494-Hardcore]: <https://raw.githubusercontent.com/lordslair/ra-completion/master/Screenshot-6494-Hardcore.png>
   [330-Twitter]: <https://raw.githubusercontent.com/lordslair/ra-completion/master/Screenshot-330-Twitter.png>
