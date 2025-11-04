import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet, RouterLink } from '@angular/router';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';
import { MatIconModule } from '@angular/material/icon';
import { AuthService } from './core/services/auth.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    CommonModule,
    RouterOutlet,
    RouterLink,
    MatToolbarModule,
    MatButtonModule,
    MatMenuModule,
    MatIconModule
  ],
  template: `
    <mat-toolbar color="primary">
      <span>Auth Platform</span>
      <span class="spacer"></span>
      <button mat-button routerLink="/">Home</button>
      <button mat-button routerLink="/dashboard" *ngIf="isAuthenticated()">Dashboard</button>
      <button mat-button routerLink="/profile" *ngIf="isAuthenticated()">Profile</button>
      <button mat-button routerLink="/admin" *ngIf="hasAdminRole()">Admin</button>

      <button mat-button [matMenuTriggerFor]="menu" *ngIf="isAuthenticated()">
        <mat-icon>account_circle</mat-icon>
        {{ getUsername() }}
      </button>
      <mat-menu #menu="matMenu">
        <button mat-menu-item routerLink="/profile">
          <mat-icon>person</mat-icon>
          <span>Profile</span>
        </button>
        <button mat-menu-item (click)="logout()">
          <mat-icon>logout</mat-icon>
          <span>Logout</span>
        </button>
      </mat-menu>

      <button mat-raised-button color="accent" (click)="login()" *ngIf="!isAuthenticated()">
        Login
      </button>
    </mat-toolbar>

    <router-outlet></router-outlet>
  `,
  styles: [`
    .spacer {
      flex: 1 1 auto;
    }
  `]
})
export class AppComponent {
  constructor(public authService: AuthService) {}

  isAuthenticated(): boolean {
    return this.authService.isAuthenticated();
  }

  hasAdminRole(): boolean {
    return this.authService.hasRole('ADMIN');
  }

  getUsername(): string {
    return this.authService.getUsername();
  }

  login(): void {
    this.authService.login();
  }

  logout(): void {
    this.authService.logout();
  }
}
