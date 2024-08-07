import 'package:chessground/chessground.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/widgets/list.dart';
import 'package:lichess_mobile/src/widgets/platform.dart';

class PieceSetScreen extends StatelessWidget {
  const PieceSetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      androidBuilder: _androidBuilder,
      iosBuilder: _iosBuilder,
    );
  }

  Widget _androidBuilder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.pieceSet)),
      body: _Body(),
    );
  }

  Widget _iosBuilder(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(),
      child: _Body(),
    );
  }
}

class _Body extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardPrefs = ref.watch(boardPreferencesProvider);

    List<AssetImage> getPieceImages(PieceSet set) {
      return [
        set.assets[PieceKind.whiteKing]!,
        set.assets[PieceKind.blackQueen]!,
        set.assets[PieceKind.whiteRook]!,
        set.assets[PieceKind.blackBishop]!,
        set.assets[PieceKind.whiteKnight]!,
        set.assets[PieceKind.blackPawn]!,
      ];
    }

    void onChanged(PieceSet? value) => ref
        .read(boardPreferencesProvider.notifier)
        .setPieceSet(value ?? PieceSet.cburnett);

    return SafeArea(
      child: ListView.separated(
        itemCount: PieceSet.values.length,
        separatorBuilder: (_, __) => PlatformDivider(
          height: 1,
          // on iOS: 14 (default indent) + 16 (padding)
          indent:
              Theme.of(context).platform == TargetPlatform.iOS ? 14 + 16 : null,
          color: Theme.of(context).platform == TargetPlatform.iOS
              ? null
              : Colors.transparent,
        ),
        itemBuilder: (context, index) {
          final set = PieceSet.values[index];
          return PlatformListTile(
            trailing: boardPrefs.pieceSet == set
                ? Theme.of(context).platform == TargetPlatform.android
                    ? const Icon(Icons.check)
                    : Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: CupertinoTheme.of(context).primaryColor,
                      )
                : null,
            title: Text(set.label),
            subtitle: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 264,
              ),
              child: Stack(
                children: [
                  boardPrefs.boardTheme.thumbnail,
                  Row(
                    children: getPieceImages(set)
                        .map(
                          (img) => Image(
                            image: img,
                            height: 44,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            onTap: () => onChanged(set),
            selected: boardPrefs.pieceSet == set,
          );
        },
      ),
    );
  }
}
