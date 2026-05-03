import 'package:air_query/core/constants/app_icons.dart';
import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/utils/app_external_launchers.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/about/widgets/about_card.dart';
import 'package:air_query/ui/profile/notifier/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                borderColor: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.premium,
                          color: AppColors.primary,
                          size: AppSizes.mediumIcon,
                        ),
                        const SizedBox(width: AppSizes.small),
                        Text(
                          'Premium User',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.small),
                    Text(
                      'Premium users get a unique and distinct badge, along with 24/7 WhatsApp support. Show your support for the platform and stand out!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSizes.medium),
                    Text(
                      'Price: ${BusinessConstants.premiumPricePKR} PKR (Lifetime)\nPayment Method: Easypaisa',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.medium),
                    Text(
                      'How to apply:\n1. Click the button below to open the form.\n2. Fill in the brief form and attach your payment receipt.\n3. Our team will review the form ASAP.\n4. We will contact you via WhatsApp for confirmation.',
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
                              : "Apply via Google Form",
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
        ),
      ),
    );
  }
}
