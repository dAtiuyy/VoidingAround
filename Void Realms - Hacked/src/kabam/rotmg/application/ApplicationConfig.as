package kabam.rotmg.application {
import flash.display.DisplayObjectContainer;
import flash.display.LoaderInfo;

import kabam.rotmg.application.api.ApplicationSetup;
import kabam.rotmg.application.api.DebugSetup;
import kabam.rotmg.application.impl.ProductionSetup;
import kabam.rotmg.application.model.DomainModel;
import kabam.rotmg.application.model.PlatformModel;
import kabam.rotmg.build.api.BuildData;

import org.swiftsuspenders.Injector;

import robotlegs.bender.framework.api.IConfig;

public class ApplicationConfig implements IConfig {

    [Inject]
    public var injector:Injector;
    [Inject]
    public var root:DisplayObjectContainer;
    [Inject]
    public var data:BuildData;
    [Inject]
    public var loaderInfo:LoaderInfo;
    [Inject]
    public var domainModel:DomainModel;


    public function configure():void {
        var _local_1:ApplicationSetup = new ProductionSetup();
        this.injector.map(DebugSetup).toValue(_local_1);
        this.injector.map(ApplicationSetup).toValue(_local_1);
        this.injector.map(PlatformModel).asSingleton();
    }
}
}//package kabam.rotmg.application
