import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayVoiceScreen extends StatefulWidget {
  PlayVoiceScreen(this.songUrl);
  var songUrl;

  @override
  State<PlayVoiceScreen> createState() => _PlayVoiceScreenState();
}

class _PlayVoiceScreenState extends State<PlayVoiceScreen> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String? time(Duration duration) {
    String twodigits(int n) => n.toString().padLeft(2, '0');
    final hours = twodigits(duration.inHours);
    final minutes = twodigits(duration.inMinutes.remainder(60));
    final seconds = twodigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  Future setAudio(data) async {
    audioPlayer.setReleaseMode(ReleaseMode.STOP);
    audioPlayer.play(data);
  }

  @override
  void initState() {
    audioPlayer.setReleaseMode(ReleaseMode.STOP);
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    setState(() {
                      final position = Duration(seconds: value.toInt());
                      audioPlayer.seek(position);
                      audioPlayer.resume();
                    });
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(time(position) ?? ''),
                  Text(time(duration) ?? ''),
                ],
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 20,
                child: IconButton(
                  onPressed: () {
                    if (isPlaying) {
                      audioPlayer.pause();
                    } else {
                      setAudio(widget.songUrl);
                    }
                  },
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
