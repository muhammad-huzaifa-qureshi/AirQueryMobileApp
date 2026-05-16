import 'package:air_query/core/constants/app_icons.dart';
import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/utils/app_external_launchers.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/about/widgets/about_card.dart';
import 'package:air_query/ui/badges/notifier/badges_notifier.dart';
import 'package:air_query/ui/profile/notifier/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  static const _priceNotFound = 'Price Not Found';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(badgesProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(badgesProvider);

            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.pricing == null && state.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Failed to load prices."),
                    const SizedBox(height: AppSizes.small),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(badgesProvider.notifier)
                          .fetchPremiumPlanPricing(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            final actualPrice = state.pricing?.premiumActualPricePKR;
            final discountedPrice = state.pricing?.premiumDiscountedPricePKR;
            final discountPC = _discountPercentage(
              actualPrice: actualPrice,
              discountedPrice: discountedPrice,
            );
            final priceText = discountedPrice == null
                ? _priceNotFound
                : '${_formatPrice(discountedPrice)} PKR';

            return SingleChildScrollView(
              padding: const .all(AppSizes.medium),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Text(
                    'Platform Badges',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.small),
                  Text(
                    'Stand out in the community!',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.large),

                  // Insider Badge Info
                  AboutCard(
                    borderColor: AppColors.whitish,
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              AppIcons.insider,
                              color: AppColors.whitish,
                              size: AppSizes.mediumIcon,
                            ),
                            const SizedBox(width: AppSizes.small),
                            Text(
                              'Insider Badge',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.small),
                        Text(
                          'Awarded to AU Students and AU Staff only. To get this badge, set your role to Student or Staff in the profile section (an AU email account is required).',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.medium),

                  // Premium Badge Info
                  AboutCard(
                    borderColor: AppColors.golden,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              AppIcons.premium,
                              color: AppColors.golden,
                              size: AppSizes.mediumIcon,
                            ),
                            const SizedBox(width: AppSizes.small),
                            Text(
                              'Premium User ${discountPC != null ? "($discountPC% OFF)" : ""}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: AppColors.golden),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.small),
                        Text(
                          "Premium users enjoy:\n"
                          "- Premium Unique Badge\n"
                          "- Golden Queries\n"
                          "- 24/7 WhatsApp Support",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSizes.medium),

                        Text(
                          "Price: $priceText (Lifetime)",
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppColors.golden),
                        ),
                        Text(
                          "Payment Method: Any method (received via Easypaisa)",
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppColors.whitish),
                        ),

                        const SizedBox(height: AppSizes.medium),
                        Text(
                          'How to apply:\n'
                          '1. Click the button below to open the form.\n'
                          '2. Fill in the brief form and attach your payment receipt.\n'
                          '3. Our team will review the form ASAP.\n'
                          '4. We will contact you via WhatsApp for confirmation.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSizes.medium),
                        // if user is already premium, else CTA
                        Consumer(
                          builder: (context, ref, _) {
                            final isPremium = ref.watch(
                              profileProvider.select(
                                (state) => state.user?.isPremium ?? false,
                              ),
                            );
                            return CTAButton(
                              text: isPremium
                                  ? "Premium Activated"
                                  : "Apply for Premium",
                              isPremium: true,
                              isDisabled: isPremium,
                              onPressed: isPremium
                                  ? null
                                  : AppExternalLaunchers.launchPremiumApplication,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static int? _discountPercentage({
    required double? actualPrice,
    required double? discountedPrice,
  }) {
    if (actualPrice == null || discountedPrice == null || actualPrice <= 0) {
      return null;
    }
    final discount = (1 - (discountedPrice / actualPrice)) * 100;
    return discount > 0 ? discount.round() : null;
  }

  static String _formatPrice(double price) {
    return price % 1 == 0 ? price.toInt().toString() : price.toStringAsFixed(2);
  }
}
