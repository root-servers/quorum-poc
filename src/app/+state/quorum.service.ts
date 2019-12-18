import { Injectable } from '@angular/core';
import { quorumNodes } from '../../environments/environment';
import { JsonRpcProvider } from '@ethersproject/providers';
import { BehaviorSubject } from 'rxjs';

@Injectable({providedIn: 'root'})
export class QuorumService {

  nodeUrl: string;
  user: string;
  password: string;
  provider: JsonRpcProvider;

  loading$ = new BehaviorSubject(false);
  error$ = new BehaviorSubject('');

  constructor() {}

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
      this.password = password;
      console.log(this.provider);
      this.loading$.next(false);
      return true;
    } catch (error) {
      console.warn(error);
      this.error$.next('Invalid Password');
    }
    this.loading$.next(false);
    return false;
  }
}
