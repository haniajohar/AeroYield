// =============================================================================
// AeroYield — Voice Assistant Modal
//
// Speech recognition is optional device capability. Farmers can always type a
// question if permission is denied or a language pack is unavailable.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../constants/app_l10n.dart';
import '../models/farm_data.dart';
import '../services/farm_voice_assistant.dart';
import 'helpline_modal.dart';

Future<void> showVoiceAssistantModal(
  BuildContext context, {
  required FarmData farm,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _VoiceAssistantSheet(farm: farm),
  );
}

class _VoiceAssistantSheet extends StatefulWidget {
  final FarmData farm;

  const _VoiceAssistantSheet({required this.farm});

  @override
  State<_VoiceAssistantSheet> createState() => _VoiceAssistantSheetState();
}

class _VoiceAssistantSheetState extends State<_VoiceAssistantSheet>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _typedQuestion = TextEditingController();
  late final AnimationController _pulseController;

  bool _isListening = false;
  bool _speechAvailable = true;
  String _transcript = '';
  VoiceReply? _reply;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseController.dispose();
    _typedQuestion.dispose();
    super.dispose();
  }

  bool get _isUrdu => Localizations.localeOf(context).languageCode == 'ur';

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _speechAvailable = false;
        });
      },
    );
    if (!available) {
      if (mounted) setState(() => _speechAvailable = false);
      return;
    }

    final locales = await _speech.locales();
    final preferredLocale = _preferredLocaleId(locales);
    if (mounted) {
      setState(() {
        _speechAvailable = true;
        _isListening = true;
        _reply = null;
      });
    }
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _transcript = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _answer(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: preferredLocale,
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  String? _preferredLocaleId(List<LocaleName> locales) {
    if (!_isUrdu) {
      return locales
          .where((locale) => locale.localeId.toLowerCase().startsWith('en'))
          .map((locale) => locale.localeId)
          .cast<String?>()
          .firstOrNull;
    }
    return locales
        .where((locale) => locale.localeId.toLowerCase().startsWith('ur'))
        .map((locale) => locale.localeId)
        .cast<String?>()
        .firstOrNull;
  }

  void _answer(String question) {
    final cleaned = question.trim();
    if (cleaned.isEmpty) return;
    _typedQuestion.text = cleaned;
    setState(() {
      _transcript = cleaned;
      _isListening = false;
      _reply = FarmVoiceAssistant.answer(
        farm: widget.farm,
        question: cleaned,
        isUrdu: _isUrdu,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isUrdu ? 'اپنے کھیت سے سوال کریں' : 'Ask about your field',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = _isListening
                        ? 1.0 + _pulseController.value * 0.18
                        : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Semantics(
                        button: true,
                        label: _isListening
                            ? (_isUrdu ? 'سننا بند کریں' : 'Stop listening')
                            : (_isUrdu
                                  ? 'بولنے کے لیے مائیک دبائیں'
                                  : 'Tap microphone to speak'),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _toggleListening,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isListening
                                  ? theme.colorScheme.error
                                  : primary,
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withAlpha(64),
                                  blurRadius: 18,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.stop : Icons.mic,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  _isListening
                      ? l10n.voiceListening
                      : (_speechAvailable
                            ? l10n.voicePrompt
                            : (_isUrdu
                                  ? 'مائیک دستیاب نہیں، سوال لکھیں۔'
                                  : 'Microphone unavailable—type your question.')),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                if (_transcript.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    '“$_transcript”',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _typedQuestion,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _answer,
                  decoration: InputDecoration(
                    labelText: _isUrdu ? 'سوال لکھیں' : 'Type a question',
                    hintText: _isUrdu
                        ? 'مثلاً: میری فصل کی صحت کیسی ہے؟'
                        : 'For example: How is my crop health?',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => _answer(_typedQuestion.text),
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ),
                if (_reply != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.smart_toy, color: primary),
                            const SizedBox(width: 8),
                            Text(
                              'AeroYield',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_reply!.text),
                        if (_reply!.offersHelp) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => showHelplineModal(context),
                            icon: const Icon(Icons.support_agent),
                            label: Text(
                              _isUrdu ? 'ہیلپ لائن کھولیں' : 'Open helpline',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.voiceClose),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on Iterable<String?> {
  String? get firstOrNull {
    for (final value in this) {
      if (value != null) return value;
    }
    return null;
  }
}
