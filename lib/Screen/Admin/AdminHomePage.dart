import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantee/Bloc/Auth/auth_bloc.dart';
import 'package:restaurantee/Bloc/User/user_bloc.dart';
import 'package:restaurantee/Screen/Admin/Category/CategoriesAdminPage.dart';
import 'package:restaurantee/Screen/Admin/Delivery/ListDeliverysPage.dart';
import 'package:restaurantee/Screen/Admin/OrdersAdmin/OrdersAdminPage.dart';
import 'package:restaurantee/Screen/Admin/Products/ListProductsPage.dart';
import 'package:restaurantee/Screen/Profile/ChangePasswordPage.dart';
import 'package:restaurantee/Screen/Profile/EditProdilePage.dart';
import 'package:restaurantee/Screen/Home/SelectRolePage.dart';
import 'package:restaurantee/Screen/Intro/CheckingLoginPage.dart';
import 'package:restaurantee/Themes/ColorsFrave.dart';
import 'package:restaurantee/Widgets/AnimationRoute.dart';
import 'package:restaurantee/Widgets/ImagePicker.dart';
import 'package:restaurantee/Widgets/Widgets.dart';
import 'package:restaurantee/Helpers/Helpers.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is LoadingUserState) {
          modalLoading(context);
        } else if (state is SuccessUserState) {
          Navigator.pop(context);
          modalSuccess(
              context,
              'Picture Change Successfully',
              () => Navigator.pushReplacement(
                  context, routeFrave(page: AdminHomePage())));
          Navigator.pop(context);
        } else if (state is FailureUserState) {
          Navigator.pop(context);
          errorMessageSnack(context, state.error);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            children: [
              Align(alignment: Alignment.center, child: ImagePickerFrave()),
              const SizedBox(height: 10.0),
              Center(
                  child: BlocBuilder<UserBloc, UserState>(
                      builder: (_, state) => TextFrave(
                          text: (state.user != null)
                              ? state.user!.firstName!.toUpperCase() +
                                  ' ' +
                                  state.user!.lastName!.toUpperCase()
                              : '',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          maxLine: 1,
                          textAlign: TextAlign.center,
                          color: ColorsFrave.secundaryColor))),
              const SizedBox(height: 5.0),
              Center(
                  child: BlocBuilder<UserBloc, UserState>(
                      builder: (_, state) => TextFrave(
                          text: (state.user != null) ? state.user!.email! : '',
                          fontSize: 20,
                          color: ColorsFrave.secundaryColor))),
              const SizedBox(height: 15.0),
              const TextFrave(text: 'Account', color: Colors.grey),
              const SizedBox(height: 10.0),
              ItemAccount(
                text: 'Profile setting',
                icon: Icons.person,
                colorIcon: 0xff01C58C,
                onPressed: () => Navigator.push(
                    context, routeFrave(page: EditProfilePage())),
              ),
              ItemAccount(
                text: 'Change Password',
                icon: Icons.lock_rounded,
                colorIcon: 0xff1B83F5,
                onPressed: () => Navigator.push(
                    context, routeFrave(page: ChangePasswordPage())),
              ),
              ItemAccount(
                text: 'Change Role',
                icon: Icons.swap_horiz_rounded,
                colorIcon: 0xffE62755,
                onPressed: () => Navigator.pushAndRemoveUntil(context,
                    routeFrave(page: SelectRolePage()), (route) => false),
              ),
              ItemAccount(
                text: 'Dark mode',
                icon: Icons.dark_mode_rounded,
                colorIcon: 0xff051E2F,
              ),
              const SizedBox(height: 15.0),
              const TextFrave(text: 'Restaurant', color: Colors.grey),
              const SizedBox(height: 10.0),
              ItemAccount(
                text: 'Categories',
                icon: Icons.category_rounded,
                colorIcon: 0xff5E65CD,
                onPressed: () => Navigator.push(
                    context, routeFrave(page: CategoriesAdminPage())),
              ),
              ItemAccount(
                text: 'Products',
                icon: Icons.add,
                colorIcon: 0xff355773,
                onPressed: () => Navigator.push(
                    context, routeFrave(page: ListProductsPage())),
              ),
              ItemAccount(
                text: 'Delivery',
                icon: Icons.delivery_dining_rounded,
                colorIcon: 0xff469CD7,
                onPressed: () => Navigator.push(
                    context, routeFrave(page: ListDeliverysPage())),
              ),
              ItemAccount(
                text: 'Orders',
                icon: Icons.checklist_rounded,
                colorIcon: 0xffFFA136,
                onPressed: () => Navigator.push(
                    context, routeFrave(page: OrdersAdminPage())),
              ),
              const SizedBox(height: 15.0),
              const TextFrave(text: 'Personal', color: Colors.grey),
              const SizedBox(height: 10.0),
              ItemAccount(
                text: 'Privacy & Policy',
                icon: Icons.policy_rounded,
                colorIcon: 0xff6dbd63,
              ),
              ItemAccount(
                text: 'Security',
                icon: Icons.lock_outline_rounded,
                colorIcon: 0xff1F252C,
              ),
              ItemAccount(
                text: 'Term & Conditions',
                icon: Icons.description_outlined,
                colorIcon: 0xff458bff,
              ),
              ItemAccount(
                text: 'Help',
                icon: Icons.help_outline,
                colorIcon: 0xff4772e6,
              ),
              const Divider(),
              ItemAccount(
                text: 'Sign Out',
                icon: Icons.power_settings_new_sharp,
                colorIcon: 0xffF02849,
                onPressed: () {
                  authBloc.add(LogOutEvent());
                  Navigator.pushAndRemoveUntil(context,
                      routeFrave(page: CheckingLoginPage()), (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
