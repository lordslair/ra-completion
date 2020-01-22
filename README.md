# RetroAchievements Bot, the project :

This project is mainly a PoC about using the Twitter API, ReroAchievement.org API, and PNG Sprites.  
All of this inside a Docker container for portable purposes.  
Powered up by Kubernetes.  

Actually, as 2.0, it works this way, as soon as you send your RA username to the script via twitter :

 - Fetch Scores, Games recently played, and Achievements RA.org
 - Sort the data and find if you completed a game (100% of achievements)
 - Fetch the Game Icon fom RA.org, and convert it in 64x64
 - Compose the final image by adding PNG layers
 - Reply to your tweet with the PNG as media

### Which script does what ?

```
.
├── code                              |
│   ├── data                          |
│   │   ├── initDB.pl                 |  DB creation if needed
│   │   └── test                      |  
│   │       └── *.pl                  |  Bunch of test scripts
│   ├── lib                           |  
│   │   └── RAB                       |  
│   │       ├── SQLite.pm             |  RAB::SQLite     to interact with SQL3 DB
│   │       ├── Twitter.pm            |  RAB::Twitter    to check mentions, and reply
│   │       └── RAAPI.pm              |  RAB::RAAPI      to fetch data from RA.org API
│   ├── ra-completion                 |  Main script, the Docker endpoint daemon who does all the work
│   └── sprites                       |  
│       ├── img                       |  Folder where will be located, per user, the generated images
│       ├── src                       |  
│       │   └── *.png                 |  Base PNG used to generate final images
│       └── tmp                       |  Folder used for temporary transformation on sprites
└── kubernetes                        |  
    ├── deployment-*.yaml             |  Pods deployment files
    └── volume-*.yaml                 |  Volumes deployment files
```

### Tech

I used mainy :

* Perl - as a lazy animal
* [Net::Twitter::Lite::WithAPIv1_1;][CPANTwitt] - Easy Twitter API implementation
* [Image::Magick][CPANIM] - PNG creation from layers
* [DBI] - With SQLite driver for the DB
* [JSON] - Make the output from RA.org usable in the script
* [docker/docker-ce][docker] to make it easy to maintain
* [Alpine][alpine] - probably the best/lighter base container to work with
* [Daemon exemple script][daemon] - gobland-it Perl daemon is based on this (Kudos)

And of course GitHub to store all these shenanigans. 

### Installation

The core and its dependencies are meant to run in a Docker/k8s environment.  
Could work without it, but more practical to maintain this way.  
  
Every part is kept in a different k8s file separately for more details.  
  
```
$ git clone https://github.com/lordslair/ra_bot
$ cd ra_bot/kubernetes
$ kubectl apply -f volume-code-perl.yaml
$ kubectl apply -f deployment-perl.yaml
```

This will create :  

- The pod : ra-completion

```
$ kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
ra-completion-867f8d5464-d8c8p           1/1     Running   0          142m
```

- The volume : code-perl

```
$ kubectl get pvc
NAME                     STATUS   VOLUME                   CAPACITY   [...]
ra-completion-code-perl  Bound    pvc-[...]-5e59fec92f65   1Gi        [...]
```

```
$ kubectl logs -f ra-completion-55c96467bd-wrvkv
2020-01-22 22:45:12 Building Perl dependencies and system set-up ...
[...]
OK: 138 MiB in 92 packages
[...]
2020-01-22 23:49:33 Build done ...
2020-01-22 23:49:33 | =====
2020-01-22 23:49:33 | Starting daemon
2020-01-22 23:49:33 | exec: initDB
2017-08-31 15:23:43 | :o) Entering loop 1
2017-08-31 15:24:45 | Got a not yet replied mention from @Lordslair (@ra_completion !Lordslair)
2017-08-31 15:24:45 | [@Lordslair] Got to reply
2017-08-31 15:24:45 | [@Lordslair] Added in DB (440766852,Lordslair)
2017-08-31 15:24:45 | [@Lordslair] Registered on RA (Lordslair), sending ACK Tweet
2017-08-31 15:24:46 | [@Lordslair:Lordslair]   Marked this game (113:Hellfire:normal) as DONE in DB
2017-08-31 15:24:46 | [@Lordslair:Lordslair]     Sending tweet about this
2017-08-31 15:24:47 | [@Lordslair:Lordslair]     /code/sprites/img/Lordslair/113.png
2017-08-31 15:24:47 | [@Lordslair:Lordslair]   Marked this game (330:Gynoug:normal) as DONE in DB
2017-08-31 15:24:47 | [@Lordslair:Lordslair]     Sending tweet about this
2017-08-31 15:24:48 | [@Lordslair:Lordslair]     /code/sprites/img/Lordslair/330.png
```

#### Disclaimer/Reminder

>There's proably **NULL** interest for anyone to clone it and run the project this way, though.  
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
   [CPANTwitt]: <http://search.cpan.org/~mmims/Net-Twitter-Lite-0.12008/lib/Net/Twitter/Lite/WithAPIv1_1.pod>
   [CPANIM]: <http://search.cpan.org/~jcristy/PerlMagick-6.89-1/Magick.pm>
   [daemon]: <http://www.andrewault.net/2010/05/27/creating-a-perl-daemon-in-ubuntu/>
   [docker]: <https://github.com/docker/docker-ce>
   [alpine]: <https://github.com/alpinelinux>

   [119-Normal]: <https://raw.githubusercontent.com/lordslair/ra_bot/master/Screenshot-119-Normal.png>
   [6494-Hardcore]: <https://raw.githubusercontent.com/lordslair/ra_bot/master/Screenshot-6494-Hardcore.png>
   [330-Twitter]: <https://raw.githubusercontent.com/lordslair/ra_bot/master/Screenshot-330-Twitter.png>
