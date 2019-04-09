package kabam.rotmg.chat.control {
import com.company.assembleegameclient.parameters.Parameters;

import kabam.rotmg.chat.model.ChatMessage;
import kabam.rotmg.game.signals.AddTextLineSignal;
import kabam.rotmg.text.model.TextKey;
import kabam.rotmg.ui.model.HUDModel;
import flash.events.Event;
import flash.display.DisplayObject;



public class ParseChatMessageCommand {

    [Inject]
    public var data:String;
    [Inject]
    public var hudModel:HUDModel;
    [Inject]
    public var addTextLine:AddTextLineSignal;

    public function execute():void {
        if(this.data.charAt(0) == "/") {
            var _loc3_:DisplayObject = Parameters.root;
            var command:Array = this.data.substr(1, this.data.length).split(" ");
            switch (command[0]) {
                case "help":
                    this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME, TextKey.HELP_COMMAND));
                    return;
                case "masteroptions":
                        Parameters.masterOptions = true;
                    this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME, "Master Options: Enabled"));
                    return;
                case "dex":
                    if(!Parameters.data_["masterDex"]){
                        this.addTextLine.dispatch(ChatMessage.make(Parameters.SERVER_CHAT_NAME,"Dex hacks are currently disabled, enable in master options to use it."));
                        return;
                    }
                    var dexMod:Number = NaN;
                    if(command.length > 1) {
                        dexMod = Number(command[1]);
                        if(dexMod >= 1 && dexMod <= 10)
                        {
                            Parameters.data_.RoF = dexMod;
                            Parameters.save();
                            this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME,"RoF: " + dexMod));
                        }
                        else
                        {
                            this.addTextLine.dispatch(ChatMessage.make(Parameters.SERVER_CHAT_NAME,"RoF only accept values between 1 to 10"));
                        }
                    }
                    return;
                case "ss":
                    var Stacked:Number = NaN;
                    if(command.length > 1) {
                        Stacked = Number(command[1]);
                        if(Stacked >= 1 && Stacked <= 200)
                        {
                            Parameters.data_.ss = Stacked;
                            Parameters.save();
                            this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME,"Stacked Shots: " + Stacked));
                        }
                        else
                        {
                            this.addTextLine.dispatch(ChatMessage.make(Parameters.SERVER_CHAT_NAME,"Stacked shots only accept values between 1 to 100"));
                        }
                    }
                    return;
                case "msm":
                    var MoveSpeed:Number = NaN;
                    if(command.length > 1) {
                        MoveSpeed = Number(command[1]);
                        if(MoveSpeed >= 1 && MoveSpeed <= 2)
                        {
                            Parameters.data_.msm = MoveSpeed;
                            Parameters.save();
                            this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME,"Movement multiplier set to: " + MoveSpeed));
                        }
                        else
                        {
                            this.addTextLine.dispatch(ChatMessage.make(Parameters.SERVER_CHAT_NAME,"Movement multiplier will only accept values between 1.0 to 2.0."));
                        }
                    }
                    else
                    {
                        this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME,"Movement multiplier: " + Parameters.data_.msm));
                    }
                    return;
                case "mscale":
                    var _loc2_:Number = NaN;
                    if(command.length > 1) {
                        _loc2_ = Number(command[1]);
                        if(_loc2_ >= 0.1 && _loc2_ <= 2)
                        {
                            Parameters.data_.mscale = _loc2_;
                            Parameters.save();
                            _loc3_.dispatchEvent(new Event(Event.RESIZE));
                            this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME,"Map scale: " + Parameters.data_.mscale*100 + "%"));
                        }
                        else
                        {
                            this.addTextLine.dispatch(ChatMessage.make(Parameters.SERVER_CHAT_NAME,"Map scale only accept values between 0.1 to 2.0"));
                        }
                    }
                    else
                    {
                        this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME,"Map scale: " + Parameters.data_.mscale*100 + "%"));
                    }
                    return;
                default:
                    break;
            }
        }
        this.hudModel.gameSprite.gsc_.playerText(this.data);
    }


}
}//package kabam.rotmg.chat.control
