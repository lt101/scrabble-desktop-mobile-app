import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ClueDialogComponent } from './clue-dialog.component';

describe('ClueDialogComponent', () => {
  let component: ClueDialogComponent;
  let fixture: ComponentFixture<ClueDialogComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ClueDialogComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(ClueDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
