import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/ui/about/widgets/about_card.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Air Query')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Air Query',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.small),
              Text(
                'Community Driven Wisdom',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppSizes.large),

              // Mission Card
              AboutCard(
                borderColor: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'The Mission',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: AppSizes.small),
                    Text(
                      "Air Query is an unofficial platform built for the Air University community including students, staff, alumni, and explorers. It offers a focused space to ask questions, share knowledge, discover opportunities, and connect through peer-to-peer support.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: AppSizes.medium),
                    Text(
                      'Source Available & Collaborative',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: AppSizes.small),
                    Text(
                      'Air Query is a source-available project. The code can be viewed and improved through approved contributions, helping students learn and collaborate while protecting the project’s ownership and original implementation.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSizes.large),

              // Author Card
              AboutCard(
                borderColor: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Made with ❤ by',
                      textAlign: .center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.whitish,
                      ),
                    ),
                    SizedBox(height: AppSizes.small),
                    Text(
                      'Muhammad Huzaifa Qureshi',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: .center,
                    ),
                    SizedBox(height: AppSizes.small),
                    Text(
                      'BS Software Engineering Student',
                      textAlign: .center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSizes.large),

              // Disclaimer Card
              AboutCard(
                borderColor: AppColors.whitish,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disclaimer',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.whitish,
                      ),
                    ),
                    SizedBox(height: AppSizes.small),
                    Text(
                      'This application is an independent project and is NOT affiliated with, endorsed by, or officially associated with Air University. All references to the institution are for identification purposes only.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSizes.large),

              // Copyright footer
              Text(
                '© ${DateTime.now().year} Air Query. All rights reserved.',
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.medium),
            ],
          ),
        ),
      ),
    );
  }
}
