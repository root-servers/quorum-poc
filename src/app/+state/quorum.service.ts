import { Injectable } from '@angular/core';

@Injectable({providedIn: 'root'})
export class QuorumService {
  constructor() {
  }

  sayHello() {
    console.log('hello');
  }
}
