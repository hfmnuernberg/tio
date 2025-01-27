// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.7.1.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `on_audio_callback`, `pitch_shift`, `thread_handle_command`
// These types are ignored because they are not used by any `pub` functions: `AudioProcessingData`, `PROCESSING_DATA`, `RING_CONSUMER`, `SOURCE_DATA`, `THREAD_DATA`, `ThreadData`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `deref`, `deref`, `deref`, `deref`, `initialize`, `initialize`, `initialize`, `initialize`
// These functions are ignored (category: IgnoreBecauseExplicitAttribute): `media_player_compute_rms`, `media_player_create_stream`, `media_player_query_state`, `media_player_set_buffer`, `media_player_set_loop_value`, `media_player_set_new_volume`, `media_player_set_pitch`, `media_player_set_pos_factor`, `media_player_set_speed`, `media_player_set_trim_by_factor`, `media_player_trigger_destroy_stream`

class MediaPlayerState {
  final bool playing;
  final double playbackPositionFactor;
  final double totalLengthSeconds;
  final bool looping;
  final double trimStartFactor;
  final double trimEndFactor;

  const MediaPlayerState({
    required this.playing,
    required this.playbackPositionFactor,
    required this.totalLengthSeconds,
    required this.looping,
    required this.trimStartFactor,
    required this.trimEndFactor,
  });

  @override
  int get hashCode =>
      playing.hashCode ^
      playbackPositionFactor.hashCode ^
      totalLengthSeconds.hashCode ^
      looping.hashCode ^
      trimStartFactor.hashCode ^
      trimEndFactor.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaPlayerState &&
          runtimeType == other.runtimeType &&
          playing == other.playing &&
          playbackPositionFactor == other.playbackPositionFactor &&
          totalLengthSeconds == other.totalLengthSeconds &&
          looping == other.looping &&
          trimStartFactor == other.trimStartFactor &&
          trimEndFactor == other.trimEndFactor;
}
