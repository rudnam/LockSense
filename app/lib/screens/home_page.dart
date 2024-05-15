import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      return Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to ',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'LockSense',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: bodyTextStyle,
                children: [
                  TextSpan(
                      text: 'LockSense',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                  const TextSpan(
                      text:
                          ' is a smart lock that you can manage on the cloud.'),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: bodyTextStyle,
                children: [
                  const TextSpan(
                      text: 'Forgot your keys? No problem! You can use the '),
                  TextSpan(
                      text: 'LockSense app',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                  const TextSpan(text: ' to unlock your doors.'),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: bodyTextStyle,
                children: const [
                  TextSpan(
                      text:
                          'Use it to let family or friends into your home without even needing to be there before them!'),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
