import 'package:flutter/material.dart';
import 'package:patta/ui/common_widgets/pariyatti_icons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:patta/ui/themes/app_themes.dart';

class AudioButton extends StatefulWidget {
  final Uri? audioUrl;

  AudioButton({this.audioUrl, Key? key}) : super(key: key);

  @override
  _AudioButtonState createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> {
  final _player = AudioPlayer();

  @override
  void initState() {
    initStreamListen();
    initAudioSource();
    super.initState();
  }

  void initStreamListen() {
    _player.playbackEventStream.listen((event) {},
      onError: (Object e, StackTrace stackTrace) {
        print('A stream error occurred: $e');
      }
    );
  }

  Future<void> initAudioSource() async {
    // Try to load audio from a source and catch any errors.
    try {
      await _player.setAudioSource(AudioSource.uri(widget.audioUrl!));
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Center(
                child: Container(
                  margin: EdgeInsets.zero,
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(color: Color.fromARGB(255, 186, 86, 38)),
              ));
            } else if (playing != true) {
              return MaterialButton(
                padding: EdgeInsets.zero,
                child: Icon(PariyattiIcons.get(IconName.play), color: Theme.of(context).colorScheme.onSecondary),
                onPressed: _player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return MaterialButton(
                padding: EdgeInsets.zero,
                child: Icon(PariyattiIcons.get(IconName.pause), color: Theme.of(context).colorScheme.onSecondary),
                onPressed: _player.pause,
              );
            } else {
              return MaterialButton(
                padding: EdgeInsets.zero,
                child: Icon(PariyattiIcons.get(IconName.play), color: Theme.of(context).colorScheme.onSecondary),
                onPressed: play,
              );
            }
          }
        )
    );
  }

  void play() {
    _player.seek(Duration.zero); // needed in case the audio has played once
    setState(() { _player.play(); });
  }

  void stop() {
    setState(() { _player.stop(); });
    _player.seek(Duration.zero);
  }
}