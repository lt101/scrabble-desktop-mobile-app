import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LanguageSelectorComponentComponent } from './language-selector-component.component';

describe('LanguageSelectorComponentComponent', () => {
  let component: LanguageSelectorComponentComponent;
  let fixture: ComponentFixture<LanguageSelectorComponentComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ LanguageSelectorComponentComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(LanguageSelectorComponentComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
