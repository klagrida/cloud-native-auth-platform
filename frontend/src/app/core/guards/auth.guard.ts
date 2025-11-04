import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    const requiredRoles = route.data['roles'] as string[];

    if (requiredRoles && requiredRoles.length > 0) {
      if (authService.hasAnyRole(requiredRoles)) {
        return true;
      } else {
        router.navigate(['/unauthorized']);
        return false;
      }
    }

    return true;
  } else {
    authService.login();
    return false;
  }
};
