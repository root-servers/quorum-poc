import { Component, OnInit } from '@angular/core';
import { QuorumService } from '../+state/quorum.service';
import { FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit {

  nodes: string[];
  loginForm: FormGroup;

  constructor(
    private formBuilder: FormBuilder,
    private service: QuorumService
  ) {
    this.nodes = ['archipelContent', 'pulsar', 'bank'];

    this.loginForm = this.formBuilder.group({
      node: new FormControl('', Validators.required),
      user: new FormControl('', Validators.required),
      password: new FormControl('', Validators.required),
    });
  }

  ngOnInit() {
  }

  login() {
    const {node, user, password} = this.loginForm.value;
    console.log(node, user, password);
    this.service.login(node, user, password);
  }

}
