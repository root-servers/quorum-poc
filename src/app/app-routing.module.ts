import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { LoginComponent } from './login/login.component';
import { ArchipelComponent } from './archipel/archipel.component';
import { PulsarComponent } from './pulsar/pulsar.component';
import { BankComponent } from './bank/bank.component';
import { AuthGuard } from './guards/auth.guard';

const routes: Routes = [
  { path: '**',  redirectTo: 'login' },
  { path: '',  redirectTo: 'login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'archipelContent', canActivate: [AuthGuard], component: ArchipelComponent },
  { path: 'pulsar', canActivate: [AuthGuard], component: PulsarComponent },
  { path: 'bank', canActivate: [AuthGuard], component: BankComponent },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
