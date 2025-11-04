import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatButtonModule],
  template: `
    <div class="container">
      <mat-card class="card">
        <mat-card-header>
          <mat-card-title>Welcome to Auth Platform</mat-card-title>
        </mat-card-header>
        <mat-card-content>
          <p>This is a cloud-native authentication platform using:</p>
          <ul>
            <li>Angular 17+ for the frontend</li>
            <li>Spring Boot 3+ for the backend API</li>
            <li>Keycloak for identity and access management</li>
            <li>Kubernetes for container orchestration</li>
          </ul>
          <p *ngIf="!isAuthenticated()">Please log in to access protected features.</p>
          <p *ngIf="isAuthenticated()">You are logged in! Visit the dashboard to see your information.</p>
        </mat-card-content>
        <mat-card-actions>
          <button mat-raised-button color="primary" (click)="login()" *ngIf="!isAuthenticated()">
            Login
          </button>
        </mat-card-actions>
      </mat-card>
    </div>
  `,
  styles: [`
    .container {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 80vh;
    }
    .card {
      max-width: 600px;
      width: 100%;
    }
    ul {
      margin: 20px 0;
    }
  `]
})
export class HomeComponent {
  constructor(private authService: AuthService) {}

  login(): void {
    this.authService.login();
  }

  isAuthenticated(): boolean {
    return this.authService.isAuthenticated();
  }
}
