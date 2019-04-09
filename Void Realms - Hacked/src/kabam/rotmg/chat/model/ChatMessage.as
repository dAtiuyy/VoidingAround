package kabam.rotmg.chat.model
{
public class ChatMessage
{

    public var name:String;
    public var nameColor:String;
    public var textColor:String;
    public var rank:int;
    public var text:String;
    public var objectId:int = -1;
    public var numStars:int = -1;
    public var recipient:String = "";
    public var isToMe:Boolean;
    public var isWhisper:Boolean;
    public var tokens:Object;


    public static function make(_arg_1:String, _arg_3:String, _arg_4:int=-1, _arg_5:int=-1, _arg_6:String="", _arg_7:Boolean=false, _arg_8:Object=null, _arg_9:Boolean=false, _arg_10:String="0x00FFFF", _arg_2:String="0x00FFFF", _arg_11:int=0):ChatMessage
    {
        var _local_9:ChatMessage = new (ChatMessage)();
        _local_9.name = _arg_1;
        _local_9.nameColor = _arg_10;
        _local_9.textColor = _arg_2;
        _local_9.rank = _arg_11;
        _local_9.text = _arg_3;
        _local_9.objectId = _arg_4;
        _local_9.numStars = _arg_5;
        _local_9.recipient = _arg_6;
        _local_9.isToMe = _arg_7;
        _local_9.isWhisper = _arg_9;
        _local_9.tokens = ((_arg_8 == null) ? {} : _arg_7);
        return (_local_9);
    }


}
}

