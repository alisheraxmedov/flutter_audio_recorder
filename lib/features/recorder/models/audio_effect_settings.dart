/// Audio effect preset types
enum AudioPreset {
  none,
  podcast,
  clearVoice,
}

/// Settings for audio effects batch processing
class AudioEffectSettings {
  final double speed;
  final double pitch;
  final bool normalize;
  final bool trimSilence;
  final bool noiseGate;
  final AudioPreset preset;

  const AudioEffectSettings({
    this.speed = 1.0,
    this.pitch = 1.0,
    this.normalize = false,
    this.trimSilence = false,
    this.noiseGate = false,
    this.preset = AudioPreset.none,
  });

  /// Check if any effect is enabled
  bool get hasActiveEffects =>
      speed != 1.0 ||
      pitch != 1.0 ||
      normalize ||
      trimSilence ||
      noiseGate ||
      preset != AudioPreset.none;

  /// Build FFmpeg filter_complex string
  /// [sampleRate] - original audio sample rate for pitch calculation
  String buildFilterString(int sampleRate) {
    final filters = <String>[];

    // 1. Preset filters first (they set a baseline)
    switch (preset) {
      case AudioPreset.podcast:
        filters.add('highpass=f=80');
        filters.add('lowpass=f=12000');
        filters.add('afftdn=nf=-20');
        filters.add('loudnorm');
        break;
      case AudioPreset.clearVoice:
        filters.add('highpass=f=100');
        filters.add('acompressor=threshold=-20dB:ratio=4:attack=5:release=50');
        filters.add('loudnorm');
        break;
      case AudioPreset.none:
        break;
    }

    // 2. Speed change (atempo: 0.5-2.0, chain for higher/lower)
    if (speed != 1.0) {
      final atempoFilters = _buildAtempoChain(speed);
      filters.addAll(atempoFilters);
    }

    // 3. Pitch change (using asetrate + atempo to compensate)
    if (pitch != 1.0) {
      // asetrate changes pitch but also speed, so we compensate with atempo
      final newRate = (sampleRate * pitch).round();
      filters.add('asetrate=$newRate');
      filters.add('aresample=$sampleRate'); // Resample back to original rate
      // Compensate speed change caused by pitch
      final atempoCompensation = _buildAtempoChain(1.0 / pitch);
      filters.addAll(atempoCompensation);
    }

    // 4. Silence trimming
    if (trimSilence) {
      // Remove silence from start and end
      filters.add(
        'silenceremove=start_periods=1:start_silence=0.5:start_threshold=-50dB',
      );
      filters.add('areverse');
      filters.add(
        'silenceremove=start_periods=1:start_silence=0.5:start_threshold=-50dB',
      );
      filters.add('areverse');
    }

    // 5. Noise gate
    if (noiseGate) {
      filters.add('afftdn=nf=-25');
    }

    // 6. Normalize (should be last for best results)
    if (normalize && preset == AudioPreset.none) {
      // Skip if preset already includes loudnorm
      filters.add('loudnorm');
    }

    return filters.join(',');
  }

  /// Build atempo chain for speeds outside 0.5-2.0 range
  List<String> _buildAtempoChain(double targetSpeed) {
    final filters = <String>[];
    var remaining = targetSpeed;

    if (remaining > 1.0) {
      // Speed up: max 2.0 per filter
      while (remaining > 2.0) {
        filters.add('atempo=2.0');
        remaining /= 2.0;
      }
      if (remaining > 1.0) {
        filters.add('atempo=$remaining');
      }
    } else if (remaining < 1.0) {
      // Slow down: min 0.5 per filter
      while (remaining < 0.5) {
        filters.add('atempo=0.5');
        remaining /= 0.5;
      }
      if (remaining < 1.0) {
        filters.add('atempo=$remaining');
      }
    }

    return filters;
  }

  AudioEffectSettings copyWith({
    double? speed,
    double? pitch,
    bool? normalize,
    bool? trimSilence,
    bool? noiseGate,
    AudioPreset? preset,
  }) {
    return AudioEffectSettings(
      speed: speed ?? this.speed,
      pitch: pitch ?? this.pitch,
      normalize: normalize ?? this.normalize,
      trimSilence: trimSilence ?? this.trimSilence,
      noiseGate: noiseGate ?? this.noiseGate,
      preset: preset ?? this.preset,
    );
  }
}
