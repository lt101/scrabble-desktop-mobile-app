import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RegisterPageComponentComponent } from './register-page-component.component';

describe('RegisterPageComponentComponent', () => {
  let component: RegisterPageComponentComponent;
  let fixture: ComponentFixture<RegisterPageComponentComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ RegisterPageComponentComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(RegisterPageComponentComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
