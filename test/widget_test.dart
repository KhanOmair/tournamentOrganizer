import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourney_app/models/match.dart';
import 'package:tourney_app/models/player.dart';
import 'package:tourney_app/models/round.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/pages/home_page.dart';
import 'package:tourney_app/pages/login_page.dart';
import 'package:tourney_app/pages/player_details_page.dart';
import 'package:tourney_app/pages/signup_page.dart';
import 'package:tourney_app/pages/tournament_detail_page.dart';
import 'package:tourney_app/utils/theme_data.dart';
import 'package:tourney_app/widgets/grouping_widget.dart';
import 'package:tourney_app/widgets/podium_widget.dart';
import 'package:tourney_app/widgets/standings_table.dart';

final homeTeam = Team(
  teamId: 'north',
  teamName: 'Northside Community Club',
  playerIdsTeam: ['omar', 'sam'],
  played: 2,
  wins: 2,
  goalsFor: 6,
  goalsAgainst: 1,
);
final awayTeam = Team(
  teamId: 'united',
  teamName: 'United Weekend Players',
  playerIdsTeam: ['alex', 'jordan'],
  played: 2,
  wins: 1,
  losses: 1,
  goalsFor: 3,
  goalsAgainst: 4,
);
final match = GameMatch(
  id: 'match1',
  type: 'doubles',
  status: 'upcoming',
  playerIds: ['omar', 'sam', 'alex', 'jordan'],
  scores: MatchScore(team1: 3, team2: 1),
  winner: '',
  team1: homeTeam,
  team2: awayTeam,
  streamUrl: '',
);
final round = Round(
  id: 'round1',
  name: 'Group A · Round 2',
  roundNumber: 2,
  matchIds: [match],
);
Tournament tournament([String status = 'ongoing']) => Tournament(
  id: 'cup',
  name: 'Friday Night Community Championship',
  type: 'Group Format',
  sport: 'fifa',
  status: status,
  startDate: DateTime(2026, 9, 18),
  playerIds: match.playerIds,
  rounds: [round],
  teams: [homeTeam, awayTeam],
  participants: [],
  groups: [
    Group(id: 'a', name: 'Group A', teams: [homeTeam, awayTeam]),
  ],
  topScorers: [
    TopScorer(id: 'omar', name: 'Omar', goals: 5),
    TopScorer(id: 'sam', name: 'Sam', goals: 1),
  ],
);
final player = Player(
  id: 'omar',
  name: 'Omar',
  fname: 'Omar',
  lname: 'Khan',
  email: 'player@example.com',
  rating: 0,
  isAdmin: true,
  globalStats: PlayerGlobalStats(
    matchesPlayed: 12,
    wins: 8,
    losses: 4,
    tournamentsPlayed: 3,
  ),
);

Future<void> mount(
  WidgetTester tester,
  Widget child, {
  double width = 360,
  double scale = 1,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: midnightCourtTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final body = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
    final heading = FontLoader('BarlowCondensed')
      ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-SemiBold.ttf'));
    await Future.wait([body.load(), heading.load()]);
  });

  testWidgets(
    'login validates before authentication and toggles password visibility',
    (tester) async {
      await mount(tester, const LoginPage());
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(find.byTooltip('Hide password'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'signup fields are scrollable and validate before creating an account',
    (tester) async {
      await mount(tester, const SignupPage(), width: 320);
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your first name'), findsOneWidget);
      expect(find.text('Use at least 6 characters'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 768.0, 1280.0]) {
    testWidgets('dashboard cards fit at $width pixels', (tester) async {
      await mount(
        tester,
        Scaffold(
          body: TournamentDashboard(
            player: player,
            tournaments: [
              tournament(),
              tournament('upcoming'),
              tournament('completed'),
            ],
          ),
        ),
        width: width,
      );
      expect(find.text('TOURNAMENTS'), findsOneWidget);
      expect(find.text('View tournament'), findsNWidgets(2));
      expect(find.text('Start tournament'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('profile and podium fit at $width pixels', (tester) async {
      await mount(
        tester,
        Scaffold(body: PlayerProfileView(player: player)),
        width: width,
      );
      expect(find.text('YOUR RECORD'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final cup = tournament();
      await mount(
        tester,
        Scaffold(
          body: PodiumWidget(
            teams: cup.teams,
            groups: cup.groups,
            topScorers: cup.topScorers,
          ),
        ),
        width: width,
      );
      expect(find.text('LEADING TEAMS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tournament tabs and match editor fit at $width pixels', (
      tester,
    ) async {
      await mount(
        tester,
        Scaffold(
          body: TournamentDetailBody(tournament: tournament(), isAdmin: true),
        ),
        width: width,
      );
      expect(find.text('3 : 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Edit match').first);
      await tester.pumpAndSettle();
      expect(find.text('EDIT MATCH'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Standings'));
      await tester.pumpAndSettle();
      expect(find.text('Pts'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'score editor stages goals and cancel leaves the model unchanged',
    (tester) async {
      final cup = tournament();
      await mount(
        tester,
        Scaffold(body: TournamentDetailBody(tournament: cup, isAdmin: true)),
      );
      await tester.tap(find.byTooltip('Edit match').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Add a goal for Omar'));
      await tester.tap(find.byTooltip('Add a goal for Omar'));
      await tester.pump();
      expect(find.text('6'), findsOneWidget);
      expect(cup.topScorers.first.goals, 5);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('EDIT MATCH'), findsNothing);
      expect(cup.topScorers.first.goals, 5);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('group creation prevents duplicate team assignment', (
    tester,
  ) async {
    await mount(tester, GroupingWidget(teams: [homeTeam, awayTeam]));
    await tester.enterText(find.byType(TextField), 'Group A');
    await tester.tap(find.widgetWithText(FilterChip, homeTeam.teamName));
    await tester.tap(find.text('Add group'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilterChip, homeTeam.teamName), findsNothing);
    expect(find.widgetWithText(FilterChip, awayTeam.teamName), findsOneWidget);
    expect(find.text('Group A'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty standings and dashboard show useful states', (
    tester,
  ) async {
    await mount(
      tester,
      const Scaffold(
        body: StandingsTable(teams: [], groups: []),
      ),
    );
    expect(find.text('No standings yet'), findsOneWidget);
    await mount(
      tester,
      Scaffold(
        body: TournamentDashboard(player: player, tournaments: []),
      ),
    );
    expect(find.text('The next tournament starts here'), findsOneWidget);
    expect(find.text('UPCOMING'), findsNothing);
    expect(find.text('No upcoming tournaments yet'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text remains usable on phone screens', (tester) async {
    await mount(tester, const LoginPage(), scale: 1.6);
    expect(tester.takeException(), isNull);
    await mount(
      tester,
      Scaffold(
        body: TournamentDashboard(player: player, tournaments: [tournament()]),
      ),
      scale: 1.6,
    );
    expect(find.text('UPCOMING'), findsNothing);
    expect(find.text('No upcoming tournaments yet'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
