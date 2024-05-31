import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      const double widthThreshold = 600;
      TextStyle bodyTextStyle;
      if (constraints.maxWidth < widthThreshold) {
        bodyTextStyle = Theme.of(context).textTheme.bodyMedium!;
      } else {
        bodyTextStyle = Theme.of(context).textTheme.bodyLarge!;
      }

      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: 'Welcome to ',
                  style: Theme.of(context).textTheme.headlineMedium,
                  children: [
                    TextSpan(
                        text: "LockSense",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary))
                  ]),
            ),
            const SizedBox(height: 12.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: 'LockSense',
                  style: bodyTextStyle.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  children: [
                    TextSpan(
                      text:
                          ' is a smart lock that you can manage on the cloud.',
                      style: bodyTextStyle,
                    )
                  ]),
            ),
            const SizedBox(height: 12.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: 'Forgot your keys? No problem! You can use the ',
                  style: bodyTextStyle,
                  children: [
                    TextSpan(
                        text: 'LockSense app',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                    const TextSpan(
                      text: ' to unlock your doors.',
                    ),
                  ]),
            ),
            const SizedBox(height: 12.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text:
                    'Use it to let family or friends into your home without even needing to be there before them!',
                style: bodyTextStyle,
              ),
            ),
          ],
        ),
      );
    });
  }
}
