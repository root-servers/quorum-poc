import { Component, OnInit } from '@angular/core';
import { QuorumService } from '../+state/quorum.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit {

  node: string;
  user: string;
  password: string;

  constructor(
    private service: QuorumService
  ) { }

  ngOnInit() {
  }

  login() {
    this.service.sayHello();
  }

}
