import 'dart:async';

import 'package:app_empresas/ui/features/login/controller/login_bloc.dart';
import 'package:app_empresas/ui/features/login/service/login_service.dart';
import 'package:app_empresas/ui/features/sms_verification/handler/call_response_handler.dart';
import 'package:app_empresas/ui/features/sms_verification/handler/check_code_response_handler.dart';
import 'package:app_empresas/ui/features/sms_verification/handler/otp_marks_handler.dart';
import 'package:app_empresas/ui/features/sms_verification/service/otp_service.dart';
import 'package:app_empresas/ui/widgets/modals/copec_dialog/copec_dialog.dart';
import 'package:app_empresas/ui/widgets/modals/toast_notification.dart';
import 'package:flutter/material.dart';

/// The [OtpBloc] manages the OTP verification process, including:
/// - Validating the user’s OTP input.
/// - Requesting a call to provide the OTP.
/// - Resending the OTP to the user.
///
/// This class follows a singleton pattern to ensure a single instance is used across the app.
class OtpBloc {
  /// Private constructor to enforce the singleton pattern.
  OtpBloc._privateConstructor();

  // Singleton instance
  static OtpBloc? _instance;

  /// Returns the singleton instance of [OtpBloc].
  static OtpBloc get instance {
    _instance ??= OtpBloc._privateConstructor();
    return _instance!;
  }

  /// Disposes the instance of [OtpBloc] to free resources.
  static void disposeInstance() {
    _instance?.dispose();
    _instance = null;
  }

  // Variables
  ///This controller is in charge of the otp input
  TextEditingController? otpController;

  ///This focus node is used on the input to check if it is focused and give focus to it on entering the page
  FocusNode? otpNode;

  /// Initializes the OTP input field and focus node.
  void init() {
    otpController ??= TextEditingController();
    otpNode ??= FocusNode();
  }

  /// Disposes the OTP input controller and focus node to prevent memory leaks.
  void dispose() {
    otpController?.dispose();
    otpController = null;
    otpNode?.dispose();
    otpNode = null;
  }

  /// Validates the entered OTP by sending it to the server.
  ///
  /// - Takes the [otpCode] entered by the user.
  /// - Sends it to the backend via [OtpService].
  /// - Handles the server response using [OTPStatusHandler].
  /// - If successful, the user is redirected accordingly.
  Future<void> validateOTP(String otpCode, BuildContext context) async {
    final fetchData = await OtpService().sendSmsOTP(otpCode);
    fetchData.fold((left) {
      // Handles errors if the OTP validation fails.
      unawaited(OtpMarksHandler.markPhoneValidationResponse(valid: false));
      CopecDialog.fatalError();
    }, (right) {
      // Processes the OTP response and takes appropriate action.
      final valid = right.responseCode == 3 || right.responseCode == 4;
      unawaited(OtpMarksHandler.markPhoneValidationResponse(valid: valid));
      unawaited(OTPStatusHandler().handleStatus(right, context));
    });
  }

  /// Requests a phone call to provide the OTP.
  ///
  /// - Sends a request to the backend to initiate a call with the OTP.
  /// - Uses [OtpService] to make the request.
  /// - Handles the response with [CallResponseHandler].
  /// - Displays a toast notification if the request fails.
  Future<void> requestCall({required String phoneNumber, required BuildContext context}) async {
    unawaited(OtpMarksHandler.markCallMeInstead());
    final fetchData = await OtpService().makePhoneCall(phoneNumber);
    fetchData.fold(
      (left) => CopecToast.error(context, 'Error inesperado ${left.message}'),
      (right) {
        CallResponseHandler().handleCallResponse(right, context);
      },
    );
  }

  /// Requests a new OTP and resets the timer.
  ///
  /// - Sends the stored phone number to the backend to receive a new OTP.
  /// - Uses [LoginService] to send the request.
  /// - Displays a success toast if the request is successful.
  /// - Logs an error message if the request fails.
  Future<void> requestNewOTP(BuildContext context) async {
    unawaited(OtpMarksHandler.markResendOtp());
    final fetchResult =
        await LoginService().sendPhoneNumber(LoginBloc.instance.phoneNumberController!.text);
    fetchResult.fold(
      (left) {
        CopecDialog.fatalError();
      },
      (right) {
        CopecToast.success(context, '¡Nuevo código enviado!');
      },
    );
  }
}

