import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import 'package:restaurantee/Controller/AuthController.dart';
import 'package:restaurantee/Helpers/secure_storage.dart';
import 'package:restaurantee/Models/Response/ResponseLogin.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<LoginEvent>(_onLogin);
    on<CheckLoginEvent>(_onCheckLogin);
    on<LogOutEvent>(_onLogOut);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingAuthState());

      final data =
          await authController.loginController(event.email, event.password);

      await Future.delayed(const Duration(milliseconds: 850));

      if (data.resp) {
        await secureStorage.deleteSecureStorage();

        await secureStorage.persistenToken(data.token!);

        emit(state.copyWith(
            user: data.user, rolId: data.user!.rolId.toString()));
      } else {
        emit(FailureAuthState(data.msg));
      }
    } catch (e) {
      emit(FailureAuthState(e.toString()));
    }
  }

  Future<void> _onCheckLogin(
      CheckLoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingAuthState());

      if (await secureStorage.readToken() != null) {
        final data = await authController.renewLoginController();

        if (data.resp) {
          await secureStorage.persistenToken(data.token!);

          emit(state.copyWith(
              user: data.user, rolId: data.user!.rolId.toString()));
        } else {
          emit(LogOutAuthState());
        }
      } else {
        emit(LogOutAuthState());
      }
    } catch (e) {
      emit(FailureAuthState(e.toString()));
    }
  }

  Future<void> _onLogOut(LogOutEvent event, Emitter<AuthState> emit) async {
    await secureStorage.deleteSecureStorage();
    emit(LogOutAuthState());
    emit(state.copyWith(user: null, rolId: ''));
  }
}
