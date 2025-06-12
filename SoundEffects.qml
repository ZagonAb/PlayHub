import QtQuick 2.15
import QtMultimedia 5.8

Item {
    id: root

    SoundEffect {
        id: naviSound
        source: "assets/audio/choose.wav"
        volume: 0.8
    }

    SoundEffect {
        id: backSound
        source: "assets/audio/back.wav"
        volume: 0.5
    }

    SoundEffect {
        id: goSound
        source: "assets/audio/go.wav"
        volume: 0.5
    }

    SoundEffect {
        id: launchSound
        source: "assets/audio/launch.wav"
        volume: 1.0
    }

    SoundEffect {
        id: favSound
        source: "assets/audio/Fav.wav"
        volume: 0.7
    }

    function play(soundName) {
        switch(soundName) {
            case "navi": naviSound.play(); break;
            case "back": backSound.play(); break;
            case "go": goSound.play(); break;
            case "launch": launchSound.play(); break;
            case "fav": favSound.play(); break;
        }
    }
}
