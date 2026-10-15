import 'package:flutter/material.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/theme/app_theme.dart';
import 'package:cat_app/widgets/app_feedback.dart';
import 'package:cat_app/widgets/cat_photo.dart';
import 'package:cat_app/widgets/sub_page_header.dart';

// "Meus votos": todas as fotos que o usuário já votou (GET /votes).
class MyVotesScreen extends StatefulWidget {
  const MyVotesScreen({super.key});

  @override
  State<MyVotesScreen> createState() => _MyVotesScreenState();
}

class _MyVotesScreenState extends State<MyVotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppState.instance.refreshVotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SubPageHeader(title: 'Meus votos'),
            Expanded(
              child: ListenableBuilder(
                listenable: AppState.instance,
                builder: (context, _) {
                  final state = AppState.instance;
                  final votos = state.votes;
                  if (votos.isEmpty && state.loadingVotes) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return RefreshIndicator(
                    onRefresh: state.refreshVotes,
                    child: votos.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(
                                height: 300,
                                child: EmptyView(
                                  icon: Icons.star_border,
                                  message: 'Você ainda não votou em nenhum gato.',
                                ),
                              ),
                            ],
                          )
                        : GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            itemCount: votos.length,
                            itemBuilder: (context, i) {
                              final v = votos[i];
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: CatPhoto(
                                        url: state.voteThumbUrl(v),
                                        colorIndex: i,
                                        iconSize: 28,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: v.isPositive
                                            ? AppColors.green
                                            : AppColors.pink,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        v.isPositive ? Icons.star : Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
