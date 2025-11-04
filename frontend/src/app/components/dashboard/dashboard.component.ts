import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { AuthService } from '../../core/services/auth.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatButtonModule, MatProgressSpinnerModule],
  template: `
    <div class="container">
      <mat-card class="card">
        <mat-card-header>
          <mat-card-title>User Dashboard</mat-card-title>
        </mat-card-header>
        <mat-card-content>
          <h3>Welcome, {{ getUsername() }}!</h3>

          <div class="section">
            <h4>API Test</h4>
            <button mat-raised-button color="primary" (click)="fetchUserData()" [disabled]="loading">
              Fetch User Data
            </button>

            <div *ngIf="loading" class="loading">
              <mat-spinner diameter="40"></mat-spinner>
            </div>

            <div *ngIf="userData" class="data-display">
              <pre>{{ userData | json }}</pre>
            </div>

            <div *ngIf="error" class="error">
              {{ error }}
            </div>
          </div>
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: [`
    .container {
      padding: 20px;
    }
    .section {
      margin-top: 20px;
    }
    .loading {
      margin-top: 20px;
      text-align: center;
    }
    .data-display {
      margin-top: 20px;
      padding: 15px;
      background-color: #f5f5f5;
      border-radius: 4px;
    }
    .error {
      margin-top: 20px;
      padding: 15px;
      background-color: #ffebee;
      color: #c62828;
      border-radius: 4px;
    }
    pre {
      margin: 0;
      white-space: pre-wrap;
    }
  `]
})
export class DashboardComponent implements OnInit {
  userData: any = null;
  loading = false;
  error: string | null = null;

  constructor(
    private authService: AuthService,
    private http: HttpClient
  ) {}

  ngOnInit(): void {}

  getUsername(): string {
    return this.authService.getUsername();
  }

  fetchUserData(): void {
    this.loading = true;
    this.error = null;
    this.userData = null;

    this.http.get(`${environment.apiUrl}/user/info`).subscribe({
      next: (data) => {
        this.userData = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = `Error: ${err.message}`;
        this.loading = false;
      }
    });
  }
}
