import { Injectable } from '@angular/core';
import { quorumNodes } from '../../environments/environment';
import { JsonRpcProvider } from '@ethersproject/providers';
import { BehaviorSubject } from 'rxjs';

@Injectable({providedIn: 'root'})
export class QuorumService {

  nodeName: string;
  nodeUrl: string;
  user: string;
  password: string;
  provider: JsonRpcProvider;

  loading$ = new BehaviorSubject(false);
  error$ = new BehaviorSubject('');
  logged$ = new BehaviorSubject(false);

  constructor() {}

  isLoggedIn() {
    return !!this.user && !!this.nodeName && !!this.nodeUrl;
  }

  logout() {
    delete this.nodeName;
    delete this.nodeUrl;
    delete this.user;
    delete this.password;
    delete this.provider;
    this.loading$.next(false);
    this.error$.next('');
    this.logged$.next(false);
  }

  async login(nodeName: string, password: string) {
    this.loading$.next(true);
    this.error$.next('');
    if (!quorumNodes[nodeName]) {
      throw new Error(`There is no Quorum Nodes called ${nodeName}!`);
    }
    const {url, user} = quorumNodes[nodeName];
    this.provider = new JsonRpcProvider({url, user, password});
    try {
      await this.provider.ready;
      this.user = user;
      this.nodeUrl = url;
      this.nodeName = nodeName;
      this.password = password;
      console.log(this.provider);
      this.loading$.next(false);
      this.logged$.next(true);
      return true;
    } catch (error) {
      console.warn(error);
      this.error$.next('Invalid Password');
      this.logged$.next(false);
    }
    this.loading$.next(false);
    return false;
  }
}
