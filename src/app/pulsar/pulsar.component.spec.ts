import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PulsarComponent } from './pulsar.component';

describe('PulsarComponent', () => {
  let component: PulsarComponent;
  let fixture: ComponentFixture<PulsarComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PulsarComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PulsarComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
