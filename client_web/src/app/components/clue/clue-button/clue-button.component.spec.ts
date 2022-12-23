import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ClueButtonComponent } from './clue-button.component';

describe('ClueButtonComponent', () => {
  let component: ClueButtonComponent;
  let fixture: ComponentFixture<ClueButtonComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ClueButtonComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(ClueButtonComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
