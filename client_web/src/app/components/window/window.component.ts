import { CdkPortal, DomPortalHost } from '@angular/cdk/portal';
import { ApplicationRef, Component, ComponentFactoryResolver, Injector, OnDestroy, OnInit, ViewChild } from '@angular/core';

@Component({
    selector: 'window',
    template: `<ng-container *cdkPortal><ng-content></ng-content></ng-container>`,
})
export class WindowComponent implements OnInit, OnDestroy {
    @ViewChild(CdkPortal) portal: CdkPortal;
    private externalWindow: any = null;

    constructor(private componentFactoryResolver: ComponentFactoryResolver, private applicationRef: ApplicationRef, private injector: Injector) {}

    ngOnInit() {}

    ngAfterViewInit() {
        this.externalWindow = window.open('', 'window', 'width=600,height=400,left=200,top=200');

        const host = new DomPortalHost(this.externalWindow.document.body, this.componentFactoryResolver, this.applicationRef, this.injector);

        host.attach(this.portal);
    }

    ngOnDestroy() {
        this.externalWindow.close();
    }
}
