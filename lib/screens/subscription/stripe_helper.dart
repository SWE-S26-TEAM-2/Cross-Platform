import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

const String stripePublishableKey =
    'pk_test_51TRFyg04qGDcIo7GKX7U0JjKAqXusMG6jPtuBgOoTyllvsl2pgc6GJmCyidrRzzAp0EqkJOtm1AMsXLjtSGiVcOB00lRh95jLg';

/// Call once in main() before runApp():
///   StripeHelper.init();
void initStripe() {
  Stripe.publishableKey = stripePublishableKey;
}

/// Shows the Stripe card payment sheet and returns a payment token string,
/// or null if the user cancelled or an error occurred.
///
/// Usage:
///   final token = await StripeHelper.createToken(context);
///   if (token != null) {
///     await subscriptionNotifier.upgrade(paymentToken: token);
///   }
class StripeHelper {
  StripeHelper._();

  /// Creates a Stripe card token using the Payment Sheet flow.
  /// Returns the token string (e.g. "tok_...") on success, null on cancel/error.
  static Future<String?> createToken(BuildContext context) async {
    try {
      // Create a card token directly — simplest approach for test mode
      final tokenData = await Stripe.instance.createToken(
        CreateTokenParams.card(
          params: const CardTokenParams(type: TokenType.Card),
        ),
      );
      return tokenData.id;
    } on StripeException catch (e) {
      final msg =
          e.error.localizedMessage ?? e.error.message ?? 'Payment cancelled';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
        );
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment error: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
      return null;
    }
  }
}

/// A ready-to-use card input widget using Stripe's CardField.
/// Embed this in your payment UI instead of building custom card inputs.
///
/// Usage:
///   CardInputWidget(onCardChanged: (details) { ... })
class CardInputWidget extends StatelessWidget {
  const CardInputWidget({super.key, this.onCardChanged});

  final void Function(CardFieldInputDetails?)? onCardChanged;

  @override
  Widget build(BuildContext context) {
    return CardField(
      onCardChanged: onCardChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }
}
