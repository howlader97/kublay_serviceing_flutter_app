
import 'package:belwork/screens/auth/sign_in_screen/provider/remember_provider.dart';
import 'package:belwork/screens/auth/sign_in_screen/provider/sign_in_provider.dart';
import 'package:belwork/screens/auth/sign_in_screen/widgets/sign_in_header.dart';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/auth/role_setting_screen/provider/roll_settings_provider.dart';
import 'package:belwork/screens/auth/sign_in_screen/widgets/google_button.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';


class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: (){
                    AppRoutes.instance.go(AppRoutesKey.instance.languageScreen);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                        child: Icon(Icons.arrow_back_outlined,color:Colors.black,)),
                  ),
                ),
                SignInHeader(),
                Gap(height: 5),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.instance.containerBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 8,),
                        AppText(text: "To register as a Craftsman/Business, please login in by email",fontSize: 16,fontWeight: FontWeight.w500,color: AppColors.instance.primary,maxLines: 2,textAlign: TextAlign.center,),
                        AppInputWidgetTwo(
                          title: "E-mail",
                          controller: _emailController,
                          hintText: "Enter email address",
                          validator: (String? value) {
                            if (value?.isEmpty ?? true) {
                              return "Enter email";
                            }
                            return null;
                          },
                          prefix: Image.asset(
                            AppAssertsIconsPath.instance.mailPassword,
                            scale: 3,
                          ),
                          // suffixIcon: Image.asset(
                          //   AppAssertsIconsPath.instance.fingerPrintIcon,
                          //   color: AppColors.instance.primary,
                          //   scale: 3,
                          // ),
                        ),
                        AppInputWidgetTwo(
                          controller: _passwordController,
                          title: "Password",
                          hintText: "Enter password",
                          maxLines: 1,
                          isPassWord: true,
                          validator: (String? value) {
                            if (value?.isEmpty ?? true) {
                              return "enter password";
                            }
                            return null;
                          },
                          prefix: Image.asset(
                            AppAssertsIconsPath.instance.lockPassword,
                            scale: 3,
                          ),
                        ),
                        Gap(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Consumer(
                              builder: (context, ref, child) {
                                final remember = ref.watch(rememberProvider);
                                return Checkbox(
                                  value: remember,
                                  onChanged: (value) {
                                    ref.read(rememberProvider.notifier).state =
                                        value ?? false;
                                  },
                                  activeColor: AppColors.instance.primary,
                                  checkColor: Colors.white,
                                  side: BorderSide(
                                    color: AppColors.instance.primary,
                                  ),
                                );
                              },
                            ),
                            AppText(text: "Remember"),
                          ],
                        ),
                        Gap(height: 10),
                        Consumer(
                          builder: (context, ref, child) {
                            final signInState = ref.watch(signInProvider);
                            return AppButton(
                              isLoading: signInState.isLoading,
                              onTap: () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                final email = _emailController.text.trim().toLowerCase();
                                final password = _passwordController.text.trim();

                                final isSuccess = await ref
                                    .read(signInProvider.notifier)
                                    .login(email: email, password: password);

                                if (isSuccess) {
                                  AppSnackBar.instance.success("Login successful!");
                                  await ref
                                      .read(userRoleNotifierProvider.notifier)
                                      .loadRole();

                                  AppRoutes.instance.go(
                                    AppRoutesKey.instance.appNavigationScreen,
                                  );
                                }
                              },
                              height: 50,
                              title: "Sign In",
                            );
                          },
                        ),
                        Gap(height: 16),
                        GestureDetector(
                          onTap: () {
                            AppRoutes.instance.pushNamed(
                              AppRoutesKey.instance.emailVerificationScreen,
                            );
                          },
                          child: AppText(
                            text: "Forgot Password?",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.red,
                          ),
                        ),
                        Gap(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              text: "Don't have an account ?",
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                            ),
                            Gap(width: 10),
                            GestureDetector(
                              onTap: () {
                                AppRoutes.instance.pushNamed(
                                  AppRoutesKey.instance.rollSettingScreen,
                                );
                              },
                              child: AppText(
                                text: "Sign Up",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Gap(height: 6),
                        AppText(
                          text: "Or",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),

                        const SizedBox(height: 10,),
                        Consumer(
                          builder: (context, ref, child) {
                            final googleSignInState = ref.watch(googleSignInProvider);
                            return GoogleButton(
                              isLoading: googleSignInState.isLoading,
                              onTap: () async {
                                final isSuccess = await ref
                                    .read(googleSignInProvider.notifier)
                                    .signInWithGoogle();

                                if (isSuccess) {
                                  AppSnackBar.instance.success("Login successful!");
                                  await ref
                                      .read(userRoleNotifierProvider.notifier)
                                      .loadRole();

                                  AppRoutes.instance.go(
                                    AppRoutesKey.instance.appNavigationScreen,
                                  );
                                }
                              },
                              text: 'Continue with Google',
                              icon: AppAssertsIconsPath.instance.googleIcon,
                            );
                          },
                        ),
                        Gap(height: 10),
                        Consumer(
                          builder: (context, ref, child) {
                            final appleSignInState = ref.watch(appleSignInProvider);
                            return GoogleButton(
                              isLoading: appleSignInState.isLoading,
                              onTap: () async {
                                final isSuccess = await ref
                                    .read(appleSignInProvider.notifier)
                                    .signInWithApple();

                                if (isSuccess) {
                                  AppSnackBar.instance.success("Login successful!");
                                  await ref
                                      .read(userRoleNotifierProvider.notifier)
                                      .loadRole();

                                  AppRoutes.instance.go(
                                    AppRoutesKey.instance.appNavigationScreen,
                                  );
                                }
                              },
                              text: 'Continue with Apple',
                              icon: AppAssertsIconsPath.instance.appleIcon,
                            );
                          },
                        ),

                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


