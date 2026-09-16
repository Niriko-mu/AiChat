import 'package:flutter/cupertino.dart';
import '../config/theme.dart';

/// 通讯录右侧字母索引栏（A-Z + #），支持点击与长按滑动。
///
/// 使用 pan 手势统一跟踪按下/滑动/抬起，避免 onTapDown 与
/// onVerticalDrag* 在手势竞争中丢失事件，导致滑动不跳转。
class AlphabetIndexBar extends StatelessWidget {
  final Set<String> availableLetters;
  final ValueChanged<String> onLetterChanged;
  final VoidCallback onDragEnd;

  const AlphabetIndexBar({
    super.key,
    required this.availableLetters,
    required this.onLetterChanged,
    required this.onDragEnd,
  });

  static final _letters = ['#', ...'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')];
  static const double _itemHeight = 18;
  // 略宽命中区，手指在侧边条附近也能滑到
  static const double _hitWidth = 40;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = _letters.length * _itemHeight;
        // 字母列表居中；topOffset 可能为负（高度不够时），由 _handle 夹紧
        final topOffset = (constraints.maxHeight - totalHeight) / 2;

        void handle(Offset local) {
          _handle(local.dy, topOffset);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          // pan：按下即响应，滑动持续更新，与列表纵向滚动竞争时优先占用侧边条
          onPanDown: (details) => handle(details.localPosition),
          onPanStart: (details) => handle(details.localPosition),
          onPanUpdate: (details) => handle(details.localPosition),
          onPanEnd: (_) => onDragEnd(),
          onPanCancel: onDragEnd,
          // 兜底：极短点击若未形成 pan，仍能跳一次
          onTapUp: (details) {
            handle(details.localPosition);
            onDragEnd();
          },
          child: SizedBox(
            width: _hitWidth,
            child: Center(
              child: SizedBox(
                width: 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _letters.map((letter) {
                    final isAvailable = availableLetters.contains(letter);
                    return SizedBox(
                      height: _itemHeight,
                      child: Container(
                        width: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? context.accentColor.withValues(alpha: 0.12)
                              : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isAvailable
                                ? context.accentColor
                                : context.textSecondaryColor
                                    .withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handle(double localY, double topOffset) {
    // 按下位置相对字母列表；超出上下时夹到首尾字母
    double y = localY - topOffset;
    if (y < 0) y = 0;
    final listH = _letters.length * _itemHeight;
    if (y > listH - 0.01) y = listH - 0.01;
    var index = (y / _itemHeight).floor();
    if (index < 0) index = 0;
    if (index >= _letters.length) index = _letters.length - 1;
    onLetterChanged(_letters[index]);
  }
}
