import { Component } from '@angular/core';
import { QuorumService } from './+state/quorum.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  title = 'quorum-poc';

  logged$ = this.service.logged$;

  constructor(
    private router: Router,
    private service: QuorumService,
  ) {}

  logout() {
    this.service.logout();
    this.router.navigateByUrl('/');
  }
}
