

import 'package:chat/env/env.dart';

class ServiceAccCred {
  static late final Map secret;

  static Future<void> intializeSecret() async {
    // await dotenv.load(fileName: ".env");
    
    // secret = dotenv.env["GOOGLE_SERVICE_ACCOUNT_KEY"]!;

    // final env = Env('GOOGLE_SERVICE_ACCOUNT_KEY'); // Provide the encryption key
    // print("google api secret: ${env.name}");
    // print(env.blah);
    secret = await Env.load();
  }
}