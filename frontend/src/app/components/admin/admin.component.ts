import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTableModule } from '@angular/material/table';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-admin',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatButtonModule, MatProgressSpinnerModule, MatTableModule],
  template: `
    <div class="container">
      <mat-card class="card">
        <mat-card-header>
          <mat-card-title>Admin Panel</mat-card-title>
          <mat-card-subtitle>Admin-only access</mat-card-subtitle>
        </mat-card-header>
        <mat-card-content>
          <div class="actions">
            <button mat-raised-button color="primary" (click)="fetchUsers()" [disabled]="loading">
              Load Users
            </button>
            <button mat-raised-button color="accent" (click)="fetchStats()" [disabled]="loading">
              Load Stats
            </button>
          </div>

          <div *ngIf="loading" class="loading">
            <mat-spinner diameter="40"></mat-spinner>
          </div>

          <div *ngIf="users && users.length > 0" class="data-section">
            <h4>Users</h4>
            <table mat-table [dataSource]="users" class="mat-elevation-z2">
              <ng-container matColumnDef="id">
                <th mat-header-cell *matHeaderCellDef>ID</th>
                <td mat-cell *matCellDef="let user">{{ user.id }}</td>
              </ng-container>

              <ng-container matColumnDef="username">
                <th mat-header-cell *matHeaderCellDef>Username</th>
                <td mat-cell *matCellDef="let user">{{ user.username }}</td>
              </ng-container>

              <ng-container matColumnDef="email">
                <th mat-header-cell *matHeaderCellDef>Email</th>
                <td mat-cell *matCellDef="let user">{{ user.email }}</td>
              </ng-container>

              <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
              <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
            </table>
          </div>

          <div *ngIf="stats" class="data-section">
            <h4>System Statistics</h4>
            <pre>{{ stats | json }}</pre>
          </div>

          <div *ngIf="error" class="error">
            {{ error }}
          </div>
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: [`
    .container {
      padding: 20px;
    }
    .actions {
      margin-bottom: 20px;
    }
    .actions button {
      margin-right: 10px;
    }
    .loading {
      margin-top: 20px;
      text-align: center;
    }
    .data-section {
      margin-top: 30px;
    }
    table {
      width: 100%;
    }
    .error {
      margin-top: 20px;
      padding: 15px;
      background-color: #ffebee;
      color: #c62828;
      border-radius: 4px;
    }
    pre {
      background-color: #f5f5f5;
      padding: 15px;
      border-radius: 4px;
    }
  `]
})
export class AdminComponent implements OnInit {
  users: any[] = [];
  stats: any = null;
  loading = false;
  error: string | null = null;
  displayedColumns: string[] = ['id', 'username', 'email'];

  constructor(private http: HttpClient) {}

  ngOnInit(): void {}

  fetchUsers(): void {
    this.loading = true;
    this.error = null;
    this.stats = null;

    this.http.get<any[]>(`${environment.apiUrl}/admin/users`).subscribe({
      next: (data) => {
        this.users = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = `Error: ${err.message}`;
        this.loading = false;
      }
    });
  }

  fetchStats(): void {
    this.loading = true;
    this.error = null;
    this.users = [];

    this.http.get(`${environment.apiUrl}/admin/stats`).subscribe({
      next: (data) => {
        this.stats = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = `Error: ${err.message}`;
        this.loading = false;
      }
    });
  }
}
