package kabam.rotmg.application.impl {
import kabam.rotmg.application.api.ApplicationSetup;

public class ProductionSetup implements ApplicationSetup {

    private const SERVER:String = "173.208.193.186";
    private const UNENCRYPTED:String = ("http://" + SERVER);
    private const ENCRYPTED:String = ("http://" + SERVER);
    private const BUILD_LABEL:String = "Void Client - 09/18";


    public function getAppEngineUrl(_arg_1:Boolean = false):String {
        return (((_arg_1) ? this.UNENCRYPTED : this.ENCRYPTED));
    }

    public function getBuildLabel():String {
        return this.BUILD_LABEL;
    }

    public function useLocalTextures():Boolean {
        return (false);
    }

    public function isToolingEnabled():Boolean {
        return (false);
    }

    public function isGameLoopMonitored():Boolean {
        return (false);
    }

    public function useProductionDialogs():Boolean {
        return (true);
    }

    public function areErrorsReported():Boolean {
        return (false);
    }

    public function areDeveloperHotkeysEnabled():Boolean {
        return (false);
    }

    public function isDebug():Boolean {
        return (true);
    }


}
}//package kabam.rotmg.application.impl
