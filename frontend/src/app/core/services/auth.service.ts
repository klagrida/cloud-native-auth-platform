import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { OAuthService, AuthConfig } from 'angular-oauth2-oidc';
import { BehaviorSubject, Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private isAuthenticatedSubject = new BehaviorSubject<boolean>(false);
  public isAuthenticated$: Observable<boolean> = this.isAuthenticatedSubject.asObservable();

  private authConfig: AuthConfig = {
    issuer: `${environment.keycloakUrl}/realms/${environment.keycloakRealm}`,
    redirectUri: window.location.origin + '/callback',
    clientId: environment.keycloakClientId,
    responseType: 'code',
    scope: 'openid profile email',
    showDebugInformation: !environment.production,
    requireHttps: false,
    postLogoutRedirectUri: window.location.origin,
    useSilentRefresh: true,
    silentRefreshRedirectUri: window.location.origin + '/silent-refresh.html'
  };

  constructor(
    private oauthService: OAuthService,
    private router: Router
  ) {
    this.configureOAuth();
  }

  private configureOAuth(): void {
    this.oauthService.configure(this.authConfig);
    this.oauthService.setupAutomaticSilentRefresh();
    this.oauthService.loadDiscoveryDocumentAndTryLogin().then(() => {
      if (this.oauthService.hasValidAccessToken()) {
        this.isAuthenticatedSubject.next(true);
      }
    });

    this.oauthService.events.subscribe(event => {
      if (event.type === 'token_received' || event.type === 'token_refreshed') {
        this.isAuthenticatedSubject.next(true);
      } else if (event.type === 'logout' || event.type === 'session_terminated') {
        this.isAuthenticatedSubject.next(false);
      }
    });
  }

  public login(): void {
    this.oauthService.initCodeFlow();
  }

  public logout(): void {
    this.oauthService.logOut();
    this.isAuthenticatedSubject.next(false);
    this.router.navigate(['/']);
  }

  public isAuthenticated(): boolean {
    return this.oauthService.hasValidAccessToken();
  }

  public getAccessToken(): string {
    return this.oauthService.getAccessToken();
  }

  public getUserInfo(): any {
    const claims = this.oauthService.getIdentityClaims();
    return claims || null;
  }

  public hasRole(role: string): boolean {
    const claims: any = this.oauthService.getIdentityClaims();
    if (!claims) return false;

    const realmAccess = claims['realm_access'];
    if (!realmAccess || !realmAccess.roles) return false;

    return realmAccess.roles.includes(role);
  }

  public hasAnyRole(roles: string[]): boolean {
    return roles.some(role => this.hasRole(role));
  }

  public getUsername(): string {
    const claims: any = this.getUserInfo();
    return claims?.preferred_username || '';
  }

  public getEmail(): string {
    const claims: any = this.getUserInfo();
    return claims?.email || '';
  }
}
