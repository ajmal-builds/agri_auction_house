import 'package:flutter_test/flutter_test.dart';
import 'package:agri_auction_house/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriAuctionApp());
    expect(find.byType(AgriAuctionApp), findsOneWidget);
  });
}
