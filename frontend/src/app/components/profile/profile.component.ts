import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatListModule } from '@angular/material/list';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatListModule],
  template: `
    <div class="container">
      <mat-card class="card">
        <mat-card-header>
          <mat-card-title>User Profile</mat-card-title>
        </mat-card-header>
        <mat-card-content>
          <mat-list>
            <mat-list-item>
              <strong>Username:</strong> {{ userInfo?.preferred_username || 'N/A' }}
            </mat-list-item>
            <mat-list-item>
              <strong>Email:</strong> {{ userInfo?.email || 'N/A' }}
            </mat-list-item>
            <mat-list-item>
              <strong>Name:</strong> {{ userInfo?.name || 'N/A' }}
            </mat-list-item>
            <mat-list-item>
              <strong>Roles:</strong> {{ getRoles() }}
            </mat-list-item>
          </mat-list>

          <div class="token-section">
            <h4>Token Claims</h4>
            <pre>{{ userInfo | json }}</pre>
          </div>
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: [`
    .container {
      padding: 20px;
    }
    mat-list-item {
      margin-bottom: 10px;
    }
    .token-section {
      margin-top: 30px;
    }
    pre {
      background-color: #f5f5f5;
      padding: 15px;
      border-radius: 4px;
      overflow-x: auto;
    }
  `]
})
export class ProfileComponent implements OnInit {
  userInfo: any = null;

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.userInfo = this.authService.getUserInfo();
  }

  getRoles(): string {
    if (!this.userInfo || !this.userInfo.realm_access || !this.userInfo.realm_access.roles) {
      return 'N/A';
    }
    return this.userInfo.realm_access.roles.join(', ');
  }
}
