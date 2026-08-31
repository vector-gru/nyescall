import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/widgets.dart';
import '../providers/voices_provider.dart';

class VoicesScreen extends ConsumerStatefulWidget {
  const VoicesScreen({super.key});

  @override
  ConsumerState<VoicesScreen> createState() => _VoicesScreenState();
}

class _VoicesScreenState extends ConsumerState<VoicesScreen> {
  final _nameCtrl = TextEditingController();
  String _selectedLanguage = 'English';
  String _selectedSpeed = 'Normal';
  String _selectedTone = 'Professional';
  bool _consentGiven = false;
  int _activeTab = 0; // 0=My voice, 1=AI male, 2=AI female, 3=Other

  static const _tabs = ['My voice', 'AI male', 'AI female', 'Other'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveVoice() async {
    await ref.read(saveVoiceProvider.notifier).save(
          name: _nameCtrl.text,
          language: _selectedLanguage,
          speakingSpeed: _selectedSpeed,
          voiceTone: _selectedTone,
          consentGiven: _consentGiven,
        );
  }

  @override
  Widget build(BuildContext context) {
    final voicesAsync = ref.watch(voicesProvider);
    final saveState = ref.watch(saveVoiceProvider);
    final isSaving = saveState is SaveVoiceLoading;

    ref.listen<SaveVoiceState>(saveVoiceProvider, (_, next) {
      if (next is SaveVoiceSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Voice saved!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        _nameCtrl.clear();
        setState(() => _consentGiven = false);
        ref.read(saveVoiceProvider.notifier).reset();
      } else if (next is SaveVoiceError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
        ref.read(saveVoiceProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppConstants.appName, style: AppTextStyles.titleLarge),
                Text('Nyescall Center', style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Default voice settings ──────────────────────────────────
            NyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.voiceForYourCall,
                      style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 2),
                  Text(AppStrings.defaultVoiceNotSet,
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 16),

                  // Settings row
                  Row(
                    children: [
                      Expanded(
                        child: _DropdownSetting(
                          label: AppStrings.language,
                          value: _selectedLanguage,
                          items: AppConstants.supportedLanguages,
                          onChanged: (v) =>
                              setState(() => _selectedLanguage = v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DropdownSetting(
                          label: AppStrings.speakingSpeed,
                          value: _selectedSpeed,
                          items: AppConstants.speakingSpeeds,
                          onChanged: (v) => setState(() => _selectedSpeed = v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DropdownSetting(
                          label: AppStrings.voiceTone,
                          value: _selectedTone,
                          items: AppConstants.voiceTones,
                          onChanged: (v) => setState(() => _selectedTone = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(AppStrings.speedToneNote,
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Voice type tabs ─────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final selected = _activeTab == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              selected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(
                          _tabs[i],
                          style: AppTextStyles.labelLarge.copyWith(
                            color:
                                selected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // ── Add new voice ───────────────────────────────────────────
            NyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.addANewVoice,
                      style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 4),
                  Text(AppStrings.addVoiceNote, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 16),

                  NyTextField(
                    label: AppStrings.voiceName,
                    hint: AppStrings.voiceNameHint,
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 16),

                  // Record / Upload buttons
                  Row(
                    children: [
                      Expanded(
                        child: NyButton(
                          label: AppStrings.recordSample,
                          icon: const Icon(Icons.mic_rounded,
                              size: 16, color: AppColors.textPrimary),
                          onPressed: () {/* TODO: record */},
                          variant: NyButtonVariant.outlined,
                          height: 44,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: NyButton(
                          label: AppStrings.uploadAudio,
                          icon: const Icon(Icons.upload_rounded,
                              size: 16, color: AppColors.textPrimary),
                          onPressed: () {/* TODO: file pick */},
                          variant: NyButtonVariant.outlined,
                          height: 44,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Consent checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _consentGiven,
                        onChanged: (v) =>
                            setState(() => _consentGiven = v ?? false),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _consentGiven = !_consentGiven),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              AppStrings.voiceOwnershipConsent,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  NyButton(
                    label: AppStrings.saveVoice,
                    onPressed: _consentGiven ? _saveVoice : null,
                    isLoading: isSaving,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.security_rounded,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(AppStrings.recordingsPrivacyNote,
                            style: AppTextStyles.labelSmall),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── My voices list ──────────────────────────────────────────
            Text(AppStrings.myVoices, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 10),

            voicesAsync.when(
              loading: () => const NyLoading(),
              error: (e, _) =>
                  NyEmptyState(message: 'Could not load voices. $e'),
              data: (voices) => voices.isEmpty
                  ? NyCard(
                      child: Text(AppStrings.noVoicesYet,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                    )
                  : Column(
                      children: voices
                          .map((v) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: NyCard(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.mic_rounded,
                                          color: AppColors.primary, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(v.name,
                                                style:
                                                    AppTextStyles.titleMedium),
                                            Text(
                                                '${v.language} · ${v.speakingSpeed} · ${v.voiceTone}',
                                                style: AppTextStyles.bodySmall),
                                          ],
                                        ),
                                      ),
                                      if (v.isDefault)
                                        const NyBadge(
                                            label: 'Default',
                                            variant: NyBadgeVariant.success),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DropdownSetting extends StatelessWidget {
  const _DropdownSetting({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          style: AppTextStyles.bodySmall,
          items: items
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
