import { Component } from '@angular/core';
import { QuorumService } from '../+state/quorum.service';
import { FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';
import { Observable } from 'rxjs';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {

  nodes: string[];
  loginForm: FormGroup;

  loading$: Observable<boolean>;
  error$: Observable<string>;

  constructor(
    private formBuilder: FormBuilder,
    private service: QuorumService,
    private router: Router,
  ) {
    this.nodes = ['archipelContent', 'pulsar', 'bank'];

    this.loginForm = this.formBuilder.group({
      node: new FormControl('', Validators.required),
      password: new FormControl('', Validators.required),
    });

    this.loading$ = this.service.loading$;
    this.error$ = this.service.error$;
  }

  async login() {
    const {node, password} = this.loginForm.value;
    console.log(node, password);
    const success = await this.service.login(node, password);
    if (success) {
      this.router.navigateByUrl(`/${this.service.nodeName}`);
    }
  }

}
