// import 'package:mailer/mailer.dart';
// import 'package:mailer/smtp_server.dart';

// void sendEmail() async {
//   // Replace these values with your email and password
//   final String emailcontroller = 'your_email@my.cspc.edu.ph';
//   final String password = 'your_email_password';

//   // Create an SMTP server
//   final smtpServer = gmail(emailcontroller, password);

//   // Create a message
//   final message = Message()
//     ..from = Address(emailcontroller, 'Your Name')
//     ..recipients.add('recipient_email@my.cspc.edu.ph')
//     ..subject = 'Test Dart Email'
//     ..text = 'This is a test email sent from Dart.';

//   try {
//     // Send the message
//     final sendReport = await send(message, smtpServer);

//     print('Message sent: ' + sendReport.toString());
//   } catch (e) {
//     print('Error occurred: $e');
//   }
// }

// void main() {
//   sendEmail();
// }