# Scrabble mobile and desktop app

## About
This is a continuation of the web app version of the popular board game Scrabble created in the context of an academic project (see https://github.com/lt101/scrabble-web-app for details). This version includes a multiplayer desktop app built with Electron.js and a mobile app written in Flutter. It implements Socket.io for client-server communication and a REST API for persistance with a MongoDB database.

## How To Use
Before running the application, run the `npm install` script in the *client_web* and *server* directories, as well as *flutter pub get* in *client_mobile* to install necessary dependencies.

- Desktop app:
    - To build the executable desktop app, run the `npm run build` script in the *client_web* directory. The executable file named *client-lourd* will be found in client_web > build > client-lourd-win32-x64.
    - To run the desktop app without building an executable file, run the `npm start` script in the *client_web* directory.
    - To run the web version of the app, run the `ng serve` script in the *client_web* directory. The client will run on **http://localhost:4200/**.
    
- Mobile app:
    - Download and open the scrabble-mobile.apk file.
    - If you have an Android emulator, you can run the app on the emulator by running the main.dart file in client_mobile > lib.
    
## Login and user profile
You need to create an account to use the app. If you already have an account, type in your email address and password and click on *Se connecter*. If not, click on *Pas de compte? Inscrivez-vous* to create an account. Enter an email address (it doesn't have to exist but must respect a valid email format such as example@gmail.com), a username and a password. Whe you are done, click on *S'inscrire*. Back in the login page, type in your email address and password and click on *Se connecter*. Welcome to Scrabble!

**Note**: For demo purposes, you may want to open the app multiple times to simulate a multiplayer experience.

## Settings
The in-game language is set to French by default. To change the language to English, click on the cog icon to access the settings. Here, you can choose the language and the theme (dark or light).

## Game modes
- Classic: This is the classic Scrabble game. Please refer to the official rules to see how it is played.
- Objectives: This is the Scrabble game with a twist. There are 4 objectives to be completed, each rewarding a certain number of points depending on its difficulty. Once an objective is completed, other players may no longer complete it.

## Game visibility
- Private: The host can choose to accept or reject players wanting to join the game. 
- Public: Anyone can join a public game, but they must enter the password that was set by the host. Once started, public games can be observed by players.

## Gameplay
To start a classic Scrabble game, click on *Classic Scrabble*, then *Create a game*. Set the game paramters (Timer, Dictionary and Visibility). When you are ready, confirm the settings and create the game. The version currently only has a beginner level, so choose *Débutant*. Click on *Initialiser La Partie* when you are ready to start the game and wait for a player to join the game.
To join a classic Scrabble game, click on *Classic Scrabble*, then *Join a game*. You will see a list of available games filtered by their visibility. 

Each turn, the player can either place letters to form a word, exchange letters or pass the turn.
**Note**: The first word has to touch the H8 tile.

Players may also ask for a hints by clicking on the light bulb icon.

The game ends when a player has used all of his letters AND the reserve is empty, OR when each player passes 3 turns in a row.

## Chatting
Players can chat with other players at all times in the General chat. During a game, they can chat with the other players in the Party chat. Apart from text messages, players can send GIFs, emojis, and even upload pdf and .txt files! 


# Development details

## Desktop app
The desktop app is written with Angular in Typescript. Navigation between pages in done using the Angular Router. Game parameters (username, length of each turn) are set in an Angular Form using Validators. The game board itself is created with Canvas API. Electron.js was used to create a desktop app version of the web app.

## Mobile app
The mobile app is created with Flutter in Dart. 

## Server
The server is an Express server. It implements Socket.io to handle client requests and allow real-time chatting between users. It communicates with a MongoDB database using a REST API.  

