import 'package:air_query/core/constants/app_icons.dart';
import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/about/widgets/about_card.dart';
import 'package:air_query/ui/profile/notifier/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen> {
  late final double discountPC;

  @override
  void initState() {
    discountPC =
        (1 -
            (BusinessConstants.premiumDiscountedPricePKR /
                BusinessConstants.premiumActualPrice)) *
        100;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: SafeArea(
        child: SingleChildScrollView(
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
                          'Premium User ${discountPC > 0 ? "(${discountPC.round()}%)" : ""}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.golden),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.small),
                    Text(
                      "Premium users enjoy:\n"
                      "• Premium Unique Badge\n"
                      "• Golden Queries\n"
                      "• 24/7 WhatsApp Support",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSizes.medium),

                    Text(
                      "Price: ${BusinessConstants.premiumDiscountedPricePKR} PKR (Lifetime)",
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: AppColors.golden),
                    ),
                    Text(
                      "Payment Method: Any method (received via Easypaisa)",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.whitish,
                      ),
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
                              : "Coming Soon...",
                          isPremium: true,
                          isDisabled: isPremium,
                          onPressed: null,
                          // onPressed: isPremium
                          //     ? null
                          //     : AppExternalLaunchers.launchPremiumApplication,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
