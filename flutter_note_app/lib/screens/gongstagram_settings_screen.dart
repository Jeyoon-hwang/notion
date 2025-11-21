import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/theme_provider.dart';
import '../services/custom_font_loader.dart';

/// Gongstagram Settings Screen
/// Theme customization and custom font management
class GongstagramSettingsScreen extends StatefulWidget {
  const GongstagramSettingsScreen({Key? key}) : super(key: key);

  @override
  State<GongstagramSettingsScreen> createState() =>
      _GongstagramSettingsScreenState();
}

class _GongstagramSettingsScreenState extends State<GongstagramSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('공스타그램 설정'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Theme Settings
          _buildSectionHeader(theme, '테마 선택'),
          const SizedBox(height: 12),
          _buildThemeSelector(theme, themeProvider),
          const SizedBox(height: 32),

          // Custom Font Settings
          _buildSectionHeader(theme, '커스텀 폰트'),
          const SizedBox(height: 8),
          Text(
            '나만의 필기체 폰트를 업로드하세요\n타이핑된 텍스트도 손글씨처럼 보입니다',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          _buildFontUploadButton(theme),
          const SizedBox(height: 16),
          _buildFontList(theme, themeProvider),
          const SizedBox(height: 32),

          // Focus Mode Settings
          _buildSectionHeader(theme, '포커스 모드'),
          const SizedBox(height: 12),
          _buildFocusModeCard(theme),
          const SizedBox(height: 32),

          // Weekly Goal Settings
          _buildSectionHeader(theme, '주간 목표'),
          const SizedBox(height: 12),
          _buildWeeklyGoalCard(theme),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    );
  }

  Widget _buildThemeSelector(ThemeData theme, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            theme,
            themeProvider,
            mode: StudyThemeMode.muji,
            title: '무지 화이트',
            description: '깨끗하고 정돈된 느낌',
            icon: Icons.wb_sunny_outlined,
          ),
          const SizedBox(height: 12),
          _buildThemeOption(
            theme,
            themeProvider,
            mode: StudyThemeMode.ivory,
            title: '아이보리 종이',
            description: '따뜻한 종이 느낌',
            icon: Icons.article_outlined,
          ),
          const SizedBox(height: 12),
          _buildThemeOption(
            theme,
            themeProvider,
            mode: StudyThemeMode.pastel,
            title: '파스텔 톤',
            description: '부드럽고 감성적인',
            icon: Icons.palette_outlined,
          ),
          const SizedBox(height: 12),
          _buildThemeOption(
            theme,
            themeProvider,
            mode: StudyThemeMode.dark,
            title: '다크 모드',
            description: '밤 공부용',
            icon: Icons.nightlight_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeData theme,
    ThemeProvider themeProvider, {
    required StudyThemeMode mode,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = themeProvider.themeMode == mode;

    return InkWell(
      onTap: () => themeProvider.setTheme(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onBackground.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onBackground.withOpacity(0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontUploadButton(ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['ttf', 'otf'],
        );

        if (result != null && result.files.single.path != null) {
          final fontLoader = CustomFontLoader();
          final font = await fontLoader.uploadFont(result.files.single.path!);

          if (font != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('폰트 업로드 성공: ${font.displayName}'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {});
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('폰트 업로드 실패'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      icon: const Icon(Icons.upload_file),
      label: const Text('폰트 파일 업로드 (.ttf, .otf)'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildFontList(ThemeData theme, ThemeProvider themeProvider) {
    final fontLoader = CustomFontLoader();
    final fonts = fontLoader.loadedFonts;

    if (fonts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onBackground.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.font_download_outlined,
              size: 48,
              color: theme.colorScheme.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              '업로드된 폰트가 없습니다',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Default font option
          _buildFontItem(
            theme,
            themeProvider,
            fontName: null,
            displayName: '기본 폰트',
            isDefault: true,
          ),
          const Divider(height: 1),
          // Custom fonts
          ...fonts.map((font) => _buildFontItem(
                theme,
                themeProvider,
                fontName: font.family,
                displayName: font.displayName,
              )),
        ],
      ),
    );
  }

  Widget _buildFontItem(
    ThemeData theme,
    ThemeProvider themeProvider, {
    required String? fontName,
    required String displayName,
    bool isDefault = false,
  }) {
    final isSelected = themeProvider.customFontFamily == fontName;

    return ListTile(
      title: Text(
        displayName,
        style: TextStyle(
          fontFamily: fontName,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'AaBbCc가나다라',
        style: TextStyle(
          fontFamily: fontName,
          fontSize: 12,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Icon(Icons.check_circle, color: theme.colorScheme.primary),
          if (!isDefault) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('폰트 삭제'),
                    content: Text('$displayName을(를) 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && fontName != null) {
                  final fontLoader = CustomFontLoader();
                  await fontLoader.deleteFont(fontName);
                  if (mounted) {
                    setState(() {});
                    if (isSelected) {
                      themeProvider.setCustomFont(null);
                    }
                  }
                }
              },
            ),
          ],
        ],
      ),
      onTap: () => themeProvider.setCustomFont(fontName),
    );
  }

  Widget _buildFocusModeCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.center_focus_strong, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '포커스 모드',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '방해 요소를 모두 제거하고 오직 학습에만 집중합니다',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '주간 목표',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '40시간',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Show weekly goal edit dialog
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }
}
