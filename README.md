# RetroAchievements Bot, the project :

This project is mainly a PoC about using the Twitter API, ReroAchievement.org API, and PNG Sprites.  
All of this inside a Docker container for portable purposes.  
Powered up by Kubernetes.  

Actually, as 2.1, it works this way, as soon as you send your RA username to the script via twitter :

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
│   ├── data                          |
│   │   ├── initDB.pl                 |  DB creation if needed
│   │   └── test                      |  
│   │       └── *.pl                  |  Bunch of test scripts
│   ├── lib                           |  
│   │   └── RAB                       |  
│   │       ├── SQL.pm                |  RAB::SQL        to interact with MySQL DB
│   │       ├── Sprites.pm            |  RAB::Sprites    to interact with Imagemagick
│   │       ├── Twitter.pm            |  RAB::Twitter    to check mentions, and reply
│   │       └── RAAPI.pm              |  RAB::RAAPI      to fetch data from RA.org API
│   ├── ra-completion                 |  Main script, the Docker endpoint daemon who does all the work
│   └── sprites                       |  
│       ├── img                       |  Folder where will be located, per user, the generated images
│       ├── src                       |  
│       │   └── *.png                 |  Base PNG used to generate final images
│       └── tmp                       |  Folder used for temporary transformation on sprites
└── kubernetes                        |  
    └── *.yaml                        |  Deployment files
```

### Tech

I used mainy :

* Perl - as a lazy animal
* [Net::Twitter::Lite::WithAPIv1_1;][CPANTwitt] - Easy Twitter API implementation
* [Image::Magick][CPANIM] - PNG creation from layers
* [DBI] - With SQL driver for the DB
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
$ git clone https://github.com/lordslair/ra-completion
$ cd ra-completion/kubernetes
$ kubectl apply -f namespace.yaml
$ kubectl apply -f secrets.yaml
$ kubectl apply -f deployment.yaml
```

This will create :  

```
$ kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
ra-completion-867f8d5464-d8c8p           1/1     Running   0          142m
```

```
$ kubectl logs -f ra-completion-55c96467bd-wrvkv
2021-10-25 17:40:00 Building Perl dependencies and system set-up ...
[...]
OK: 157 MiB in 98 packages
[...]
2021-10-25 17:40:03 Loading done ...
2021-10-25 17:40:03 | =====
2021-10-25 17:40:03 | Starting daemon
2021-10-25 17:40:03 | exec: initDB
2021-10-25 17:40:03 | :o) Entering loop 1
2021-10-25 17:40:03 | [SYSTEM] RAB::SQL::GetTwitterUsers
2021-10-25 17:40:03 | [SYSTEM] RAB::Twitter::getMentions
2021-10-25 17:40:04 | [SYSTEM] RAB::SQL::getMentions
2021-10-25 17:40:04 | [@Lordslair] Got to reply
2021-10-25 17:40:04 | [@Lordslair] Added in DB (867418136341090304,Lordslair)
2021-10-25 17:40:04 | [@Lordslair] Registered on RA (Lordslair), sending ACK Tweet
2021-10-25 17:40:04 | [SYSTEM] RAB::SQL::GetRegisteredUsers DONE
2021-10-25 17:40:05 | [@Lordslair:Lordslair] RAB::RAAPI::GetUserRecentlyPlayedGames(Lordslair) DONE
2021-10-25 17:40:05 | [@Lordslair:Lordslair] RAB::RAAPI::GetUserProgress(Lordslair,@csv) DONE
2021-10-25 17:40:05 | [@Lordslair:Lordslair] RAB::Twitter::SendTweetMedia(...) DONE
2021-10-25 17:45:03 | :o) Entering loop 2
2021-10-25 17:45:03 | [SYSTEM] RAB::SQL::GetTwitterUsers
2021-10-25 17:45:03 | [SYSTEM] RAB::Twitter::getMentions
2021-10-25 17:45:04 | [SYSTEM] RAB::SQL::getMentions
2021-10-25 17:45:04 | [SYSTEM] RAB::SQL::GetRegisteredUsers DONE
2021-10-25 17:45:04 | [@Lordslair:Lordslair] RAB::RAAPI::GetUserRecentlyPlayedGames(Lordslair) DONE
2021-10-25 17:45:04 | [@Lordslair:Lordslair] RAB::RAAPI::GetUserProgress(Lordslair,@csv) DONE
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

   [119-Normal]: <https://raw.githubusercontent.com/lordslair/ra-completion/master/Screenshot-119-Normal.png>
   [6494-Hardcore]: <https://raw.githubusercontent.com/lordslair/ra-completion/master/Screenshot-6494-Hardcore.png>
   [330-Twitter]: <https://raw.githubusercontent.com/lordslair/ra-completion/master/Screenshot-330-Twitter.png>
