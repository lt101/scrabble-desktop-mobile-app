import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UploadAvatarDialogComponent } from './upload-avatar-dialog.component';

describe('UploadAvatarDialogComponent', () => {
  let component: UploadAvatarDialogComponent;
  let fixture: ComponentFixture<UploadAvatarDialogComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ UploadAvatarDialogComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(UploadAvatarDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
