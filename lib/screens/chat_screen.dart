import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/chat_message_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/soil_provider.dart';
import '../providers/weather_provider.dart';
import '../utils/constants.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _userBubbleStart = Color(0xFFE55934);
const _userBubbleEnd = Color(0xFFC44424);

TextStyle _geist(double size, {FontWeight w = FontWeight.w400, Color? color}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: w, color: color);

TextStyle _cabinet(double size,
        {FontWeight w = FontWeight.w700, Color? color}) =>
    GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: color);

// ── ChatScreen ────────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _textFocus = FocusNode();
  bool _hasText = false;

  late final AnimationController _cursorCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _rocketCtrl;
  late final AnimationController _avatarCtrl;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _rocketCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _avatarCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<ChatProvider>().loadCached(auth.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    _textFocus.dispose();
    _cursorCtrl.dispose();
    _pulseCtrl.dispose();
    _rocketCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    _ctrl.clear();
    setState(() => _hasText = false);
    _rocketCtrl.forward().then((_) => _rocketCtrl.reverse());

    final auth = context.read<AuthProvider>();
    final settings = context.read<SettingsProvider>();
    final weather = context.read<WeatherProvider>().weather;
    final soil = context.read<SoilProvider>().soil;

    await context.read<ChatProvider>().sendMessage(
          uid: auth.user?.uid ?? 'anonymous',
          text: text,
          language: settings.language,
          weather: weather,
          soil: soil,
          farmerName: auth.user?.name ?? '',
          conciseResponses: settings.conciseResponses,
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final settings = context.read<SettingsProvider>();

    final streamingVisible = chat.streamingContent.isNotEmpty;
    final dotsVisible = chat.typing && !streamingVisible;
    final totalItems = chat.messages.length +
        (dotsVisible ? 1 : 0) +
        (streamingVisible ? 1 : 0);
    final isEmpty = totalItems == 0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Photo background
          CachedNetworkImage(
            imageUrl: kPhotoChat,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFF0B1426)),
            errorWidget: (_, __, ___) =>
                Container(color: const Color(0xFF0B1426)),
          ),

          // Gradient overlay with 55% opacity for message readability
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x4C000000), Color(0x8C000000)],
                stops: [0.0, 1.0],
              ),
            ),
          ),

          // UI
          Column(
            children: [
              _AppBar(
                  avatarCtrl: _avatarCtrl,
                  onClear: () => context.read<ChatProvider>().clearMessages()),
              _LangStrip(lang: settings.language),
              Expanded(
                child: isEmpty
                    ? _EmptyState(onSuggestion: (s) {
                        _ctrl.text = s;
                        _send();
                      })
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: totalItems,
                        itemBuilder: (ctx, i) {
                          if (i < chat.messages.length) {
                            final msg = chat.messages[i];
                            final isLastAi = !msg.isUser &&
                                i == chat.messages.length - 1 &&
                                !chat.typing;
                            return _BubbleRow(
                              message: msg,
                              index: i,
                              showChips: isLastAi,
                              onChipTap: (s) {
                                _ctrl.text = s;
                                _send();
                              },
                            );
                          }
                          if (dotsVisible) return const _TypingDots();
                          if (streamingVisible) {
                            _scrollToBottom();
                            return _StreamingBubble(
                                text: chat.streamingContent,
                                cursorCtrl: _cursorCtrl);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
              ),
              if (chat.typing)
                _StopBtn(
                    onStop: () => context.read<ChatProvider>().cancelStream()),
              _InputBar(
                ctrl: _ctrl,
                focusNode: _textFocus,
                hasText: _hasText,
                disabled: chat.typing,
                pulseCtrl: _pulseCtrl,
                rocketCtrl: _rocketCtrl,
                onSend: chat.typing ? null : _send,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final AnimationController avatarCtrl;
  final VoidCallback onClear;
  const _AppBar({required this.avatarCtrl, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0x24FFFFFF),
              border:
                  Border(bottom: BorderSide(color: Color(0x38FFFFFF))),
            ),
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedBuilder(
                  animation: avatarCtrl,
                  builder: (_, __) {
                    final t = avatarCtrl.value;
                    final c1 = Color.lerp(kAmber, kPlum, t)!;
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kIndigo, c1],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.agriculture_rounded,
                          color: Colors.white, size: 20),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ClimaVOICE',
                          style: _cabinet(18, color: Colors.white)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF22C55E)),
                          ),
                          const SizedBox(width: 5),
                          Text('AI Farming Assistant · Online',
                              style:
                                  _geist(12, color: const Color(0xC7FFFFFF))),
                        ],
                      ),
                    ],
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onClear,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.white70),
                    ),
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

// ── Language strip ────────────────────────────────────────────────────────────

class _LangStrip extends StatelessWidget {
  final String lang;
  const _LangStrip({required this.lang});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0x18FFFFFF),
            border: Border(bottom: BorderSide(color: Color(0x28FFFFFF))),
          ),
          child: Row(
            children: [
              const Icon(Icons.language_rounded,
                  size: 14, color: Color(0xC7FFFFFF)),
              const SizedBox(width: 6),
              Text('Responding in: ${kLanguages[lang] ?? 'English'}',
                  style: _geist(12, color: const Color(0xC7FFFFFF))),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 14, color: Color(0xC7FFFFFF)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Message bubble row ────────────────────────────────────────────────────────

class _BubbleRow extends StatelessWidget {
  final ChatMessage message;
  final int index;
  final bool showChips;
  final void Function(String) onChipTap;

  static const _chips = [
    'Tell me more details',
    'What about irrigation?',
    'Any precautions to take?',
  ];

  const _BubbleRow({
    required this.message,
    required this.index,
    required this.showChips,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onLongPress: () => _showMenu(context),
              child: isUser
                  ? _UserBubble(text: message.content)
                  : _AiBubble(text: message.content),
            ),
          ),
        ).animate(delay: (index * 40).ms).fadeIn(duration: 300.ms).slideY(
            begin: 0.15, end: 0, duration: 350.ms, curve: Curves.easeOut),
        if (showChips) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _chips
                .map((s) => _SuggestionPill(text: s, onTap: () => onChipTap(s)))
                .toList(),
          ),
        ],
        const SizedBox(height: 6),
      ],
    );
  }

  void _showMenu(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF1A2542),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kAmber.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.copy_rounded, color: kAmber, size: 18),
              ),
              title:
                  Text('Copy message', style: _geist(15, color: Colors.white)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── User bubble ───────────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_userBubbleStart, _userBubbleEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: _geist(15, w: FontWeight.w500, color: Colors.white)
              .copyWith(height: 1.5),
        ),
      ),
    );
  }
}

// ── AI bubble ─────────────────────────────────────────────────────────────────

class _AiBubble extends StatelessWidget {
  final String text;
  const _AiBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _aiAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  decoration: const BoxDecoration(
                    color: Color(0x38FFFFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.fromBorderSide(
                        BorderSide(color: Color(0x55FFFFFF))),
                  ),
                  child: Text(
                    text,
                    style:
                        _geist(15, color: Colors.white).copyWith(height: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _aiAvatar() => Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kIndigo, kPlum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child:
          const Icon(Icons.agriculture_rounded, color: Colors.white, size: 14),
    );

// ── Streaming bubble ──────────────────────────────────────────────────────────

class _StreamingBubble extends StatelessWidget {
  final String text;
  final AnimationController cursorCtrl;
  const _StreamingBubble({required this.text, required this.cursorCtrl});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _aiAvatar(),
            const SizedBox(width: 8),
            Flexible(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 18),
                    decoration: const BoxDecoration(
                      color: Color(0x38FFFFFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.fromBorderSide(
                          BorderSide(color: Color(0x55FFFFFF))),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            text,
                            style: _geist(15, color: Colors.white)
                                .copyWith(height: 1.5),
                          ),
                        ),
                        const SizedBox(width: 2),
                        AnimatedBuilder(
                          animation: cursorCtrl,
                          builder: (_, __) => Opacity(
                            opacity: cursorCtrl.value,
                            child: Container(
                              width: 2,
                              height: 16,
                              decoration: BoxDecoration(
                                color: kAmber,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Typing dots ───────────────────────────────────────────────────────────────

class _TypingDots extends StatelessWidget {
  const _TypingDots();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _aiAvatar(),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0x38FFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.fromBorderSide(
                      BorderSide(color: Color(0x55FFFFFF))),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (i) => Container(
                      width: 7,
                      height: 7,
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      decoration: const BoxDecoration(
                          color: Colors.white70, shape: BoxShape.circle),
                    )
                        .animate(
                          delay: (i * 200).ms,
                          onPlay: (c) => c.repeat(reverse: true),
                        )
                        .moveY(
                            begin: 0,
                            end: -5,
                            duration: 400.ms,
                            curve: Curves.easeInOut),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Suggestion chips ──────────────────────────────────────────────────────────

class _SuggestionPill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionPill({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x28FFFFFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x50FFFFFF)),
              ),
              child: Text(
                text,
                style: _geist(13, w: FontWeight.w500, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final void Function(String) onSuggestion;
  const _EmptyState({required this.onSuggestion});

  static const _starters = [
    'What crop should I grow next?',
    'How much water for tomatoes?',
    "Today's market prices",
    'Best fertilizer for cotton',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0x30FFFFFF),
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  border: Border.fromBorderSide(
                      BorderSide(color: Color(0x55FFFFFF))),
                ),
                child: const Icon(Icons.agriculture_rounded,
                    color: Colors.white, size: 56),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
              begin: 1.0,
              end: 1.04,
              duration: 2.seconds,
              curve: Curves.easeInOut),
        ),
        const SizedBox(height: 20),
        Text(
          "Hi! I'm ClimaVOICE",
          style: _cabinet(24, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Ask me anything about your farm',
          style: _geist(14, color: const Color(0xC7FFFFFF)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ..._starters.asMap().entries.map(
              (e) => MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onSuggestion(e.value),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0x24FFFFFF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x38FFFFFF)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: kAmber.withAlpha(50),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 15,
                                  color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(e.value,
                                  style: _geist(14,
                                      w: FontWeight.w500, color: Colors.white)),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: Colors.white54),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  .animate(delay: (e.key * 80).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.06, end: 0),
            ),
      ],
    );
  }
}

// ── Stop generating button ────────────────────────────────────────────────────

class _StopBtn extends StatelessWidget {
  final VoidCallback onStop;
  const _StopBtn({required this.onStop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onStop,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x30FFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kCoral.withAlpha(180)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stop_circle_outlined, size: 14, color: kCoral),
                      const SizedBox(width: 6),
                      Text('Stop generating', style: _geist(13, color: kCoral)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focusNode;
  final bool hasText;
  final bool disabled;
  final AnimationController pulseCtrl;
  final AnimationController rocketCtrl;
  final VoidCallback? onSend;

  const _InputBar({
    required this.ctrl,
    required this.focusNode,
    required this.hasText,
    required this.disabled,
    required this.pulseCtrl,
    required this.rocketCtrl,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(12, 12, 12, bottom + 12),
          decoration: const BoxDecoration(
            color: Color(0x33000000),
            border: Border(top: BorderSide(color: Color(0x38FFFFFF))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Mic button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.mic_none_rounded,
                    color: Colors.white70, size: 20),
              ),
              const SizedBox(width: 10),
              // TextField
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: Focus(
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.enter &&
                          !HardwareKeyboard.instance.isShiftPressed) {
                        if (onSend != null) onSend!();
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: TextField(
                      controller: ctrl,
                      focusNode: focusNode,
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend?.call(),
                      style: _geist(15, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ask ClimaVOICE anything',
                        hintStyle: _geist(15, color: const Color(0xC7FFFFFF)),
                        filled: true,
                        fillColor: Colors.white.withAlpha(20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide:
                              const BorderSide(color: Color(0x38FFFFFF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide:
                              const BorderSide(color: Color(0x38FFFFFF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide:
                              const BorderSide(color: Color(0x80FFFFFF)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Send button
              AnimatedBuilder(
                animation: Listenable.merge([pulseCtrl, rocketCtrl]),
                builder: (_, __) {
                  final scale = hasText ? 1.0 + pulseCtrl.value * 0.05 : 1.0;
                  final offset = rocketCtrl.value * 4.0;
                  final angle = rocketCtrl.value * 0.26;
                  return Transform.translate(
                    offset: Offset(offset, -offset),
                    child: Transform.rotate(
                      angle: angle,
                      child: Transform.scale(
                        scale: scale,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: onSend,
                            child: AnimatedOpacity(
                              opacity: (hasText && !disabled) ? 1.0 : 0.4,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: (hasText && !disabled)
                                      ? const LinearGradient(
                                          colors: [
                                            _userBubbleStart,
                                            _userBubbleEnd
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        )
                                      : LinearGradient(colors: [
                                          Colors.grey.shade600,
                                          Colors.grey.shade700,
                                        ]),
                                  shape: BoxShape.circle,
                                  boxShadow: (hasText && !disabled)
                                      ? [
                                          BoxShadow(
                                            color: kAmber.withAlpha(100),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: const Icon(Icons.arrow_upward_rounded,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
