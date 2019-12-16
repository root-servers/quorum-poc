import { Injectable } from '@angular/core';
import { quorumNodes } from '../../environments/environment';
import { JsonRpcProvider } from '@ethersproject/providers';

@Injectable({providedIn: 'root'})
export class QuorumService {

  nodeUrl: string;
  user: string;
  password: string;
  provider: JsonRpcProvider;

  constructor() {}

  async login(nodeName: string, user: string, password: string) {
    if (!quorumNodes[nodeName]) {
      throw new Error(`There is no Quorum Nodes called ${nodeName}!`);
    }
    const url = quorumNodes[nodeName];
    this.provider = new JsonRpcProvider({url, user, password});
    try {
      await this.provider.ready;
      this.user = user;
      this.nodeUrl = url;
      this.password = password;
      console.log(this.provider);
      return true;
    } catch (error) {
      console.warn(error);
    }
    return false;
  }
}
