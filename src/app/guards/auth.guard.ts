import { Injectable } from '@angular/core';
import { CanActivate, UrlTree, Router } from '@angular/router';
import { QuorumService } from '../+state/quorum.service';

@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {

  constructor(
    private router: Router,
    private service: QuorumService,
  ) {}

  canActivate(): Promise<boolean | UrlTree> | UrlTree {
    return new Promise(resolve => {
      const logged = this.service.isLoggedIn();
      if (logged) {
        resolve(true);
      }
      resolve(this.router.parseUrl('/login'));
    });
  }
}
