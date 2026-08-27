// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/views/theme.dart';

class FacebookButton extends StatelessWidget {
  const FacebookButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(width: 2, color: context.appBorder),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const LoginScreen()),
            // );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.appSurface,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/facebook-icon.png',
                height: 25,
              ),
              Text(
                ' FACEBOOK',
                style: TextStyle(
                    color: context.appInfo,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
